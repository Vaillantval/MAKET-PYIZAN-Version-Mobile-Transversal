import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/adresse_provider.dart';
import '../../../shared/widgets/geo_selector.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdressesScreen extends ConsumerWidget {
  const AdressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adressesProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      appBar: AppBar(
        title: const Text('Mes Adresses'),
      ),
      body: state.when(
        loading: () => const LoadingWidget(message: 'Chargement...'),
        error: (e, _) => Center(child: Text('Erreur : $e')),
        data: (adresses) {
          if (adresses.isEmpty) {
            return EmptyState(
              emoji: '📍',
              titre: 'Aucune adresse',
              description: 'Ajoutez votre première adresse.',
              boutonLabel: 'Ajouter une adresse',
              onBouton: () => _afficherModalCreation(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: adresses.length,
            itemBuilder: (_, i) {
              final addr = adresses[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: addr.isDefault
                        ? AppColors.vertVif
                        : Colors.transparent,
                    width: addr.isDefault ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                addr.rue,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppColors.vertFonce,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${addr.commune}, ${addr.departement}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grisTexte,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (addr.isDefault)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.vertVif
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '⭐ Par défaut',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.vertVif,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!addr.isDefault)
                          TextButton(
                            onPressed: () => ref
                                .read(adressesProvider.notifier)
                                .setDefault(addr.id),
                            child: const Text(
                              'Par défaut',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.vertVif,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text(
                                    'Supprimer cette adresse ?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context),
                                    child:
                                        const Text('Annuler'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      ref
                                          .read(adressesProvider
                                              .notifier)
                                          .supprimer(addr.id);
                                    },
                                    style: ElevatedButton
                                        .styleFrom(
                                      backgroundColor:
                                          AppColors.rouge,
                                    ),
                                    child: const Text(
                                        'Supprimer'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: const Text(
                            'Supprimer',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.rouge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _afficherModalCreation(context, ref),
        backgroundColor: AppColors.vertFonce,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _afficherModalCreation(
    BuildContext context,
    WidgetRef ref,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _ModalCreationAdresse(ref: ref),
    );
  }
}

class _ModalCreationAdresse extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _ModalCreationAdresse({required this.ref});

  @override
  ConsumerState<_ModalCreationAdresse> createState() =>
      _ModalCreationAdresseState();
}

class _ModalCreationAdresseState
    extends ConsumerState<_ModalCreationAdresse> {
  late String _dept = '';
  late String _commune = '';
  late String _section = '';
  final _rueCtrl = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _rueCtrl.dispose();
    super.dispose();
  }

  Future<void> _creer() async {
    if (_dept.isEmpty ||
        _commune.isEmpty ||
        _rueCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez remplir tous les champs'),
          backgroundColor: AppColors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final success = await widget.ref
        .read(adressesProvider.notifier)
        .creer({
      'rue': _rueCtrl.text,
      'commune': _commune,
      'departement': _dept,
      'section_communale': _section,
    });

    setState(() => _isLoading = false);

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Adresse ajoutée'),
            backgroundColor: AppColors.vertVif,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Erreur lors de la création'),
            backgroundColor: AppColors.rouge,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      bottom: MediaQuery.of(context).viewInsets.bottom,
    ),
    child: Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ajouter une adresse',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.vertFonce,
              ),
            ),
            const SizedBox(height: 20),

            // Sélecteur géographique
            GeoSelector(
              onChanged: (dept, commune, section) {
                setState(() {
                  _dept = dept;
                  _commune = commune;
                  _section = section;
                });
              },
            ),
            const SizedBox(height: 16),

            // Rue
            TextField(
              controller: _rueCtrl,
              decoration: InputDecoration(
                labelText: 'Rue / Lieu-dit',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Boutons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _creer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.vertFonce,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('Ajouter'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
