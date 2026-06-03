import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../i18n.dart';
import '../models/user_model.dart';

/// Membership tier taxonomy for FRELIMO. Derived purely from data the backend
/// already returns on /profile/me (status + roles + isAdmin) — no new fields.
/// Order matters: leadership/staff roles outrank plain member status.
enum MemberTier {
  leadershipNational,
  leadershipProvincial,
  coordination,
  official,
  member,
  pending,
  suspended,
  citizen,
}

extension MemberTierMeta on MemberTier {
  /// i18n key for the label.
  String get labelKey => switch (this) {
        MemberTier.leadershipNational => 'badge.leadershipNational',
        MemberTier.leadershipProvincial => 'badge.leadershipProvincial',
        MemberTier.coordination => 'badge.coordination',
        MemberTier.official => 'badge.official',
        MemberTier.member => 'badge.member',
        MemberTier.pending => 'badge.pending',
        MemberTier.suspended => 'badge.suspended',
        MemberTier.citizen => 'badge.citizen',
      };

  IconData get icon => switch (this) {
        MemberTier.leadershipNational => Icons.workspace_premium,
        MemberTier.leadershipProvincial => Icons.workspace_premium,
        MemberTier.coordination => Icons.groups,
        MemberTier.official => Icons.shield,
        MemberTier.member => Icons.verified,
        MemberTier.pending => Icons.hourglass_top,
        MemberTier.suspended => Icons.block,
        MemberTier.citizen => Icons.person_outline,
      };

  Color get color => switch (this) {
        MemberTier.leadershipNational => AppColors.brandGold,
        MemberTier.leadershipProvincial => AppColors.brandGold,
        MemberTier.coordination => AppColors.brandGreen,
        MemberTier.official => AppColors.brandGreen,
        MemberTier.member => AppColors.brandGreen,
        MemberTier.pending => AppColors.warning,
        MemberTier.suspended => AppColors.primaryRed,
        MemberTier.citizen => Colors.grey,
      };

  /// Whether a verified tick (✓) is warranted for this tier.
  bool get isVerified => switch (this) {
        MemberTier.leadershipNational ||
        MemberTier.leadershipProvincial ||
        MemberTier.coordination ||
        MemberTier.official ||
        MemberTier.member =>
          true,
        _ => false,
      };
}

/// Resolve a tier from the raw signals. Roles take precedence over status so a
/// national leader who is also a verified member shows the leadership badge.
MemberTier tierFor({
  required String status,
  required List<String> roles,
  required bool isAdmin,
}) {
  final r = roles.map((e) => e.toUpperCase()).toSet();
  if (r.contains('SUPER_ADMIN') || r.contains('NATIONAL_ADMIN')) {
    return MemberTier.leadershipNational;
  }
  if (r.contains('PROVINCIAL_ADMIN')) return MemberTier.leadershipProvincial;
  if (r.contains('DISTRICT_COORD') || r.contains('WARD_COORD')) {
    return MemberTier.coordination;
  }
  if (isAdmin || r.isNotEmpty) return MemberTier.official;
  return switch (status.toUpperCase()) {
    'VERIFIED' => MemberTier.member,
    'PENDING' => MemberTier.pending,
    'SUSPENDED' => MemberTier.suspended,
    _ => MemberTier.citizen,
  };
}

MemberTier tierForUser(UserModel? u) => tierFor(
      status: u?.status ?? 'CITIZEN',
      roles: u?.roles ?? const [],
      isAdmin: u?.isAdmin ?? false,
    );

/// Pill badge showing the member's tier (icon + label). `onDark` flips the
/// fill so it reads on the red welcome-card gradient.
class MemberBadge extends ConsumerWidget {
  final MemberTier tier;
  final bool onDark;
  final bool compact;
  const MemberBadge({super.key, required this.tier, this.onDark = false, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = tier.color;
    final bg = onDark ? Colors.white.withValues(alpha: 0.18) : c.withValues(alpha: 0.14);
    final fg = onDark ? Colors.white : c;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10, vertical: compact ? 3 : 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: onDark ? null : Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tier.icon, size: compact ? 12 : 14, color: fg),
          const SizedBox(width: 5),
          Text(
            tier.labelKey.tr(ref),
            style: TextStyle(
                color: fg,
                fontWeight: FontWeight.w800,
                fontSize: compact ? 10 : 11,
                letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Parse a `#RRGGBB` (or `RRGGBB`) hex string to a Color, falling back to
/// brand green on anything malformed.
Color _hexColor(String hex) {
  var h = hex.replaceAll('#', '').trim();
  if (h.length == 6) h = 'FF$h';
  final v = int.tryParse(h, radix: 16);
  return v == null ? AppColors.brandGreen : Color(v);
}

/// Maps the subset of Material icon names the backend seeds to real IconData.
/// Unknown names fall back to a generic award icon so a new badge never
/// crashes the UI.
IconData iconForName(String name) {
  switch (name) {
    case 'star':
      return Icons.star;
    case 'military_tech':
      return Icons.military_tech;
    case 'account_balance':
      return Icons.account_balance;
    case 'gavel':
      return Icons.gavel;
    case 'how_to_vote':
      return Icons.how_to_vote;
    case 'workspace_premium':
      return Icons.workspace_premium;
    case 'volunteer_activism':
      return Icons.volunteer_activism;
    case 'shield':
      return Icons.shield;
    case 'groups':
      return Icons.groups;
    case 'verified':
      return Icons.verified;
    default:
      return Icons.emoji_events;
  }
}

/// Chip for a single admin-assigned custom badge (honorific/role/achievement).
class CustomBadgeChip extends ConsumerWidget {
  final AssignedBadge badge;
  final bool onDark;
  const CustomBadgeChip({super.key, required this.badge, this.onDark = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = _hexColor(badge.color);
    final isPt = ref.watch(localeProvider).languageCode == 'pt';
    final label = (isPt ? badge.namePt : badge.nameEn).isNotEmpty
        ? (isPt ? badge.namePt : badge.nameEn)
        : badge.namePt;
    final bg = onDark ? Colors.white.withValues(alpha: 0.18) : c.withValues(alpha: 0.14);
    final fg = onDark ? Colors.white : c;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: onDark ? null : Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconForName(badge.icon), size: 13, color: fg),
          const SizedBox(width: 5),
          Text(label,
              style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 11)),
        ],
      ),
    );
  }
}

/// Wrap of all assigned custom badges; renders nothing when empty.
class CustomBadgeRow extends StatelessWidget {
  final List<AssignedBadge> badges;
  final bool onDark;
  const CustomBadgeRow({super.key, required this.badges, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    if (badges.isEmpty) return const SizedBox.shrink();
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: badges.map((b) => CustomBadgeChip(badge: b, onDark: onDark)).toList(),
    );
  }
}

/// Small green ✓ tick for inline use next to a name. Renders nothing when the
/// tier isn't a verified one, so callers can drop it in unconditionally.
class VerifiedTick extends StatelessWidget {
  final MemberTier tier;
  final double size;
  final bool onDark;
  const VerifiedTick({super.key, required this.tier, this.size = 18, this.onDark = false});

  @override
  Widget build(BuildContext context) {
    if (!tier.isVerified) return const SizedBox.shrink();
    // Leadership ticks use gold; everyone else uses brand green.
    final ring = (tier == MemberTier.leadershipNational ||
            tier == MemberTier.leadershipProvincial)
        ? AppColors.brandGold
        : AppColors.brandGreen;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: ring,
        shape: BoxShape.circle,
        border: onDark ? Border.all(color: Colors.white, width: 1.2) : null,
      ),
      child: Icon(Icons.check, size: size * 0.66, color: Colors.white),
    );
  }
}
