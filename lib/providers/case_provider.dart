import 'package:flutter/foundation.dart';
import '../helpers/database_helper.dart';
import '../models/case_entity.dart';

class CaseProvider with ChangeNotifier {
  List<CaseEntity> _cases = [];
  final db = DatabaseHelper.instance;

  List<CaseEntity> get cases => [..._cases];

  CaseProvider() {
    fetchAndSetCases();
  }

  Future<void> fetchAndSetCases() async {
    final data = await db.queryAllRows(DatabaseHelper.casesTable,
        orderBy: 'id DESC');
    _cases = data.map((m) => CaseEntity.fromMap(m)).toList();
    notifyListeners();
  }

  Future<int> addCase(CaseEntity c) async {
    final id = await db.insert(DatabaseHelper.casesTable, c.toMap());
    await fetchAndSetCases();
    return id;
  }

  Future<int> updateCase(int id, CaseEntity newCase) async {
    final rows = await db.update(DatabaseHelper.casesTable, newCase.toMap(), id);
    await fetchAndSetCases();
    return rows;
  }

  Future<int> deleteCase(int id) async {
    final rows = await db.delete(DatabaseHelper.casesTable, id);
    await fetchAndSetCases();
    return rows;
  }

  // Search by caseNumber or title (simple)
  List<CaseEntity> search(String query) {
    final q = query.toLowerCase();
    return _cases.where((c) =>
      c.caseNumber.toLowerCase().contains(q) ||
      c.title.toLowerCase().contains(q) ||
      c.clientName.toLowerCase().contains(q)
    ).toList();
  }
}
