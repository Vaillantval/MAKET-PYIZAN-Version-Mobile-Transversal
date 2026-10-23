import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/format_utils.dart';
import 'ui.dart';

/// Ventes d'une journée (point de la courbe).
typedef PointVente = ({DateTime jour, double montant});

/// Lit `ventes_par_jour` des statistiques du tableau de bord :
/// `[{"date": "2026-10-01", "montant": "1250.00"}, …]` (ordre quelconque,
/// montants en chaîne ou nombre). Les entrées illisibles sont ignorées.
List<PointVente> lireVentesParJour(dynamic brut) {
  if (brut is! List) return const [];
  final points = <PointVente>[];
  for (final e in brut) {
    if (e is! Map) continue;
    final jour = DateTime.tryParse('${e['date']}');
    final montant = double.tryParse('${e['montant']}');
    if (jour != null && montant != null) {
      points.add((jour: jour, montant: montant));
    }
  }
  points.sort((a, b) => a.jour.compareTo(b.jour));
  return points;
}

/// Carte « Ventes » : courbe lissée des montants par jour avec aire
/// dégradée (cf. maquette tableau de bord). Rien n'est affiché sans au
/// moins deux points.
class CourbeVentes extends StatelessWidget {
  final List<PointVente> points;
  final String titre;
  const CourbeVentes(this.points, {this.titre = 'Ventes', super.key});

  static const _mois = ['janv.', 'févr.', 'mars', 'avr.', 'mai', 'juin',
      'juil.', 'août', 'sept.', 'oct.', 'nov.', 'déc.'];

  String _date(DateTime d) => '${d.day} ${_mois[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    if (points.length < 2) return const SizedBox.shrink();
    final total = points.fold<double>(0, (s, p) => s + p.montant);
    final milieu = points[points.length ~/ 2];

    return Surface(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('$titre · ${points.length} jours',
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ),
              Text(FormatUtils.htg(total),
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.vertVif)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: Semantics(
              label: '$titre sur ${points.length} jours : '
                  '${FormatUtils.htg(total)} au total',
              child: CustomPaint(painter: _PeintreCourbe(points)),
            ),
          ),
          const SizedBox(height: 8),
          DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 11, color: AppColors.grisLeger),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_date(points.first.jour)),
                Text(_date(milieu.jour)),
                Text(_date(points.last.jour)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PeintreCourbe extends CustomPainter {
  final List<PointVente> points;
  _PeintreCourbe(this.points);

  @override
  void paint(Canvas canvas, Size size) {
    final max = points.map((p) => p.montant).reduce((a, b) => a > b ? a : b);
    final haut = max <= 0 ? 1.0 : max * 1.1;
    const marge = 6.0; // place pour le point final
    final dx = (size.width - marge) / (points.length - 1);
    final pts = [
      for (var i = 0; i < points.length; i++)
        Offset(i * dx,
            marge + (size.height - marge) * (1 - points[i].montant / haut)),
    ];

    // Lissage : courbes de Bézier passant par chaque point
    final ligne = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i], b = pts[i + 1];
      final cx = (a.dx + b.dx) / 2;
      ligne.cubicTo(cx, a.dy, cx, b.dy, b.dx, b.dy);
    }

    // Lignes de repère discrètes
    final repere = Paint()
      ..color = AppColors.grisBord
      ..strokeWidth = 1;
    for (final f in [0.33, 0.66]) {
      final y = marge + (size.height - marge) * f;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), repere);
    }

    final aire = Path.from(ligne)
      ..lineTo(pts.last.dx, size.height)
      ..lineTo(pts.first.dx, size.height)
      ..close();
    canvas.drawPath(
      aire,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.vertMoyen.withValues(alpha: 0.35),
            AppColors.vertMoyen.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      ligne,
      Paint()
        ..color = AppColors.vertVif
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round,
    );

    // Dernier jour mis en évidence
    canvas.drawCircle(pts.last, 5.5, Paint()..color = AppColors.blanc);
    canvas.drawCircle(pts.last, 4, Paint()..color = AppColors.vertVif);
  }

  @override
  bool shouldRepaint(_PeintreCourbe old) => old.points != points;
}
