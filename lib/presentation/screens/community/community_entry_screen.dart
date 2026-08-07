import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community/app_group.dart';
import '../../../providers/community_providers.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/pro_feature_teaser.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'join_group_screen.dart';

/// Tab Community di navigasi utama — cuma muncul kontennya kalau `isPro`.
/// Free tier lihat teaser upgrade (update_v2.md §3, §11).
class CommunityEntryScreen extends ConsumerWidget {
  const CommunityEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    if (!isPro) return const _ProTeaser();

    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.value;
    if (user == null) return const _CommunitySignInPrompt();

    return const _GroupListView();
  }
}

class _ProTeaser extends StatelessWidget {
  const _ProTeaser();

  @override
  Widget build(BuildContext context) {
    return const ProFeatureTeaser(
      icon: Icons.groups_rounded,
      title: 'Community — Fitur Pro',
      description: 'Buat/gabung grup habit bareng teman, saingan lewat leaderboard, dan chat '
          'real-time. Upgrade ke Pro untuk membuka fitur ini.',
    );
  }
}

class _CommunitySignInPrompt extends ConsumerStatefulWidget {
  const _CommunitySignInPrompt();

  @override
  ConsumerState<_CommunitySignInPrompt> createState() => _CommunitySignInPromptState();
}

class _CommunitySignInPromptState extends ConsumerState<_CommunitySignInPrompt> {
  bool _loading = false;

  Future<void> _signIn() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal masuk: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text('Masuk untuk Lanjut', style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Community perlu akun supaya progress kamu bisa dibagikan ke grup.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: _signIn,
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Masuk dengan Google'),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupListView extends ConsumerWidget {
  const _GroupListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final groupsAsync = ref.watch(myGroupsProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final maxWidth = isTablet ? 880.0 : 640.0;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Community', style: theme.textTheme.titleLarge),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: PrimaryPillButton(
                        label: '+ Buat Grup',
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                        ),
                        child: const Text('Join via Kode'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: groupsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text('Gagal memuat grup: $e')),
                    data: (groups) {
                      if (groups.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada grup. Buat grup baru atau join lewat kode invite dari teman.',
                            style: theme.textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return ListView.separated(
                        itemCount: groups.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _GroupTile(group: groups[i]),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final AppGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => GroupDetailScreen(groupId: group.id)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Icon(Icons.groups_rounded, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${group.members.length} anggota', style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
    );
  }
}
