import 'package:flutter/material.dart';
import '../models/scanned_product.dart';
import '../services/safety_score_service.dart';
import '../services/storage_service.dart';
import '../services/sound_service.dart';
import '../theme/colors.dart';

class ResultScreen extends StatefulWidget {
  final ScannedProduct product;
  const ResultScreen({super.key, required this.product});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  SafetyResult? _result;
  final _sound = SoundService();

  @override
  void initState() {
    super.initState();
    _evaluate();
  }

  Future<void> _evaluate() async {
    final family = await StorageService().loadFamily();
    final result = SafetyScoreService().evaluate(product: widget.product, family: family);
    await StorageService().addToHistory(widget.product);
    if (!mounted) return;
    setState(() => _result = result);
    if (result.level == SafetyLevel.danger) {
      _sound.playAlert();
    } else {
      _sound.playSuccess();
    }
  }

  @override
  void dispose() {
    _sound.dispose();
    super.dispose();
  }

  Color _levelColor(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe:
        return SufraColors.safe;
      case SafetyLevel.caution:
        return SufraColors.caution;
      case SafetyLevel.danger:
        return SufraColors.danger;
    }
  }

  String _levelLabel(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe:
        return 'يبدو مناسبًا';
      case SafetyLevel.caution:
        return 'انتبه قليلاً';
      case SafetyLevel.danger:
        return 'تنبيه مهم';
    }
  }

  IconData _levelIcon(SafetyLevel level) {
    switch (level) {
      case SafetyLevel.safe:
        return Icons.check_circle_rounded;
      case SafetyLevel.caution:
        return Icons.error_rounded;
      case SafetyLevel.danger:
        return Icons.warning_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    return Scaffold(
      backgroundColor: SufraColors.background,
      appBar: AppBar(title: const Text('نتيجة الفحص')),
      body: _result == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: p.imageUrl != null
                          ? Image.network(p.imageUrl!, width: 72, height: 72, fit: BoxFit.cover)
                          : Container(
                              width: 72,
                              height: 72,
                              color: SufraColors.terracottaLight.withValues(alpha: 0.4),
                              child: const Icon(Icons.fastfood_rounded, color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          if (p.brand.isNotEmpty)
                            Text(p.brand, style: TextStyle(color: SufraColors.textMuted)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: _levelColor(_result!.level).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      Icon(_levelIcon(_result!.level), size: 44, color: _levelColor(_result!.level)),
                      const SizedBox(height: 10),
                      Text(
                        _levelLabel(_result!.level),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _levelColor(_result!.level),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text('نتيجة سُفرة: ${_result!.score} / 100',
                          style: TextStyle(color: SufraColors.textMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (_result!.reasons.isNotEmpty) ...[
                  Text('تفاصيل التنبيه', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SufraColors.textDark)),
                  const SizedBox(height: 10),
                  ..._result!.reasons.map((r) => Card(
                        child: ListTile(
                          leading: Icon(Icons.flag_rounded, color: _levelColor(_result!.level)),
                          title: Text(r.message, style: const TextStyle(height: 1.4)),
                        ),
                      )),
                  const SizedBox(height: 12),
                ],
                Text('المكوّنات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SufraColors.textDark)),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      p.ingredientsText.isEmpty ? 'لا تتوفر بيانات المكوّنات لهذا المنتج.' : p.ingredientsText,
                      style: TextStyle(height: 1.6, color: SufraColors.textDark),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text('القيمة الغذائية (لكل 100غ)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: SufraColors.textDark)),
                const SizedBox(height: 10),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _nutriRow('السعرات الحرارية', p.nutriments['energy-kcal_100g'], 'كالوري'),
                        _nutriRow('السكريات', p.nutriments['sugars_100g'], 'غ'),
                        _nutriRow('الملح', p.nutriments['salt_100g'], 'غ'),
                        _nutriRow('الدهون', p.nutriments['fat_100g'], 'غ'),
                        _nutriRow('البروتين', p.nutriments['proteins_100g'], 'غ'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _nutriRow(String label, dynamic value, String unit) {
    final display = value == null ? '—' : '$value $unit';
    return ListTile(
      dense: true,
      title: Text(label),
      trailing: Text(display, style: TextStyle(color: SufraColors.textMuted, fontWeight: FontWeight.w600)),
    );
  }
}
