import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/scanned_product.dart';
import '../services/openfoodfacts_service.dart';
import '../services/sound_service.dart';
import '../theme/colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  final _sound = SoundService();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    _sound.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_busy) return;
    if (capture.barcodes.isEmpty) return;
    final barcode = capture.barcodes.first.rawValue;
    if (barcode == null) return;

    setState(() => _busy = true);
    await _sound.playShutter();
    await _controller.stop();

    try {
      final product = await OpenFoodFactsService().lookup(barcode);
      if (!mounted) return;
      Navigator.of(context).pop(product);
    } catch (e) {
      if (!mounted) return;
      _showErrorSheet(e.toString());
      await _controller.start();
      setState(() => _busy = false);
    }
  }

  void _showErrorSheet(String message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SufraColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, size: 42, color: SufraColors.terracotta),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: SufraColors.textDark, fontSize: 15)),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسنًا، حاول مجددًا'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _manualEntry() async {
    final controller = TextEditingController();
    final code = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SufraColors.cream,
        title: const Text('إدخال الباركود يدويًا'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: 'مثال: 6291041500213'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('بحث')),
        ],
      ),
    );
    if (code != null && code.isNotEmpty) {
      await _onDetect(
        BarcodeCapture(barcodes: [Barcode(rawValue: code)]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          // Dim overlay with a scan-frame cutout
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(painter: _ScannerOverlayPainter()),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _circleButton(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
                  const Spacer(),
                  _circleButton(Icons.keyboard_rounded, _manualEntry),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                if (_busy) const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  _busy ? 'جاري البحث عن المنتج...' : 'وجّه الكاميرا نحو الباركود',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final cutoutW = size.width * 0.75;
    final cutoutH = cutoutW * 0.6;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2 - 40),
      width: cutoutW,
      height: cutoutH,
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(24));

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, Paint()..color = Colors.black.withValues(alpha: 0.5));

    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF7C9866)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
