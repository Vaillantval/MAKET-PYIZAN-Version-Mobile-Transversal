import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_users_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';

class AdminUsersScreen extends ConsumerStatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  ConsumerState<AdminUsersScreen> createState() =>
      _AdminUsersScreenState();
}

class _AdminUsersScreenState
    extends ConsumerState<AdminUsersScreen> {
  final _searchCtrl = TextEditingController();
  String _role = '';

  final _roles = [
    ('',          'Tous'),
    ('acheteur',  'Acheteurs'),
    ('producteur','Producteurs'),
    ('collecteur','Collecteurs'),
    ('superadmin','Admins'),
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminUsersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Utilisateurs')),
      body: Column(
        children: [
          // Barre de recherche
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller:  _searchCtrl,
              decoration:  InputDecoration(
                hintText:    'Rechercher...',
                prefixIcon:  const Icon(Icons.search),
                border:      OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:   BorderSide.none,
                ),
                filled:      true,
                fillColor:   AppColors.grisClair,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16),
              ),
              onSubmitted: (v) => ref
                  .read(adminUsersProvider.notifier)
                  .charger(search: v),
            ),
          ),
          // Filtres rôle
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              children: _roles.map((r) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label:    Text(r.$2),
                  selected: _role == r.$1,
                  onSelected: (_) {
                    setState(() => _role = r.$1);
                    ref.read(adminUsersProvider.notifier)
                        .charger(role: r.$1);
                  },
                  selectedColor:   AppColors.vertMenthe,
                  checkmarkColor:  AppColors.vertFonce,
                ),
              )).toList(),
            ),
          ),
          // Liste
          Expanded(
            child: state.when(
              loading: () => const LoadingWidget(),
              error:   (e, _) => Center(child: Text('$e')),
              data:    (users) {
                if (users.isEmpty) {
                  return const EmptyState(
                    emoji: '👤', titre: 'Aucun utilisateur',
                  );
                }

                return ListView.builder(
                  padding:   const EdgeInsets.all(12),
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final u = users[i];
                    final isActive = u['is_active'] as bool? ?? true;
                    return Container(
                      margin:  const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:        Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color:     Colors.black.withOpacity(0.04),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppColors.vertMenthe,
                            child: Text(
                              (u['first_name'] as String? ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color:      AppColors.vertFonce,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${u['first_name'] ?? ''} '
                                  '${u['last_name'] ?? ''}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color:      AppColors.vertFonce,
                                  ),
                                ),
                                Text(
                                  u['email'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color:    AppColors.grisTexte,
                                  ),
                                ),
                                Text(
                                  u['role'] as String? ?? '',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color:    AppColors.vertVif,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value:    isActive,
                            onChanged: (_) => ref
                                .read(adminUsersProvider.notifier)
                                .toggle(u['id'] as int),
                            activeColor: AppColors.vertVif,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
