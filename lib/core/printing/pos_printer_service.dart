import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sunmi_printer_plus/sunmi_printer_plus.dart';
import '../utils/format_utils.dart';
import '../utils/string_utils.dart';
import '../../models/pos_sale.dart';

/// État de l'imprimante thermique intégrée (terminaux Sunmi uniquement).
/// Sur tout autre appareil (téléphone ordinaire, iOS, web…), reste
/// [PosPrinterEtat.indisponible] en permanence — jamais d'exception.
enum PosPrinterEtat { verification, disponible, indisponible, erreurPapier, erreurTete }

class PosPrinterState {
  final PosPrinterEtat etat;
  final String message;
  const PosPrinterState(this.etat, [this.message = '']);

  bool get disponible => etat == PosPrinterEtat.disponible;
}

/// Résultat d'une tentative d'impression — jamais d'exception ne remonte
/// à l'appelant, l'impression n'est jamais bloquante pour l'encaissement.
class PosPrintResult {
  final bool succes;
  final bool indisponible;
  final String? erreur;
  const PosPrintResult._({required this.succes, required this.indisponible, this.erreur});

  factory PosPrintResult.succes() =>
      const PosPrintResult._(succes: true, indisponible: false);
  factory PosPrintResult.indisponible() =>
      const PosPrintResult._(succes: false, indisponible: true);
  factory PosPrintResult.erreur(String message) =>
      PosPrintResult._(succes: false, indisponible: false, erreur: message);
}

final posPrinterProvider =
    StateNotifierProvider<PosPrinterNotifier, PosPrinterState>((ref) {
  final notifier = PosPrinterNotifier();
  notifier.init();
  return notifier;
});

class PosPrinterNotifier extends StateNotifier<PosPrinterState> {
  PosPrinterNotifier() : super(const PosPrinterState(PosPrinterEtat.verification));

  /// Tente de détecter une imprimante Sunmi. Échec ou appareil non-Sunmi
  /// (téléphone ordinaire, iOS, web) → [PosPrinterEtat.indisponible],
  /// AUCUNE exception ne remonte.
  Future<void> init() async {
    if (!Platform.isAndroid) {
      state = const PosPrinterState(PosPrinterEtat.indisponible);
      return;
    }
    try {
      final raw = await SunmiConfig.getStatus();
      state = _etatDepuisStatus(_parserStatus(raw));
    } catch (_) {
      // Pas de service Sunmi natif sur cet appareil — dégradation silencieuse.
      state = const PosPrinterState(PosPrinterEtat.indisponible);
    }
  }

  /// Revérifie l'état juste avant une impression (papier retiré, capot
  /// ouvert entre-temps…).
  Future<PosPrinterState> checkStatus() async {
    if (!Platform.isAndroid) return state;
    try {
      final raw = await SunmiConfig.getStatus();
      state = _etatDepuisStatus(_parserStatus(raw));
    } catch (_) {
      state = const PosPrinterState(PosPrinterEtat.indisponible);
    }
    return state;
  }

  PrinterStatus _parserStatus(String? raw) {
    if (raw == null) return PrinterStatus.UNKNOWN;
    return PrinterStatus.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => PrinterStatus.UNKNOWN,
    );
  }

  PosPrinterState _etatDepuisStatus(PrinterStatus status) {
    switch (status) {
      case PrinterStatus.ERR_PAPER_OUT:
        return const PosPrinterState(
          PosPrinterEtat.erreurPapier,
          'Plus de papier — remplacez le rouleau puis réessayez.',
        );
      case PrinterStatus.ERR_COVER:
      case PrinterStatus.ERR_COVER_INCOMPLETE:
        return const PosPrinterState(
          PosPrinterEtat.erreurTete,
          'Tête d\'impression ouverte — fermez le capot puis réessayez.',
        );
      case PrinterStatus.OFFLINE:
      case PrinterStatus.UNKNOWN:
        return const PosPrinterState(PosPrinterEtat.indisponible);
      default:
        return const PosPrinterState(PosPrinterEtat.disponible);
    }
  }

  // ── Impression du reçu ────────────────────────────────────────────

  /// Construit et imprime le ticket 80mm d'une vente. No-op silencieux
  /// si aucune imprimante n'est disponible ; ne bloque JAMAIS
  /// l'encaissement (aucune exception ne remonte à l'appelant).
  Future<PosPrintResult> imprimerRecu(
    PosSale vente, {
    required String nomOperateur,
    required String nomCaisse,
    String? nomClient,
    double? montantRecu,
  }) async {
    if (!Platform.isAndroid) return PosPrintResult.indisponible();

    final etatActuel = await checkStatus();
    if (etatActuel.etat == PosPrinterEtat.erreurPapier ||
        etatActuel.etat == PosPrinterEtat.erreurTete) {
      return PosPrintResult.erreur(etatActuel.message);
    }
    if (etatActuel.etat != PosPrinterEtat.disponible) {
      return PosPrintResult.indisponible();
    }

    try {
      await _imprimerTicket(
        vente,
        nomOperateur: nomOperateur,
        nomCaisse: nomCaisse,
        nomClient: nomClient,
        montantRecu: montantRecu,
      );
      return PosPrintResult.succes();
    } catch (e) {
      return PosPrintResult.erreur('Erreur d\'impression : $e');
    }
  }

  Future<void> _imprimerTicket(
    PosSale vente, {
    required String nomOperateur,
    required String nomCaisse,
    String? nomClient,
    double? montantRecu,
  }) async {
    // ── En-tête ──────────────────────────────────────────────────
    await _texte('MAKET PEYIZAN',
        style: SunmiTextStyle(bold: true, align: SunmiPrintAlign.CENTER, fontSize: 40));
    await _texte('maketpeyizan.ht',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 20));
    await SunmiPrinter.line();

    // ── Informations vente ───────────────────────────────────────
    await _ligneInfo('Reçu N°', vente.numeroVente ?? 'EN ATTENTE SYNC');
    await _ligneInfo('Date', FormatUtils.dateHeure(vente.vendueLe));
    await _ligneInfo('Caisse', nomCaisse);
    await _ligneInfo('Opérateur', nomOperateur);
    if (vente.montantWallet > 0 && nomClient != null && nomClient.isNotEmpty) {
      await _ligneInfo('Client', nomClient);
    }
    await SunmiPrinter.line();

    // ── Articles ─────────────────────────────────────────────────
    for (final item in vente.items) {
      final nom = _tronquer(item.nomProduit, 16);
      final qteFois = '${_formatQte(item.quantite)} x ${FormatUtils.htg(item.prixUnitaire)}';
      await _ligneColonnes([
        _Col(nom, 6),
        _Col(qteFois, 4, align: SunmiPrintAlign.RIGHT),
        _Col(FormatUtils.htg(item.sousTotal), 4, align: SunmiPrintAlign.RIGHT),
      ]);
    }
    await SunmiPrinter.line();

    // ── Total et ventilation paiement ───────────────────────────
    await _ligneColonnes([
      const _Col('TOTAL', 6, bold: true),
      _Col(FormatUtils.htg(vente.montantTotal), 6, align: SunmiPrintAlign.RIGHT, bold: true),
    ]);

    if (vente.montantWallet > 0) {
      final complement = vente.montantTotal - vente.montantWallet;
      await _ligneInfo('Payé wallet', FormatUtils.htg(vente.montantWallet));
      if (complement > 0) {
        await _ligneInfo('Payé ${vente.methodePaiement.toUpperCase()}', FormatUtils.htg(complement));
      }
    } else if (vente.methodePaiement == 'cash' && montantRecu != null) {
      final rendu = montantRecu - vente.montantTotal;
      await _ligneInfo('Reçu', FormatUtils.htg(montantRecu));
      await _ligneInfo('Rendu', FormatUtils.htg(rendu < 0 ? 0 : rendu));
    }

    await SunmiPrinter.line();

    // ── Pied de page ─────────────────────────────────────────────
    await _texte('Mèsi anpil ! Merci de votre achat',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER));
    await _texte('Makèt Peyizan — pwodwi lokal, kalite lokal',
        style: SunmiTextStyle(align: SunmiPrintAlign.CENTER, fontSize: 18));

    await SunmiPrinter.lineWrap(3);
    await SunmiPrinter.cutPaper();
  }

  String _formatQte(double q) =>
      q == q.roundToDouble() ? q.toStringAsFixed(0) : q.toStringAsFixed(2);

  String _tronquer(String s, int maxLen) =>
      s.length <= maxLen ? s : '${s.substring(0, maxLen - 1)}…';

  Future<void> _ligneInfo(String label, String valeur) => _ligneColonnes([
    _Col(label, 5),
    _Col(valeur, 7, align: SunmiPrintAlign.RIGHT),
  ]);

  Future<void> _ligneColonnes(List<_Col> colonnes) async {
    final cols = colonnes.map((c) => SunmiColumn(
      text: c.texte,
      width: c.largeur,
      style: SunmiTextStyle(align: c.align, bold: c.bold),
    )).toList();
    try {
      await SunmiPrinter.printRow(cols: cols);
    } catch (_) {
      // Repli sans accents en cas d'échec (caractère non supporté par le T2)
      final colsSansAccents = colonnes.map((c) => SunmiColumn(
        text: StringUtils.sansAccents(c.texte),
        width: c.largeur,
        style: SunmiTextStyle(align: c.align, bold: c.bold),
      )).toList();
      await SunmiPrinter.printRow(cols: colsSansAccents);
    }
  }

  Future<void> _texte(String texte, {SunmiTextStyle? style}) async {
    try {
      await SunmiPrinter.printText(texte, style: style);
    } catch (_) {
      await SunmiPrinter.printText(StringUtils.sansAccents(texte), style: style);
    }
  }
}

class _Col {
  final String texte;
  final int largeur;
  final SunmiPrintAlign align;
  final bool bold;
  const _Col(this.texte, this.largeur, {this.align = SunmiPrintAlign.LEFT, this.bold = false});
}
