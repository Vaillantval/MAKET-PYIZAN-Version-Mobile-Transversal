import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/admin_users_provider.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/ui/ui.dart';
import '../widgets/admin_scaffold.dart';

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

  static const _roles = [
    ('',          'Tous'),
    ('acheteur',  'Utilisateurs'),
    // Vendre ne dépend plus du rôle : « membre » = membre d'au moins une
    // entreprise (filtre backend dédié, l'ancien rôle producteur n'existe plus)
    ('membre',    'Membres d\'entreprise'),
    ('collecteur','Collecteurs'),
    ('pos_operator','Caissiers'),
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

    return AdminScaffold(
      titre: 'Utilisateurs',
      retour: '/admin/plus',
      filtres: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText:   'Nom, e-mail, téléphone…',
                prefixIcon: Icon(Icons.search_rounded),
              ),
              onSubmitted: (v) => ref
                  .read(adminUsersProvider.notifier)
                  .charger(search: v),
            ),
          ),
          PastillesFiltre(
            options: _roles,
            valeur: _role,
            onChanged: (r) {
              setState(() => _role = r);
              ref.read(adminUsersProvider.notifier).charger(role: r);
            },
          ),
        ],
      ),
      corps: state.when(
        loading: () => const LoadingWidget(),
        error:   (e, _) => ErreurChargement(e),
        data:    (users) {
          if (users.isEmpty) {
            return const EmptyState(
              icone: Icons.group_outlined, titre: 'Aucun utilisateur',
            );
          }
          return ListView.separated(
            padding:   const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final u = users[i];
              final isActive = u['is_active'] as bool? ?? true;
              final nom = '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
              return Surface(
                padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
                child: Row(
                  children: [
                    AvatarInitiales(nom.isEmpty ? '?' : nom, taille: 42),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(nom.isEmpty ? '—' : nom,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14.5,
                            ),
                          ),
                          Text(u['email'] as String? ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5, color: AppColors.grisTexte,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_libelleRole(u),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.vertFonce,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: isActive,
                      onChanged: (_) => ref
                          .read(adminUsersProvider.notifier)
                          .toggle(u['id'] as int),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Libellé du compte : rôle + entreprises dont il est membre (/admin/users
/// renvoie le même profil que /me, avec `entreprises`).
String _libelleRole(Map<String, dynamic> u) {
  const libelles = {
    'acheteur':     'Utilisateur',
    'collecteur':   'Agent de collecte',
    'pos_operator': 'Opérateur de caisse',
    'superadmin':   'Super-admin',
  };
  final role = u['is_superuser'] == true ? 'superadmin' : (u['role'] as String? ?? '');
  final entreprises = (u['entreprises'] as List? ?? const [])
      .map((e) => (e as Map)['nom']?.toString() ?? '')
      .where((n) => n.isNotEmpty)
      .toList();
  final base = libelles[role] ?? role;
  return entreprises.isEmpty ? base : '$base · ${entreprises.join(', ')}';
}
