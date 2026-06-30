import 'package:flutter/material.dart';
import '../models/scanned_product.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import 'result_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScannedProduct> _history = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await StorageService().loadHistory();
    setState(() => _history = history);
  }

  Future<void> _confirmClear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SufraColors.surface(context),
        title: const Text('مسح السجل'),
        content: const Text('سيتم حذف جميع المسحات السابقة من هذا الجهاز. هل تريد الاستمرار؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
        ],
      ),
    );
    if (confirmed == true) {
      await StorageService().clearHistory();
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سجل المسحات'),
        actions: [
          if (_history.isNotEmpty)
            IconButton(icon: const Icon(Icons.delete_outline_rounded), onPressed: _confirmClear),
        ],
      ),
      body: _history.isEmpty
          ? Center(
              child: Text('لا توجد مسحات محفوظة بعد', style: TextStyle(color: SufraColors.muted(context))),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _history.length,
              itemBuilder: (context, i) {
                final p = _history[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: SufraColors.terracottaLight.withValues(alpha: 0.4),
                      backgroundImage: p.imageUrl != null ? NetworkImage(p.imageUrl!) : null,
                      child: p.imageUrl == null ? const Icon(Icons.fastfood_rounded, color: Colors.white) : null,
                    ),
                    title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    subtitle: Text(p.brand, maxLines: 1, overflow: TextOverflow.ellipsis),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => ResultScreen(product: p)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
