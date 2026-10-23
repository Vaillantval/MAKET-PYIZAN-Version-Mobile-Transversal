import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/sons/sons_app.dart';
import '../../../core/offline/connectivity_service.dart';
import '../../../core/utils/format_utils.dart';
import '../../../models/adresse.dart';
import '../providers/commande_provider.dart';
import '../providers/adresse_provider.dart';
import '../providers/panier_provider.dart';
import '../providers/wallet_provider.dart';
import '../../../shared/widgets/compte_depot.dart';
import '../../../shared/widgets/logo_paiement.dart';
import '../../../shared/ui/ui.dart';

/// Validation de la commande : livraison, adresse, moyen de paiement.
///
/// Contrat POST /api/orders/commander/ : methode_paiement ∈ moncash |
/// natcash | hors_ligne | cash. Le portefeuille n'est pas une méthode
/// côté serveur : `utiliser_wallet` + moncash/natcash (le serveur débite
/// le solde et ne redirige que pour un éventuel complément). Le bouton de
/// paiement reste visible en bas d'écran, désactivé tant qu'une condition
/// manque (adresse, preuve…), avec la raison affichée au-dessus.
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

/// Moyen de paiement proposé (ordre d'affichage = ordre de la liste).
class _Methode {
  final String code;   // moncash | natcash | hors_ligne | wallet | cash
  final String titre;
  final String sousTitre;
  const _Methode(this.code, this.titre, this.sousTitre);
}

const _methodes = [
  _Methode('moncash',    'MonCash',          'Paiement mobile immédiat'),
  _Methode('natcash',    'NatCash',          'Paiement mobile immédiat'),
  _Methode('hors_ligne', 'Virement / dépôt', 'Avec preuve de paiement jointe'),
  _Methode('wallet',     'Portefeuille',     'Votre solde Makèt Peyizan'),
  _Methode('cash',       'Espèces',          'À la livraison ou au retrait'),
];

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _methode       = 'moncash';
  String _complement    = 'moncash'; // portefeuille insuffisant : reste via…
  String _modeLivraison = 'domicile';
  int?   _adresseId;
  XFile? _preuve;
  bool   _isLoading     = false;

  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Adresse retenue : celle choisie, sinon celle par défaut, sinon la
  /// première — réellement envoyée au serveur (pas seulement affichée).
  Adresse? _adresse(List<Adresse> adresses) {
    if (adresses.isEmpty) return null;
    return adresses.where((a) => a.id == _adresseId).firstOrNull ??
        adresses.where((a) => a.isDefault).firstOrNull ??
        adresses.first;
  }

  Future<void> _choisirPreuve(ImageSource source) async {
    final image = await ImagePicker()
        .pickImage(source: source, imageQuality: 80, maxWidth: 2000);
    if (image != null) setState(() => _preuve = image);
  }

  Future<void> _commander(Adresse? adresse) async {
    setState(() => _isLoading = true);
    final wallet = _methode == 'wallet';
    final result = await ref.read(commandesProvider.notifier).passer(
      methodePaiement: wallet ? _complement : _methode,
      modeLivraison:   _modeLivraison,
      adresseId:       _modeLivraison == 'domicile' ? adresse?.id : null,
      notes:           _notesCtrl.text.trim(),
      utiliserWallet:  wallet,
      preuve:          _methode == 'hors_ligne' ? _preuve : null,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result?['success'] != true) {
      SonsApp.jouer(SonApp.erreur);
      afficherMessage(context, result?['error']?.toString() ?? 'Erreur',
          succes: false);
      return;
    }

    // Panier vidé et solde débité côté serveur
    ref.read(panierProvider.notifier).charger();
    if (wallet) ref.read(walletProvider.notifier).rafraichir();

    final data = result!['data'] as Map<String, dynamic>;
    final commandes = (data['commandes'] as List? ?? const [])
        .whereType<Map>()
        .map((c) => '${c['numero_commande']}')
        .toList();
    final reference = commandes.isNotEmpty ? commandes.first : null;
    final detail = commandes.length > 1
        ? '${commandes.length} commandes (une par producteur)'
        : reference != null ? 'Commande $reference' : null;

    // Passerelle indisponible : commandes créées, paiement à reprendre
    final erreurPaiement = data['paiement_erreur']?.toString();
    if (erreurPaiement != null) {
      afficherMessage(context, erreurPaiement, succes: false);
      context.go('/acheteur/commandes');
      return;
    }

    // MonCash / NatCash (ou complément du portefeuille) → passerelle
    final redirect = data['redirect_url']?.toString();
    if (redirect != null && redirect.isNotEmpty && reference != null) {
      context.go('/acheteur/paiement/mobile', extra: {
        'url':     redirect,
        'ref':     reference,
        'methode': wallet ? _complement : _methode,
      });
      return;
    }

    final (titre, sousTitre) = switch (_methode) {
      'wallet'     => ('Commande payée', 'Réglée avec votre portefeuille'),
      'hors_ligne' => ('Commande envoyée', 'Preuve de paiement en vérification'),
      _            => ('Commande passée', detail),
    };
    SonsApp.jouer(SonApp.commande);
    await afficherReussite(context, titre: titre, detail: sousTitre);
    if (mounted) context.go('/acheteur/commandes');
  }

  @override
  Widget build(BuildContext context) {
    final adressesState = ref.watch(adressesProvider);
    final panierState   = ref.watch(panierProvider);
    final walletState   = ref.watch(walletProvider);
    final isOnline      = ref.watch(isOnlineProvider);

    final panier      = panierState.valueOrNull;
    final total       = panier?.total ?? 0.0;
    final solde       = walletState.whenOrNull(data: (w) => w.solde) ?? 0.0;
    final walletActif = walletState.whenOrNull(data: (w) => w.isActive) ?? false;
    final adresses    = adressesState.valueOrNull ?? const <Adresse>[];
    final adresse     = _adresse(adresses);

    // Portefeuille inactif (ou devenu indisponible) : retour à MonCash
    if (_methode == 'wallet' && !walletActif) _methode = 'moncash';

    // Première condition manquante (null : tout est prêt)
    final String? raison = !isOnline
        ? 'Connexion internet requise pour commander'
        : (panier == null || panier.items.isEmpty)
            ? 'Votre panier est vide'
            : (_modeLivraison == 'domicile' && adresse == null)
                ? 'Ajoutez une adresse de livraison'
                : (_methode == 'hors_ligne' && _preuve == null)
                    ? 'Joignez la preuve de votre virement ou dépôt'
                    : (_methode == 'wallet' && solde <= 0)
                        ? 'Votre portefeuille est vide'
                        : null;

    final sections = <Widget>[
      _Section(
        titre: 'Livraison',
        child: _ModesLivraison(
          valeur: _modeLivraison,
          onChanged: (m) => setState(() => _modeLivraison = m),
        ),
      ),
      AnimatedSize(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: _modeLivraison != 'domicile'
            ? const SizedBox(width: double.infinity)
            : _Section(
                titre: 'Adresse de livraison',
                child: adressesState.isLoading && adresses.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : _Adresses(
                        adresses: adresses,
                        choisie: adresse,
                        onChanged: (a) => setState(() => _adresseId = a.id),
                        onAjouter: () async {
                          await context.push('/acheteur/checkout/adresses');
                          ref.read(adressesProvider.notifier).charger();
                        },
                      ),
              ),
      ),
      _Section(
        titre: 'Moyen de paiement',
        child: Column(
          children: [
            for (final m in _methodes)
              if (m.code != 'wallet' || walletActif)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _CarteMethode(
                    methode: m,
                    actif: _methode == m.code,
                    badge: m.code == 'moncash' ? 'Recommandé' : null,
                    onTap: () => setState(() => _methode = m.code),
                    details: _details(m.code, total, solde),
                  ),
                ),
          ],
        ),
      ),
      _Section(
        titre: 'Note pour le vendeur (optionnel)',
        child: TextField(
          controller: _notesCtrl,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'Ex : livrer avant midi, appeler avant…',
          ),
        ),
      ),
      if (panier != null) _Section(titre: 'Récapitulatif', child: _Recap(panier.nbArticles, total)),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Paiement')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          for (var i = 0; i < sections.length; i++)
            _Apparition(index: i, child: sections[i]),
        ],
      ),
      // Toujours visible, même désactivé
      bottomNavigationBar: _BarrePaiement(
        total: total,
        methode: _methode,
        complement: _complement,
        walletCouvreTout: solde >= total,
        raison: raison,
        chargement: _isLoading,
        onPayer: () => _commander(adresse),
      ),
    );
  }

  /// Contenu déplié sous la méthode sélectionnée.
  Widget _details(String code, double total, double solde) {
    switch (code) {
      case 'moncash':
      case 'natcash':
        final nom = code == 'moncash' ? 'MonCash' : 'NatCash';
        return _TexteInfo(Icons.lock_outline_rounded,
            'Vous serez redirigé vers $nom pour payer '
            '${FormatUtils.htg(total)} en toute sécurité.');
      case 'hors_ligne':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _TexteInfo(Icons.account_balance_outlined,
                'Effectuez le virement ou le dépôt, puis joignez la preuve '
                '(reçu, capture). Votre commande sera confirmée après '
                'vérification.'),
            // Comptes configurés par l'administration (rien : texte seul)
            ...?ref.watch(moyensDepotProvider).valueOrNull?.map((m) => Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: CompteDepotCarte(m),
                )),
            const SizedBox(height: 10),
            _Preuve(
              preuve: _preuve,
              onChoisir: _choisirPreuve,
              onRetirer: () => setState(() => _preuve = null),
            ),
          ],
        );
      case 'wallet':
        if (solde <= 0) {
          return Row(
            children: [
              const Expanded(
                child: _TexteInfo(Icons.info_outline_rounded,
                    'Votre portefeuille est vide.'),
              ),
              TextButton(
                onPressed: () => context.push('/acheteur/checkout/recharge'),
                child: const Text('Recharger'),
              ),
            ],
          );
        }
        if (solde >= total) {
          return _TexteInfo(Icons.check_circle_outline_rounded,
              'Votre solde couvre la commande. Solde restant après '
              'paiement : ${FormatUtils.htg(solde - total)}.');
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TexteInfo(Icons.call_split_rounded,
                '${FormatUtils.htg(solde)} pris sur votre solde, '
                'complément de ${FormatUtils.htg(total - solde)} via :'),
            const SizedBox(height: 10),
            Row(
              children: [
                for (final c in ['moncash', 'natcash']) ...[
                  _PastilleComplement(
                    code: c,
                    actif: _complement == c,
                    onTap: () => setState(() => _complement = c),
                  ),
                  const SizedBox(width: 8),
                ],
              ],
            ),
          ],
        );
      default:
        return _TexteInfo(Icons.payments_outlined,
            _modeLivraison == 'domicile'
                ? 'Vous payez ${FormatUtils.htg(total)} en espèces à la livraison.'
                : 'Vous payez ${FormatUtils.htg(total)} en espèces au retrait.');
    }
  }
}

// ── Animations ──────────────────────────────────────────────────────

/// Entrée en cascade des sections (fondu + léger glissement).
class _Apparition extends StatelessWidget {
  final int index;
  final Widget child;
  const _Apparition({required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    final reduit = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduit) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 90),
      curve: Curves.easeOutCubic,
      builder: (_, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 24 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}

// ── Sections ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  final String titre;
  final Widget child;
  const _Section({required this.titre, required this.child});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Surtitre(titre),
          child,
        ],
      );
}

class _ModesLivraison extends StatelessWidget {
  final String valeur;
  final ValueChanged<String> onChanged;
  const _ModesLivraison({required this.valeur, required this.onChanged});

  static const _modes = [
    ('domicile', 'À domicile', Icons.home_rounded),
    ('retrait',  'Chez le vendeur', Icons.storefront_rounded),
    ('collecte', 'Point de collecte', Icons.place_rounded),
  ];

  @override
  Widget build(BuildContext context) => Row(
        children: [
          for (final m in _modes) ...[
            Expanded(
              child: _Selectionnable(
                actif: valeur == m.$1,
                onTap: () => onChanged(m.$1),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
                child: Column(
                  children: [
                    Icon(m.$3,
                        size: 24,
                        color: valeur == m.$1 ? AppColors.vertFonce : AppColors.grisTexte),
                    const SizedBox(height: 6),
                    Text(m.$2,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        style: TextStyle(
                            fontSize: 12,
                            height: 1.2,
                            fontWeight: valeur == m.$1 ? FontWeight.w700 : FontWeight.w500)),
                  ],
                ),
              ),
            ),
            if (m != _modes.last) const SizedBox(width: 8),
          ],
        ],
      );
}

class _Adresses extends StatelessWidget {
  final List<Adresse> adresses;
  final Adresse? choisie;
  final ValueChanged<Adresse> onChanged;
  final VoidCallback onAjouter;
  const _Adresses({
    required this.adresses,
    required this.choisie,
    required this.onChanged,
    required this.onAjouter,
  });

  @override
  Widget build(BuildContext context) {
    if (adresses.isEmpty) {
      return _Selectionnable(
        actif: false,
        alerte: true,
        onTap: onAjouter,
        child: const Row(
          children: [
            TuileIcone(Icons.add_location_alt_rounded, couleur: AppColors.orange, taille: 40),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Aucune adresse enregistrée',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                  SizedBox(height: 2),
                  Text('Ajoutez-en une pour être livré',
                      style: TextStyle(fontSize: 12.5, color: AppColors.grisTexte)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.grisTexte),
          ],
        ),
      );
    }
    return Column(
      children: [
        for (final a in adresses)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _Selectionnable(
              actif: identical(a, choisie),
              onTap: () => onChanged(a),
              child: Row(
                children: [
                  _Pastille(actif: identical(a, choisie)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.rue,
                            style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('${a.commune} · ${a.departementLabel}',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.grisTexte)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAjouter,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Autre adresse'),
          ),
        ),
      ],
    );
  }
}

class _CarteMethode extends StatelessWidget {
  final _Methode methode;
  final bool actif;
  final String? badge;
  final VoidCallback onTap;
  final Widget details;
  const _CarteMethode({
    required this.methode,
    required this.actif,
    required this.onTap,
    required this.details,
    this.badge,
  });

  @override
  Widget build(BuildContext context) => _Selectionnable(
        actif: actif,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _Pastille(actif: actif),
                const SizedBox(width: 12),
                AnimatedScale(
                  scale: actif ? 1.08 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: LogoPaiement(methode.code, taille: 34),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(methode.titre,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w700)),
                      Text(methode.sousTitre,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.grisTexte)),
                    ],
                  ),
                ),
                if (badge != null) PuceStatut(badge!, couleur: AppColors.vertVif),
              ],
            ),
            // Détails dépliés avec la sélection
            AnimatedSize(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: actif
                  ? Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: details,
                    )
                  : const SizedBox(width: double.infinity),
            ),
          ],
        ),
      );
}

class _Preuve extends StatelessWidget {
  final XFile? preuve;
  final ValueChanged<ImageSource> onChoisir;
  final VoidCallback onRetirer;
  const _Preuve({required this.preuve, required this.onChoisir, required this.onRetirer});

  @override
  Widget build(BuildContext context) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: FadeTransition(opacity: a, child: c)),
        child: preuve == null
            ? Row(
                key: const ValueKey('vide'),
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onChoisir(ImageSource.camera),
                      icon: const Icon(Icons.photo_camera_outlined, size: 18),
                      label: const Text('Photo'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => onChoisir(ImageSource.gallery),
                      icon: const Icon(Icons.image_outlined, size: 18),
                      label: const Text('Galerie'),
                    ),
                  ),
                ],
              )
            : Container(
                key: ValueKey(preuve!.path),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.blanc,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.grisBord),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(File(preuve!.path),
                          width: 52, height: 52, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const SizedBox(
                              width: 52, height: 52,
                              child: Icon(Icons.description_outlined))),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Preuve jointe',
                              style: TextStyle(fontWeight: FontWeight.w700)),
                          Text('Elle partira avec la commande',
                              style: TextStyle(fontSize: 12, color: AppColors.grisTexte)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Retirer la preuve',
                      onPressed: onRetirer,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
      );
}

class _PastilleComplement extends StatelessWidget {
  final String code;
  final bool actif;
  final VoidCallback onTap;
  const _PastilleComplement({required this.code, required this.actif, required this.onTap});

  @override
  Widget build(BuildContext context) => _Selectionnable(
        actif: actif,
        onTap: onTap,
        rayon: 30,
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LogoPaiement(code, taille: 24),
            const SizedBox(width: 8),
            Text(code == 'moncash' ? 'MonCash' : 'NatCash',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          ],
        ),
      );
}

class _Recap extends StatelessWidget {
  final int nbArticles;
  final double total;
  const _Recap(this.nbArticles, this.total);

  @override
  Widget build(BuildContext context) => Surface(
        child: Column(
          children: [
            Row(
              children: [
                Text('$nbArticles article(s)',
                    style: const TextStyle(color: AppColors.grisTexte)),
                const Spacer(),
                Text(FormatUtils.htg(total)),
              ],
            ),
            const SizedBox(height: 6),
            const Row(
              children: [
                Text('Livraison', style: TextStyle(color: AppColors.grisTexte)),
                Spacer(),
                Text('Calculée par le vendeur',
                    style: TextStyle(color: AppColors.grisTexte, fontSize: 12.5)),
              ],
            ),
            const Divider(height: 22),
            Row(
              children: [
                const Text('Total', style: TextStyle(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(FormatUtils.htg(total),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
              ],
            ),
          ],
        ),
      );
}

// ── Barre de paiement (toujours visible) ────────────────────────────

class _BarrePaiement extends StatelessWidget {
  final double total;
  final String methode;
  final String complement;
  final bool walletCouvreTout;
  final String? raison;
  final bool chargement;
  final VoidCallback onPayer;
  const _BarrePaiement({
    required this.total,
    required this.methode,
    required this.complement,
    required this.walletCouvreTout,
    required this.raison,
    required this.chargement,
    required this.onPayer,
  });

  String get _libelle => switch (methode) {
        'moncash'    => 'Payer avec MonCash',
        'natcash'    => 'Payer avec NatCash',
        'hors_ligne' => 'Envoyer la commande et la preuve',
        'wallet'     => walletCouvreTout
            ? 'Payer avec mon portefeuille'
            : 'Portefeuille + ${complement == 'moncash' ? 'MonCash' : 'NatCash'}',
        _            => 'Commander · paiement à la livraison',
      };

  @override
  Widget build(BuildContext context) {
    final pret = raison == null && !chargement;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: AppColors.noir.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text('Total à payer',
                      style: TextStyle(color: AppColors.grisTexte)),
                  const Spacer(),
                  CompteurAnime(
                    valeur: total,
                    format: FormatUtils.htg,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.4),
                  ),
                ],
              ),
              // Raison du blocage (glisse à l'apparition / disparition)
              AnimatedSize(
                duration: const Duration(milliseconds: 220),
                child: raison == null
                    ? const SizedBox(height: 10, width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                size: 16, color: AppColors.orange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(raison!,
                                  style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.orange)),
                            ),
                          ],
                        ),
                      ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: pret || chargement ? 1 : 0.55,
                child: ElevatedButton(
                  onPressed: pret ? onPayer : null,
                  style: ElevatedButton.styleFrom(
                    disabledBackgroundColor: AppColors.noir,
                    disabledForegroundColor: AppColors.blanc,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: chargement
                        ? const SizedBox(
                            key: ValueKey('charge'),
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                                color: AppColors.blanc, strokeWidth: 2.4),
                          )
                        : Row(
                            key: ValueKey('$methode$complement$walletCouvreTout'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (methode != 'cash' && methode != 'hors_ligne') ...[
                                LogoPaiement(methode, taille: 22),
                                const SizedBox(width: 10),
                              ],
                              Flexible(
                                child: Text(_libelle,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Briques ─────────────────────────────────────────────────────────

/// Carte sélectionnable : fond menthe et bordure verte une fois choisie.
class _Selectionnable extends StatelessWidget {
  final bool actif;
  final bool alerte;
  final VoidCallback onTap;
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double rayon;
  const _Selectionnable({
    required this.actif,
    required this.onTap,
    required this.child,
    this.alerte = false,
    this.padding = const EdgeInsets.all(14),
    this.rayon = 18,
  });

  @override
  Widget build(BuildContext context) => Semantics(
        selected: actif,
        button: true,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: actif ? AppColors.vertMenthe : AppColors.blanc,
            borderRadius: BorderRadius.circular(rayon),
            border: Border.all(
              color: actif
                  ? AppColors.vertFonce
                  : alerte ? AppColors.orange : AppColors.grisBord,
              width: actif ? 1.6 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(rayon),
              onTap: onTap,
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      );
}

class _Pastille extends StatelessWidget {
  final bool actif;
  const _Pastille({required this.actif});

  @override
  Widget build(BuildContext context) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: actif ? AppColors.vertFonce : AppColors.blanc,
          border: Border.all(
              color: actif ? AppColors.vertFonce : AppColors.grisLeger, width: 1.6),
        ),
        child: AnimatedScale(
          scale: actif ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutBack,
          child: const Icon(Icons.check_rounded, size: 14, color: AppColors.blanc),
        ),
      );
}

class _TexteInfo extends StatelessWidget {
  final IconData icone;
  final String texte;
  const _TexteInfo(this.icone, this.texte);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 18, color: AppColors.vertFonce),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texte,
                style: const TextStyle(fontSize: 13, height: 1.35)),
          ),
        ],
      );
}
