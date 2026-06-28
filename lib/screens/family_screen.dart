import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/family_member.dart';
import '../services/storage_service.dart';
import '../theme/colors.dart';

class FamilyScreen extends StatefulWidget {
  const FamilyScreen({super.key});

  @override
  State<FamilyScreen> createState() => _FamilyScreenState();
}

class _FamilyScreenState extends State<FamilyScreen> {
  List<FamilyMember> _members = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final members = await StorageService().loadFamily();
    setState(() => _members = members);
  }

  Future<void> _save() async {
    await StorageService().saveFamily(_members);
  }

  void _openEditor({FamilyMember? existing}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SufraColors.cream,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MemberEditorSheet(
        existing: existing,
        onSaved: (member) async {
          setState(() {
            if (existing != null) {
              final idx = _members.indexWhere((m) => m.id == existing.id);
              _members[idx] = member;
            } else {
              _members.add(member);
            }
          });
          await _save();
        },
        onDeleted: existing == null
            ? null
            : () async {
                setState(() => _members.removeWhere((m) => m.id == existing.id));
                await _save();
              },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('أفراد الأسرة')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SufraColors.sage,
        onPressed: () => _openEditor(),
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      body: _members.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'أضف أفراد أسرتك وحساسياتهم الغذائية للحصول على تنبيهات مخصصة لكل فرد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SufraColors.textMuted),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _members.length,
              itemBuilder: (context, i) {
                final m = _members[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: SufraColors.sage.withValues(alpha: 0.3),
                      child: Text(m.name.isNotEmpty ? m.name[0] : '?'),
                    ),
                    title: Text(m.name),
                    subtitle: Text(
                      m.allergyTags.isEmpty ? 'لا توجد حساسيات مسجّلة' : '${m.allergyTags.length} حساسية مسجّلة',
                      style: TextStyle(color: SufraColors.textMuted),
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => _openEditor(existing: m),
                  ),
                );
              },
            ),
    );
  }
}

class _MemberEditorSheet extends StatefulWidget {
  final FamilyMember? existing;
  final void Function(FamilyMember) onSaved;
  final Future<void> Function()? onDeleted;

  const _MemberEditorSheet({this.existing, required this.onSaved, this.onDeleted});

  @override
  State<_MemberEditorSheet> createState() => _MemberEditorSheetState();
}

class _MemberEditorSheetState extends State<_MemberEditorSheet> {
  late TextEditingController _nameController;
  late TextEditingController _watchController;
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existing?.name ?? '');
    _watchController = TextEditingController(text: widget.existing?.watchIngredients.join('، ') ?? '');
    _selected = widget.existing == null
        ? {}
        : CommonAllergens.arabicToTag.entries
            .where((e) => widget.existing!.allergyTags.contains(e.value))
            .map((e) => e.key)
            .toSet();
  }

  void _save() {
    if (_nameController.text.trim().isEmpty) return;
    final member = FamilyMember(
      id: widget.existing?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      allergyTags: _selected.map((a) => CommonAllergens.arabicToTag[a]!).toList(),
      watchIngredients: _watchController.text
          .split('،')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
    );
    widget.onSaved(member);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.existing == null ? 'إضافة فرد جديد' : 'تعديل بيانات الفرد',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم'),
            ),
            const SizedBox(height: 16),
            Text('الحساسيات الغذائية', style: TextStyle(color: SufraColors.textMuted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: CommonAllergens.arabicToTag.keys.map((label) {
                final selected = _selected.contains(label);
                return FilterChip(
                  label: Text(label),
                  selected: selected,
                  onSelected: (val) => setState(() {
                    if (val) {
                      _selected.add(label);
                    } else {
                      _selected.remove(label);
                    }
                  }),
                  selectedColor: SufraColors.sage.withValues(alpha: 0.25),
                  backgroundColor: SufraColors.background,
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('مكوّنات أخرى للمتابعة (اختياري)', style: TextStyle(color: SufraColors.textMuted)),
            const SizedBox(height: 8),
            TextField(
              controller: _watchController,
              decoration: const InputDecoration(hintText: 'مثال: سكر، ألوان صناعية — مفصولة بفاصلة'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(onPressed: _save, child: const Text('حفظ')),
                ),
                if (widget.onDeleted != null) ...[
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: () async {
                      await widget.onDeleted!.call();
                      if (context.mounted) Navigator.pop(context);
                    },
                    icon: Icon(Icons.delete_outline_rounded, color: SufraColors.danger),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
