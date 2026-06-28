import 'package:flutter/material.dart';
import '../models/scanned_product.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import 'scan_screen.dart';
import 'history_screen.dart';
import 'family_screen.dart';
import 'result_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeTab(),
      const HistoryScreen(),
      const FamilyScreen(),
    ];

    return Scaffold(
      body: pages[_tab],
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: SufraColors.terracotta,
        shape: const CircleBorder(),
        onPressed: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ScanScreen()),
          );
          if (result != null && result is ScannedProduct && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ResultScreen(product: result)),
            );
          }
        },
        child: const Icon(Icons.qr_code_scanner_rounded, size: 32, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: SufraColors.cream,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navButton(Icons.home_rounded, 'الرئيسية', 0),
            _navButton(Icons.history_rounded, 'السجل', 1),
            const SizedBox(width: 48),
            _navButton(Icons.family_restroom_rounded, 'الأسرة', 2),
          ],
        ),
      ),
    );
  }

  Widget _navButton(IconData icon, String label, int index) {
    final selected = _tab == index;
    final color = selected ? SufraColors.terracotta : SufraColors.textMuted;
    return InkWell(
      onTap: () => setState(() => _tab = index),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  const _HomeTab();

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  List<ScannedProduct> _recent = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await StorageService().loadHistory();
    setState(() => _recent = history.take(5).toList());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('سُفرة',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: SufraColors.textDark)),
                    Text('وجبات أسرتك، بثقة', style: TextStyle(fontSize: 13, color: SufraColors.textMuted)),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.asset('assets/icon/app_icon.png', width: 48, height: 48),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: SufraColors.sage.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner_rounded, color: SufraColors.sageDark, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'اضغط على زر المسح في الأسفل لفحص أي منتج غذائي بالباركود',
                      style: TextStyle(color: SufraColors.textDark, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('أحدث المسحات', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: SufraColors.textDark)),
            const SizedBox(height: 12),
            if (_recent.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text('لا توجد مسحات بعد — جرّب مسح أول منتج!', style: TextStyle(color: SufraColors.textMuted)),
              )
            else
              ..._recent.map((p) => Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                  )),
          ],
        ),
      ),
    );
  }
}
