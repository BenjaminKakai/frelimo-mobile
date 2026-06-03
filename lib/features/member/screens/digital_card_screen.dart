import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../../../config/env.dart';
import '../../../config/theme.dart';
import '../../../shared/i18n.dart';
import '../../../shared/widgets/flag_stripe.dart';
import '../../auth/providers/auth_provider.dart';

/// The party's digital membership card.
///
/// The QR encodes `<verifyBaseUrl>/<memberNumber>` — branch staff scan it
/// with the in-app scanner, or anyone can open the URL in a browser and the
/// public verify page renders the read-only card (no PII beyond what's
/// already on the physical card).
///
/// The card renders entirely from `auth.user` — no extra network call. This
/// keeps the offline guarantee intact: a verified member can show their card
/// on a plane, in a rural area, anywhere.
class DigitalCardScreen extends ConsumerStatefulWidget {
  const DigitalCardScreen({super.key});
  @override
  ConsumerState<DigitalCardScreen> createState() => _DigitalCardScreenState();
}

class _DigitalCardScreenState extends ConsumerState<DigitalCardScreen> {
  final GlobalKey _captureKey = GlobalKey();

  Future<Uint8List?> _capturePng() async {
    try {
      final boundary = _captureKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<void> _share() async {
    final png = await _capturePng();
    if (png == null) return;
    final dir = await getTemporaryDirectory();
    final f = File('${dir.path}/frelimo-card.png');
    await f.writeAsBytes(png);
    await Share.shareXFiles([XFile(f.path)], text: 'Cartão FRELIMO');
  }

  Future<void> _download() async {
    final png = await _capturePng();
    if (png == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final f = File('${dir.path}/frelimo-card.png');
    await f.writeAsBytes(png);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Cartão guardado em ${f.path}'),
      behavior: SnackBarBehavior.floating,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final memberNumber = user.memberNumber ?? '—';
    final verifyUrl = '${Env.verifyBaseUrl}/$memberNumber';
    final status = user.status.toUpperCase();

    return Scaffold(
      appBar: AppBar(title: Text('card.title'.tr(ref))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // RepaintBoundary lets us rasterise just the card subtree.
            RepaintBoundary(
              key: _captureKey,
              child: _CardBody(
                user: user,
                verifyUrl: verifyUrl,
                memberNumber: memberNumber,
              ),
            ),
            const SizedBox(height: 24),
            if (status != 'VERIFIED') _StatusBanner(status: status),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _share,
                    icon: const Icon(Icons.share_outlined),
                    label: Text('common.share'.tr(ref)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _download,
                    icon: const Icon(Icons.download_outlined),
                    label: Text('common.download'.tr(ref)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CardBody extends ConsumerWidget {
  final dynamic user;
  final String verifyUrl;
  final String memberNumber;
  const _CardBody({
    required this.user,
    required this.verifyUrl,
    required this.memberNumber,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AspectRatio(
      aspectRatio: 1.586, // ISO/IEC 7810 ID-1 — feels card-like
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryRed,
              Color(0xFFB10E20),
              AppColors.darkSurface,
            ],
            stops: [0.0, 0.6, 1.0],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Flag stripe on the left edge
            const Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: FlagStripe(width: 14, height: double.infinity),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 16, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/frelimo-logo.png',
                        height: 32,
                        errorBuilder: (_, __, ___) => const Icon(
                            Icons.flag,
                            color: Colors.white,
                            size: 32),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FRELIMO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'card.title'.tr(ref).toUpperCase(),
                        style: TextStyle(
                          color: AppColors.brandGold,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.fullName.toString().toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              memberNumber,
                              style: TextStyle(
                                color: AppColors.brandGold,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFeatures: const [
                                  FontFeature.tabularFigures()
                                ],
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              [
                                user.province,
                                user.district,
                                user.ward,
                                user.cell
                              ]
                                  .where((s) =>
                                      s != null && s.toString().isNotEmpty)
                                  .join(' · '),
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: QrImageView(
                          data: verifyUrl,
                          version: QrVersions.auto,
                          size: 72,
                          backgroundColor: Colors.white,
                          eyeStyle: const QrEyeStyle(
                            eyeShape: QrEyeShape.square,
                            color: AppColors.primaryRed,
                          ),
                          dataModuleStyle: const QrDataModuleStyle(
                            dataModuleShape: QrDataModuleShape.square,
                            color: AppColors.darkSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBanner extends ConsumerWidget {
  final String status;
  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (color, key) = switch (status) {
      'PENDING' => (AppColors.warning, 'card.pending'),
      'SUSPENDED' => (AppColors.primaryRed, 'card.suspended'),
      'EXPIRED' => (Colors.grey, 'card.expired'),
      _ => (AppColors.warning, 'card.pending'),
    };
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              key.tr(ref),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
