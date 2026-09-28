import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/widgets/member_badge.dart';
import '../../auth/providers/auth_provider.dart';

/// Read+edit profile. Geography fields are read-only — they're issued by an
/// admin at verification time. Citizens edit only the address they own
/// (street / neighbourhood / town) plus contact (firstName / lastName /
/// phone).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _phone;
  late final TextEditingController _street;
  late final TextEditingController _neighbourhood;
  late final TextEditingController _town;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final u = ref.read(authProvider).user;
    _firstName = TextEditingController(text: u?.firstName ?? '');
    _lastName = TextEditingController(text: u?.lastName ?? '');
    _phone = TextEditingController(text: u?.phone ?? '');
    _street = TextEditingController(text: u?.street ?? '');
    _neighbourhood = TextEditingController(text: u?.neighbourhood ?? '');
    _town = TextEditingController(text: u?.town ?? '');
  }

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _phone.dispose();
    _street.dispose();
    _neighbourhood.dispose();
    _town.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final api = ref.read(apiClientProvider);
      await api.patch('/profile/me', data: {
        'firstName': _firstName.text.trim(),
        'lastName': _lastName.text.trim(),
        'phone': _phone.text.trim(),
        'street': _street.text.trim(),
        'neighbourhood': _neighbourhood.text.trim(),
        'town': _town.text.trim(),
      });
      await ref.read(authProvider.notifier).refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('common.save'.tr(ref)),
        backgroundColor: AppColors.brandGreen,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('common.error'.tr(ref)),
        backgroundColor: AppColors.primaryRed,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final u = ref.watch(authProvider).user;
    return Scaffold(
      appBar: AppBar(title: Text('profile.title'.tr(ref))),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Builder(builder: (_) {
            final tier = tierForUser(u);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (tier.isVerified) ...[
                      VerifiedTick(tier: tier, size: 20),
                      const SizedBox(width: 8),
                    ],
                    MemberBadge(tier: tier),
                  ],
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          _field('profile.firstName'.tr(ref), _firstName),
          _field('profile.lastName'.tr(ref), _lastName),
          _field('profile.phone'.tr(ref), _phone, keyboard: TextInputType.phone),
          const Divider(height: 32),
          _field('profile.street'.tr(ref), _street),
          _field('profile.neighbourhood'.tr(ref), _neighbourhood),
          _field('profile.town'.tr(ref), _town),
          const SizedBox(height: 24),
          Text('profile.geography'.tr(ref),
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          // Geography is read-only — the API returns these values and we
          // surface them but never offer an editor. Admin assigns them.
          _readOnly('card.province'.tr(ref), u?.province),
          _readOnly('card.district'.tr(ref), u?.district),
          _readOnly('card.ward'.tr(ref), u?.ward),
          _readOnly('card.cell'.tr(ref), u?.cell),
          const SizedBox(height: 24),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : Text('common.save'.tr(ref)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl,
      {TextInputType? keyboard}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboard,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _readOnly(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(label,
                style: TextStyle(
                    color:
                        Theme.of(context).textTheme.bodySmall?.color))),
          Text(value ?? '—',
              style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
