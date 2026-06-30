import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/storage_service.dart';
import '../state/family_provider.dart';
import '../state/settings_provider.dart';
import '../theme/colors.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmClearData(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SufraColors.surface(context),
        title: const Text('حذف جميع البيانات'),
        content: const Text(
          'سيتم حذف أفراد الأسرة، سجل المسحات، وكل الإعدادات من هذا الجهاز نهائيًا. هل أنت متأكد؟',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف الكل', style: TextStyle(color: SufraColors.danger)),
          ),
        ],
      ),
    );

    if (confirmed != true || !context.mounted) return;

    await StorageService().clearEverything();
    if (!context.mounted) return;
    await context.read<FamilyProvider>().load();
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
        children: [
          _SectionLabel('المظهر'),
          Card(
            child: SwitchListTile(
              title: const Text('الوضع الداكن'),
              subtitle: Text('مناسب للاستخدام في الإضاءة المنخفضة', style: TextStyle(color: SufraColors.muted(context))),
              value: settings.darkMode,
              onChanged: (v) => settings.setDarkMode(v),
              activeColor: SufraColors.sage,
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('الصوت'),
          Card(
            child: SwitchListTile(
              title: const Text('أصوات التطبيق'),
              subtitle: Text('نغمات المسح والتنبيهات', style: TextStyle(color: SufraColors.muted(context))),
              value: settings.soundEnabled,
              onChanged: (v) => settings.setSoundEnabled(v),
              activeColor: SufraColors.sage,
            ),
          ),
          const SizedBox(height: 20),
          _SectionLabel('عن التطبيق'),
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('الإصدار'),
                  trailing: Text('1.0.0'),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('بيانات المنتجات من Open Food Facts'),
                  subtitle: Text(
                    'قاعدة بيانات غذائية مفتوحة ومجانية يساهم فيها مستخدمون حول العالم',
                    style: TextStyle(color: SufraColors.muted(context)),
                  ),
                  trailing: const Icon(Icons.open_in_new_rounded, size: 18),
                  onTap: () => launchUrl(
                    Uri.parse('https://world.openfoodfacts.org'),
                    mode: LaunchMode.externalApplication,
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  title: const Text('خصوصيتك'),
                  subtitle: Text(
                    'بيانات أسرتك وسجل مسحاتك تبقى على هاتفك فقط، ولا تُرفع إلى أي خادم.',
                    style: TextStyle(color: SufraColors.muted(context)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () => _confirmClearData(context),
              icon: Icon(Icons.delete_forever_rounded, color: SufraColors.danger),
              label: Text('حذف جميع البيانات', style: TextStyle(color: SufraColors.danger)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4, bottom: 8),
      child: Text(
        text,
        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: SufraColors.muted(context)),
      ),
    );
  }
}
