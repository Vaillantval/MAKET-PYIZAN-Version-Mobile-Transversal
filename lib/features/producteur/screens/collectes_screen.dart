import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../providers/collectes_producteur_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CollectesProducteurScreen extends ConsumerWidget {
  const CollectesProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectesProducteurProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Collectes'),
        actions: [
          IconButton(
            icon:      const Icon(Icons.refresh),
            onPressed: () =>
                ref.read(collectesProducteurProvider.notifier)
                    .charger(),
          ),
        ],
      ),
      body: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => Center(child: Text('Erreur : $e')),
        data:    (participations) {
          if (participations.isEmpty) {
            return const EmptyState(
              emoji:       '🚛',
              titre:       'Aucune collecte planifiée',
              description: 'Vous serez notifié(e) dès qu\'une '
                  'collecte est organisée dans votre zone.',
            );
          }

          return RefreshIndicator(
            color:     AppColors.vertVif,
            onRefresh: () =>
                ref.read(collectesProducteurProvider.notifier)
                    .charger(),
            child: ListView.builder(
              padding:   const EdgeInsets.all(12),
              itemCount: participations.length,
              itemBuilder: (_, i) {
                final part = participations[i];
                final c    = part.collecte;
                final date = c['date_prevue'] as String?;

                return Container(
                  margin:  const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color:        Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color:     Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Header collecte
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          color: AppColors.vertMenthe,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(14),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.local_shipping,
                              color: AppColors.vertFonce),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['titre'] as String? ??
                                        c['reference'] as String? ??
                                        'Collecte',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.vertFonce,
                                    ),
                                  ),
                                  if (date != null)
                                    Text(
                                      '📅 ${FormatUtils.date(date)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.grisTexte,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            _StatutCollecteBadge(part.statut),
                          ],
                        ),
                      ),

                      // Détails
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          children: [
                            if (c['zone'] != null)
                              _InfoRow(
                                '📍', 'Zone',
                                c['zone'].toString(),
                              ),
                            if (part.quantitePrevue != null)
                              _InfoRow(
                                '⚖️', 'Quantité prévue',
                                '${part.quantitePrevue} kg',
                              ),
                            if (part.quantiteRecue != null)
                              _InfoRow(
                                '✅', 'Quantité reçue',
                                '${part.quantiteRecue} kg',
                              ),
                            if (part.montantPaye != null)
                              _InfoRow(
                                '💵', 'Montant reçu',
                                FormatUtils.htg(part.montantPaye),
                              ),

                            // Bouton confirmer si invité
                            if (part.statut == 'invite') ...[
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                icon:      const Icon(Icons.check),
                                label:     const Text(
                                    'Confirmer ma participation'),
                                onPressed: () =>
                                    _confirmer(context, ref, part.id),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      AppColors.vertVif,
                                  minimumSize: const Size(
                                      double.infinity, 44),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmer(
    BuildContext ctx, WidgetRef ref, int id,
  ) async {
    final qteCtrl   = TextEditingController();
    final notesCtrl = TextEditingController();

    final confirm = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20, top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmer ma participation',
              style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800,
                color: AppColors.vertFonce,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:   qteCtrl,
              keyboardType: const TextInputType
                  .numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText:  'Quantité prévue (kg)',
                prefixIcon: Icon(Icons.scale),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText:  'Notes (optionnel)',
                prefixIcon: Icon(Icons.note_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.vertVif,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Confirmer'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );

    if (confirm == true) {
      final success = await ref
          .read(collectesProducteurProvider.notifier)
          .confirmer(
            id,
            quantitePrevue: double.tryParse(qteCtrl.text),
            notes: notesCtrl.text,
          );
      if (ctx.mounted) {
        ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
          content: Text(
            success
                ? '✅ Participation confirmée !'
                : '❌ Erreur',
          ),
          backgroundColor:
              success ? AppColors.vertVif : AppColors.rouge,
        ));
      }
    }
  }
}

class _StatutCollecteBadge extends StatelessWidget {
  final String statut;
  const _StatutCollecteBadge(this.statut);

  @override
  Widget build(BuildContext context) {
    final colors = {
      'invite':   (AppColors.grisTexte, 'Invité'),
      'confirme': (AppColors.vertVif,   'Confirmé'),
      'present':  (AppColors.bleu,      'Présent'),
      'absent':   (AppColors.rouge,     'Absent'),
      'reporte':  (AppColors.orange,    'Reporté'),
    };
    final (color, label) = colors[statut] ??
        (AppColors.grisTexte, statut);
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color:        color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border:       Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String valeur;
  const _InfoRow(this.emoji, this.label, this.valeur);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Text(emoji),
        const SizedBox(width: 8),
        Text(label,
          style: const TextStyle(
            color: AppColors.grisTexte, fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(valeur,
          style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13,
            color: AppColors.vertFonce,
          ),
        ),
      ],
    ),
  );
}
