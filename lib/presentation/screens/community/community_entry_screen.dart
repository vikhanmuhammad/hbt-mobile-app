import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/models/community/app_group.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/community_providers.dart';
import '../../widgets/animations/fade_slide_in.dart';
import '../../widgets/animations/staggered_entrance.dart';
import '../../widgets/animations/tap_scale.dart';
import '../../widgets/pro_feature_teaser.dart';
import 'create_group_screen.dart';
import 'group_detail_screen.dart';
import 'join_group_screen.dart';

/// Community tab in main navigation — content only shows if `isPro`.
/// Free tier sees an upgrade teaser (update_v2.md §3, §11).
class CommunityEntryScreen extends ConsumerWidget {
  const CommunityEntryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPro = ref.watch(isProProvider);
    if (!isPro) return const _ProTeaser();

    final authAsync = ref.watch(authStateProvider);
    final user = authAsync.value;
    if (user == null) return const _CommunitySignInPrompt();

    // Fire-and-forget: fans the local profile photo out to any groups the
    // user is already in (see the provider's doc comment) — result isn't
    // needed here, just needs to run once per session.
    ref.watch(profilePhotoCommunitySyncProvider);

    return const _GroupListView();
  }
}

class _ProTeaser extends StatelessWidget {
  const _ProTeaser();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ProFeatureTeaser(
      icon: Icons.groups_rounded,
      title: l10n.communityProFeatureTitle,
      description: l10n.communityProFeatureDescription,
      benefits: [
        l10n.communityProBenefit1,
        l10n.communityProBenefit2,
        l10n.communityProBenefit3,
      ],
      previewBuilder: (context) => const _CommunityPreviewMock(),
    );
  }
}

/// Mock preview of the real group-list screen, rendered blurred behind the
/// Pro teaser card so free users see roughly what they'd unlock.
class _CommunityPreviewMock extends StatelessWidget {
  const _CommunityPreviewMock();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context)!.communityTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: null,
                      child: Text(AppLocalizations.of(context)!.communityCreateGroup),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: null,
                      child: Text(AppLocalizations.of(context)!.communityJoinViaCode),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              for (final entry in const [
                ('Morning Runners', 12),
                ('Book Club', 5),
                ('Water Challenge', 8),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Card(
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
                                Text(entry.$1,
                                    style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 2),
                                Text(
                                  AppLocalizations.of(context)!.communityMembersCount(entry.$2),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
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
          SnackBar(content: Text(AppLocalizations.of(context)!.communityFailedToSignIn('$e'))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.groups_rounded, size: 64, color: theme.colorScheme.primary),
              const SizedBox(height: 20),
              Text(l10n.communitySignInTitle, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Text(
                l10n.communitySignInBody,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _loading
                  ? const CircularProgressIndicator()
                  : FilledButton.icon(
                      onPressed: _signIn,
                      icon: const Icon(Icons.login_rounded),
                      label: Text(l10n.communitySignInWithGoogle),
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
    final l10n = AppLocalizations.of(context)!;
    final groupsAsync = ref.watch(myGroupsProvider);
    final isTablet = MediaQuery.sizeOf(context).width >= 600;
    final maxWidth = isTablet ? 880.0 : 640.0;

    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: Padding(
            padding: EdgeInsets.fromLTRB(isTablet ? 32 : 16, isTablet ? 32 : 20, isTablet ? 32 : 16, 24),
            child: FadeSlideIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(l10n.communityTitle, style: theme.textTheme.titleLarge),
                    IconButton(
                      tooltip: l10n.communityLogOut,
                      onPressed: () => _confirmLogout(context, ref),
                      icon: const Icon(Icons.logout_rounded),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    // Both buttons use the shared theme's button styles, but
                    // Material 3's default ElevatedButton/OutlinedButton
                    // still don't guarantee identical minimum heights on
                    // their own — pinning an explicit height on both is what
                    // actually forces them to render the same size.
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
                          ),
                          child: Text(l10n.communityCreateGroup),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const JoinGroupScreen()),
                          ),
                          child: Text(l10n.communityJoinViaCode),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: groupsAsync.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, st) => Center(child: Text(l10n.communityFailedToLoadGroups('$e'))),
                    data: (groups) {
                      return RefreshIndicator(
                        onRefresh: () async {
                          try {
                            final refreshed = ref.refresh(myGroupsProvider.future);
                            await refreshed;
                          } catch (_) {
                            // Errors surface via the AsyncValue `error` branch above.
                          }
                        },
                        child: groups.isEmpty
                            ? ListView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                children: [
                                  SizedBox(
                                    height: MediaQuery.sizeOf(context).height * 0.5,
                                    child: Center(
                                      child: Text(
                                        l10n.communityNoGroupsYet,
                                        style: theme.textTheme.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                itemCount: groups.length,
                                separatorBuilder: (_, _) => const SizedBox(height: 10),
                                itemBuilder: (context, i) => FadeSlideIn(
                                  delay: staggeredDelay(i),
                                  child: _GroupTile(group: groups[i]),
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.communityLogOutTitle),
        content: Text(l10n.communityLogOutBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.commonCancel)),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.communityLogOutConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(authServiceProvider).signOut();
  }
}

class _GroupTile extends StatelessWidget {
  const _GroupTile({required this.group});

  final AppGroup group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TapScale(
      child: Card(
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
                    Text(
                      AppLocalizations.of(context)!.communityMembersCount(group.members.length),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.textTheme.bodySmall?.color),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
