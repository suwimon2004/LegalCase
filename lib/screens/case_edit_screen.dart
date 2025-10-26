import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_entity.dart';
import '../providers/case_provider.dart';
import 'package:intl/intl.dart';

class CaseEditScreen extends StatefulWidget {
  final CaseEntity? caseEntity;
  const CaseEditScreen({this.caseEntity, super.key});

  @override
  State<CaseEditScreen> createState() => _CaseEditScreenState();
}

class _CaseEditScreenState extends State<CaseEditScreen> {
  final _form = GlobalKey<FormState>();
  late TextEditingController _caseNumberC;
  late TextEditingController _titleC;
  late TextEditingController _courtC;
  late TextEditingController _clientC;
  late TextEditingController _statusC;
  late TextEditingController _summaryC;
  DateTime? _nextHearing;

  // รายการสถานะ
  final List<String> statuses = [
    'กำลังดำเนินการ',
    'ชนะคดี',
    'แพ้คดี',
    'ยกเลิก',
  ];

  // Map ของศาลตามประเภทและระดับ
  final Map<String, List<String>> courtHierarchy = {
    'ศาลยุติธรรม (Judiciary Courts)': [
      'ชั้นต้น (ศาลชั้นต้น)',
      'ศาลอุทธรณ์ (Court of Appeal)',
      'ศาลฎีกา (Supreme Court)',
    ],
    'ศาลปกครอง (Administrative Courts)': [
      'ศาลปกครองชั้นต้น',
      'ศาลปกครองสูงสุด',
    ],
    'ศาลรัฐธรรมนูญ (Constitutional Court)': [
      'ศาลรัฐธรรมนูญ',
    ],
    'ศาลทหาร (Military Courts)': [
      'ศาลทหารกรุงเทพ',
      'ศาลทหารภูมิภาค',
      'ศาลทหารสูงสุด',
    ],
  };

  // รายละเอียดศาลยุติธรรม
  final Map<String, List<String>> judiciaryCourtLevelDetails = {
    'ชั้นต้น (ศาลชั้นต้น)': [
      'ศาลจังหวัด (Provincial Court)',
      'ศาลแขวง (District Court)',
      'ศาลเยาวชนและครอบครัวจังหวัด (Juvenile and Family Court)',
      'ศาลอาญา (Criminal Court)',
      'ศาลแพ่ง (Civil Court)',
      'ศาลอาญากรุงเทพใต้ / ศาลแพ่งกรุงเทพใต้',
      'ศาลอาญาธนบุรี / ศาลแพ่งธนบุรี',
      'ศาลทรัพย์สินทางปัญญาและการค้าระหว่างประเทศกลาง',
      'ศาลแรงงานกลาง และศาลแรงงานภูมิภาค',
      'ศาลภาษีอากรกลาง',
    ],
    'ศาลอุทธรณ์ (Court of Appeal)': [
      'ศาลอุทธรณ์ภาค 1 – 9',
      'ศาลอุทธรณ์คดีชำนัญพิเศษ',
      'ศาลอุทธรณ์คดีแรงงาน',
      'ศาลอุทธรณ์คดีภาษีอากร',
      'ศาลอุทธรณ์คดีทรัพย์สินทางปัญญาและการค้าระหว่างประเทศ',
      'ศาลอุทธรณ์คดีเยาวชนและครอบครัว',
    ],
    'ศาลฎีกา (Supreme Court)': [
      'แผนกคดีอาญาของผู้ดำรงตำแหน่งทางการเมือง',
      'แผนกคดีแรงงาน',
      'แผนกคดีภาษีอากร',
      'แผนกคดีทรัพย์สินทางปัญญา',
      'แผนกคดีเยาวชนและครอบครัว',
    ],
  };

  @override
  void initState() {
    super.initState();
    final c = widget.caseEntity;
    _caseNumberC = TextEditingController(text: c?.caseNumber ?? '');
    _titleC = TextEditingController(text: c?.title ?? '');
    _courtC = TextEditingController(text: c?.court ?? '');
    _clientC = TextEditingController(text: c?.clientName ?? '');
    _statusC = TextEditingController(text: c?.status ?? statuses[0]);
    _summaryC = TextEditingController(text: c?.summary ?? '');
    _nextHearing = c?.nextHearingDate;
  }

  @override
  void dispose() {
    _caseNumberC.dispose();
    _titleC.dispose();
    _courtC.dispose();
    _clientC.dispose();
    _statusC.dispose();
    _summaryC.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _nextHearing ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (picked != null) setState(() => _nextHearing = picked);
  }

  Future<void> _selectCourt() async {
    // เลือกประเภทศาล
    final selectedType = await showDialog<String>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: const Text('เลือกประเภทศาล'),
          children: courtHierarchy.keys.map((type) {
            return SimpleDialogOption(
              onPressed: () => Navigator.pop(context, type),
              child: Text(type),
            );
          }).toList(),
        );
      },
    );

    if (selectedType != null) {
      List<String> options = courtHierarchy[selectedType]!;

      // สำหรับศาลยุติธรรม ให้เลือกชั้นและรายละเอียด
      if (selectedType == 'ศาลยุติธรรม (Judiciary Courts)') {
        final selectedLevel = await showDialog<String>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: const Text('เลือกชั้นของศาล'),
              children: options.map((level) {
                return SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, level),
                  child: Text(level),
                );
              }).toList(),
            );
          },
        );

        if (selectedLevel != null &&
            judiciaryCourtLevelDetails.containsKey(selectedLevel)) {
          final selectedDetail = await showDialog<String>(
            context: context,
            builder: (context) {
              return SimpleDialog(
                title: const Text('เลือกศาล'),
                children: judiciaryCourtLevelDetails[selectedLevel]!
                    .map((detail) {
                  return SimpleDialogOption(
                    onPressed: () => Navigator.pop(context, detail),
                    child: Text(detail),
                  );
                }).toList(),
              );
            },
          );

          if (selectedDetail != null) {
            setState(() {
              _courtC.text = selectedDetail;
            });
          }
        }
      } else {
        // สำหรับประเภทอื่นๆ เลือกตรงๆ
        final selectedCourt = await showDialog<String>(
          context: context,
          builder: (context) {
            return SimpleDialog(
              title: Text('เลือกศาล $selectedType'),
              children: options.map((opt) {
                return SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, opt),
                  child: Text(opt),
                );
              }).toList(),
            );
          },
        );

        if (selectedCourt != null) {
          setState(() {
            _courtC.text = selectedCourt;
          });
        }
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final provider = context.read<CaseProvider>();
    final newCase = CaseEntity(
      id: widget.caseEntity?.id,
      caseNumber: _caseNumberC.text.trim(),
      title: _titleC.text.trim(),
      court: _courtC.text.trim(),
      clientName: _clientC.text.trim(),
      status: _statusC.text.trim(),
      nextHearingDate: _nextHearing,
      filingDate: widget.caseEntity?.filingDate ?? DateTime.now(),
      summary: _summaryC.text.trim(),
    );
    if (widget.caseEntity == null) {
      await provider.addCase(newCase);
    } else {
      await provider.updateCase(widget.caseEntity!.id!, newCase);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.caseEntity == null ? 'เพิ่มคดี' : 'แก้ไขคดี'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: _caseNumberC,
                decoration: const InputDecoration(labelText: 'หมายเลขคดี'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'กรุณากรอกหมายเลขคดี'
                    : null,
              ),
              TextFormField(
                controller: _titleC,
                decoration: const InputDecoration(labelText: 'ชื่อคดี'),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'กรุณากรอกชื่อคดี'
                    : null,
              ),
              TextFormField(
                controller: _clientC,
                decoration: const InputDecoration(labelText: 'ลูกความ'),
              ),
              
              // ศาล แบบ Multi-Level
              TextFormField(
                controller: _courtC,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'ศาล',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.arrow_drop_down),
                    onPressed: _selectCourt,
                  ),
                ),
              ),
              // สถานะ Dropdown
              DropdownButtonFormField<String>(
                value: _statusC.text.isNotEmpty ? _statusC.text : statuses[0],
                decoration: const InputDecoration(labelText: 'สถานะ'),
                items: statuses
                    .map((status) => DropdownMenuItem(
                          value: status,
                          child: Text(status),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _statusC.text = val);
                },
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'กรุณาเลือกสถานะ' : null,
              ),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('วันนัดถัดไป'),
                subtitle: Text(_nextHearing != null
                    ? DateFormat.yMMMEd().format(_nextHearing!)
                    : 'ไม่ได้ระบุ'),
                trailing: TextButton(
                    onPressed: _pickDate, child: const Text('เลือกวัน')),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _save, child: const Text('บันทึก')),
            ],
          ),
        ),
      ),
    );
  }
}
