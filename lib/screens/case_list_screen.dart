import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/case_provider.dart';
import '../models/case_entity.dart';
import 'case_edit_screen.dart';
import 'package:intl/intl.dart';

class CaseListScreen extends StatefulWidget {
  const CaseListScreen({super.key});
  @override
  State<CaseListScreen> createState() => _CaseListScreenState();
}

class _CaseListScreenState extends State<CaseListScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CaseProvider>();
    final list = _search.isEmpty ? provider.cases : provider.search(_search);

    return Scaffold(
      appBar: AppBar(
        title: const Text('คดีความ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context)
                .push(MaterialPageRoute(builder: (_) => const CaseEditScreen())),
          )
        ],
      ),
      body: Column(
        children: [
          // 🔍 ช่องค้นหา
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 65, 88, 218),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.indigo),
                  hintText: 'ค้นหา (เลขคดี / ชื่อคดี / ลูกความ)',
                  hintStyle:
                      const TextStyle(color: Color.fromARGB(255, 14, 3, 3)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.indigo.shade50,
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
            ),
          ),

          // 📋 รายการคดี
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('ไม่มีรายการคดี'))
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final CaseEntity c = list[i];
                      return Card(
                        margin:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: ListTile(
                          title: Text('${c.caseNumber} • ${c.title}'),
                          subtitle: Text(
                              '${c.clientName} • ${c.court}\nStatus: ${c.status}'),
                          isThreeLine: true,
                          // ✅ ปรับ trailing ไม่ให้ล้น
                          trailing: SizedBox(
                            height: 60,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  c.nextHearingDate != null
                                      ? DateFormat.yMMMd()
                                          .format(c.nextHearingDate!)
                                      : '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      iconSize: 20,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) => CaseEditScreen(
                                                  caseEntity: c))),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      iconSize: 15,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () async {
                                        final ok = await showDialog<bool>(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('ยืนยัน'),
                                            content: const Text(
                                                'ต้องการลบคดีนี้จริงหรือ?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, false),
                                                child: const Text('ยกเลิก'),
                                              ),
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(ctx, true),
                                                child: const Text('ลบ'),
                                              ),
                                            ],
                                          ),
                                        );
                                        if (ok == true) {
                                          await provider.deleteCase(c.id!);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
