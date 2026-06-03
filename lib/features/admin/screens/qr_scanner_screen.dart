import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../config/env.dart';
import '../../../config/theme.dart';

/// Branch-staff QR scanner. Decodes the card QR, extracts the member number
/// from the verify URL, and either opens the public verify page (read-only,
/// no PII) or — if the deep link arrives back via app links later — pushes
/// directly to an in-app member lookup screen. For this scaffold we open
/// the URL externally; the in-app variant lands when /verify/:id is wired.
class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});
  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final _controller = MobileScannerController();
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handle(BarcodeCapture capture) async {
    if (_handled) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null) return;
    _handled = true;
    // We only act on URLs that point at our verify origin — any other
    // QR is ignored so the scanner can't be tricked into opening an
    // arbitrary URL on the operator's phone.
    if (!raw.startsWith(Env.verifyBaseUrl)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('QR inválido: $raw'),
        backgroundColor: AppColors.primaryRed,
      ));
      _handled = false;
      return;
    }
    final uri = Uri.tryParse(raw);
    if (uri != null) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Verificar Cartão'),
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _handle),
          // Brand-styled scan window outline
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.brandGold, width: 3),
              ),
            ),
          ),
          const Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Text(
              'Aponte para o código QR do cartão',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
