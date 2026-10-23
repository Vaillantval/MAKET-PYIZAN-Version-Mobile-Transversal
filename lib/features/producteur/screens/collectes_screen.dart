import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/format_utils.dart';
import '../../../shared/ui/ui.dart';
import '../providers/collectes_producteur_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class CollectesProducteurScreen extends ConsumerWidget {
  const CollectesProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(collectesProducteurProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const EnTeteEcran('Collectes',
                surtitre: 'Ramassages dans votre zone'),
            Expanded(
              child: state.when(
                loading: () => const LoadingWidget(),
                error:   (e, _) => ErreurChargement(e),
                data:    (participations) {
                  if (participations.isEmpty) {
                    return const EmptyState(
                      icone:       Icons.local_shipping_outlined,
                      titre:       'Aucune collecte planifiée',
                      description: 'Vous serez notifié(e) dès qu\'une '
                          'collecte est organisée dans votre zone.',
                    );
                  }

                  return RefreshIndicator(
                    color:     AppColors.vertFonce,
                    onRefresh: () =>
                        ref.read(collectesProducteurProvider.notifier)
                            .charger(),
                    child: ListView.separated(
                      padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: participations.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final part = participations[i];
                        final c    = part.collecte;
                        final date = (c['date_planifiee'] ?? c['date_prevue']) as String?;
                        final zone = c['zone'] is Map
                            ? (c['zone'] as Map)['nom']?.toString()
                            : c['zone']?.toString();
                        final statut = _statutParticipation(part.statut);

                        return Surface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const TuileIcone(Icons.local_shipping_outlined,
                                      couleur: AppColors.violet, taille: 42),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          c['titre'] as String? ??
                                              c['reference'] as String? ??
                                              'Collecte',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14.5,
                                          ),
                                        ),
                                        if (date != null)
                                          Text(FormatUtils.date(date),
                                            style: const TextStyle(
                                              fontSize: 12.5,
                                              color: AppColors.grisTexte,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  PuceStatut(statut.$1, couleur: statut.$2),
                                ],
                              ),
                              const SizedBox(height: 10),
                              const Divider(),
                              const SizedBox(height: 4),
                              if (zone != null)
                                LigneInfo(Icons.place_outlined, 'Zone', zone),
                              if (part.quantitePrevue != null)
                                LigneInfo(Icons.scale_outlined, 'Prévu',
                                    '${part.quantitePrevue} kg'),
                              if (part.quantiteRecue != null)
                                LigneInfo(Icons.inventory_outlined, 'Reçu',
                                    '${part.quantiteRecue} kg'),
                              if (part.montantPaye != null)
                                LigneInfo(Icons.payments_outlined, 'Montant',
                                    FormatUtils.htg(part.montantPaye)),

                              // Invitation à confirmer
                              if (part.statut == 'invite') ...[
                                const SizedBox(height: 12),
                                FilledButton.icon(
                                  icon:  const Icon(Icons.check_rounded),
                                  label: const Text('Confirmer ma participation'),
                                  onPressed: () =>
                                      _confirmer(context, ref, part.id),
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size(double.infinity, 46),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  (String, Color) _statutParticipation(String statut) => switch (statut) {
        'invite'   => ('Invité', AppColors.grisTexte),
        'inscrit' || 'confirme' => ('Confirmé', AppColors.vertVif),
        'present'  => ('Présent', AppColors.bleu),
        'absent'   => ('Absent', AppColors.rouge),
        'reporte'  => ('Reporté', AppColors.orange),
        _          => (statut, AppColors.grisTexte),
      };

  Future<void> _confirmer(
    BuildContext ctx, WidgetRef ref, int id,
  ) async {
    final qteCtrl   = TextEditingController();
    final notesCtrl = TextEditingController();

    final confirm = await showModalBottomSheet<bool>(
      context: ctx,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20, right: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Confirmer ma participation',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            TextField(
              controller:   qteCtrl,
              keyboardType: const TextInputType
                  .numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText:  'Quantité prévue (kg)',
                prefixIcon: Icon(Icons.scale_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesCtrl,
              decoration: const InputDecoration(
                labelText:  'Notes (optionnel)',
                prefixIcon: Icon(Icons.notes_rounded),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
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
        afficherMessage(ctx,
            success ? 'Participation confirmée' : 'Confirmation impossible',
            succes: success);
      }
    }
  }
}
