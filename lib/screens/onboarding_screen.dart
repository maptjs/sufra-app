import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_member.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  final _nameController = TextEditingController();
  final Set<String> _selectedAllergens = {};
  final List<FamilyMember> _members = [];

  void _addCurrentMember() {
    if (_nameController.text.trim().isEmpty) return;
    _members.add(
      FamilyMember(
        id: const Uuid().v4(),
        name: _nameController.text.trim(),
        allergyTags: _selectedAllergens.map((a) => CommonAllergens.arabicToTag[a]!).toList(),
      ),
    );
    _nameController.clear();
    _selectedAllergens.clear();
  }

  Future<void> _finish() async {
    if (_nameController.text.trim().isNotEmpty) _addCurrentMember();
    final storage = StorageService();
    await storage.saveFamily(_members);
    await storage.setOnboarded(true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SufraColors.background,
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildWelcomePage(),
            _buildFamilyPage(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Image.asset('assets/icon/app_icon.png', width: 130, height: 130),
          ),
          const SizedBox(height: 28),
          Text(
            'أهلاً بك في سُفرة',
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: SufraColors.textDark),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'اِمسح غذاء أسرتك لمعرفة القيمة الغذائية، مسببات الحساسية، ومدى أمانه — فورًا وبكل وضوح.',
            style: TextStyle(fontSize: 16, color: SufraColors.textMuted, height: 1.6),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _pageController.nextPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              ),
              child: const Text('لنبدأ بإعداد عائلتك'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyPage() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'من في أسرتك؟',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: SufraColors.textDark),
          ),
          const SizedBox(height: 6),
          Text(
            'أضف الاسم وأي حساسية غذائية. يمكنك التعديل في أي وقت لاحقًا.',
            style: TextStyle(fontSize: 14, color: SufraColors.textMuted),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(hintText: 'مثال: سارة، أو "أنا"'),
          ),
          const SizedBox(height: 16),
          Text('الحساسيات الشائعة (اختياري):', style: TextStyle(color: SufraColors.textMuted)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CommonAllergens.arabicToTag.keys.map((label) {
              final selected = _selectedAllergens.contains(label);
              return FilterChip(
                label: Text(label),
                selected: selected,
                onSelected: (val) {
                  setState(() {
                    if (val) {
                      _selectedAllergens.add(label);
                    } else {
                      _selectedAllergens.remove(label);
                    }
                  });
                },
                selectedColor: SufraColors.sage.withValues(alpha: 0.25),
                backgroundColor: SufraColors.cream,
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              setState(_addCurrentMember);
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة فرد آخر للأسرة'),
          ),
          const SizedBox(height: 12),
          if (_members.isNotEmpty)
            Wrap(
              spacing: 8,
              children: _members
                  .map((m) => Chip(
                        label: Text(m.name),
                        backgroundColor: SufraColors.terracottaLight.withValues(alpha: 0.3),
                      ))
                  .toList(),
            ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _finish,
              child: const Text('ابدأ استخدام سُفرة'),
            ),
          ),
        ],
      ),
    );
  }
}
