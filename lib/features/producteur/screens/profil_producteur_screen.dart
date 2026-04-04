import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';

class ProfilProducteurScreen extends ConsumerWidget {
  const ProfilProducteurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user  = ref.watch(authProvider).user;
    final stats = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.grisClair,
      body: CustomScrollView(
        slivers: [
          // ── Header ────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned:          true,
            backgroundColor: AppColors.vertFonce,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.vertFonce, Color(0xFF1E8449)],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    CircleAvatar(
                      radius:          40,
                      backgroundColor: AppColors.jaune,
                      child: Text(
                        (user?.firstName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize:   32,
                          fontWeight: FontWeight.w900,
                          color:      AppColors.vertFonce,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      user?.firstName != null
                          ? '${user!.firstName} ${user.lastName}'
                          : '—',
                      style: const TextStyle(
                        color:      Colors.white,
                        fontSize:   20,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'PlayfairDisplay',
                      ),
                    ),
                    const Text(
                      '🌾 Producteur',
                      style: TextStyle(
                        color:   Color(0xBBFFFFFF),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats rapides ──────────────────────────────────
          SliverToBoxAdapter(
            child: stats.whenOrNull(
              data: (s) => Container(
                margin:  const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _QuickStat('${s.commandesTotal}',  'Commandes'),
                    _Divider(),
                    _QuickStat('${s.nbProduitsActifs}','Produits'),
                    _Divider(),
                    _QuickStat('${s.commandesLivrees}','Livrées'),
                  ],
                ),
              ),
            ) ?? const SizedBox.shrink(),
          ),

          // ── Menu ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _MenuItem(
                    icon:  Icons.person_outline,
                    label: 'Mon profil boutique',
                    onTap: () => context.go(
                        '/producteur/profil/modifier'),
                  ),
                  _MenuItem(
                    icon:  Icons.store_outlined,
                    label: 'Mes produits',
                    onTap: () =>
                        context.go('/producteur/catalogue'),
                  ),
                  _MenuItem(
                    icon:  Icons.receipt_outlined,
                    label: 'Mes commandes',
                    onTap: () =>
                        context.go('/producteur/commandes'),
                  ),
                  _MenuItem(
                    icon:  Icons.lock_outline,
                    label: 'Changer le mot de passe',
                    onTap: () {
                      // TODO: écran changer mot de passe
                    },
                  ),
                  const SizedBox(height: 8),
                  _MenuItem(
                    icon:  Icons.logout,
                    label: 'Se déconnecter',
                    color: AppColors.rouge,
                    onTap: () {
                      ref.read(authProvider.notifier).logout();
                      context.go('/login');
                    },
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String valeur;
  final String label;
  const _QuickStat(this.valeur, this.label);

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(valeur,
        style: const TextStyle(
          fontSize:   22,
          fontWeight: FontWeight.w900,
          color:      AppColors.vertFonce,
          fontFamily: 'PlayfairDisplay',
        ),
      ),
      Text(label,
        style: const TextStyle(
          fontSize: 12, color: AppColors.grisTexte,
        ),
      ),
    ],
  );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    height: 40, width: 1,
    color: const Color(0xFFEEEEEE),
  );
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String   label;
  final Color    color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = AppColors.noir,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    decoration: BoxDecoration(
      color:        Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: ListTile(
      leading:       Icon(icon, color: color),
      title:         Text(label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color:      color,
        ),
      ),
      trailing:      const Icon(
        Icons.chevron_right,
        color: AppColors.grisTexte,
      ),
      onTap:         onTap,
      shape:         RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}
