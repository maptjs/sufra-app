import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/family_member.dart';
import '../state/family_provider.dart';
import '../theme/colors.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  void _openEditor(BuildContext context, {FamilyMember? existing}) {
    final familyProvider = context.read<FamilyProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: SufraColors.surface(context),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _MemberEditorSheet(
        existing: existing,
        onSaved: (member) => familyProvider.upsert(member),
        onDeleted: existing == null ? null : () => familyProvider.remove(existing.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final members = context.watch<FamilyProvider>().members;

    return Scaffold(
      appBar: AppBar(title: const Text('أفراد الأسرة')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SufraColors.sage,
        onPressed: () => _openEditor(context),
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      body: members.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'أضف أفراد أسرتك وحساسياتهم الغذائية للحصول على تنبيهات مخصصة لكل فرد.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: SufraColors.muted(context)),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: members.length,
              itemBuilder: (context, i) {
                final m = members[i];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: SufraColors.sage.withValues(alpha: 0.3),
                      child: Text(m.name.isNotEmpty ? m.name[0] : '?'),
                    ),
                    title: Text(m.name),
                    subtitle: Text(
                      m.allergyTags.isEmpty ? 'لا توجد حساسيات مسجّلة' : '${m.allergyTags.length} حساسية مسجّلة',
                      style: TextStyle(color: SufraColors.muted(context)),
                    ),
                    trailing: const Icon(Icons.chevron_left_rounded),
                    onTap: () => _openEditor(context, existing: m),
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
            Text('الحساسيات الغذائية', style: TextStyle(color: SufraColors.muted(context))),
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
                  backgroundColor: SufraColors.pageBackground(context),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('مكوّنات أخرى للمتابعة (اختياري)', style: TextStyle(color: SufraColors.muted(context))),
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
