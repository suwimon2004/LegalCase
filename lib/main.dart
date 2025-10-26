import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/case_provider.dart';
import 'screens/case_list_screen.dart';

void main() {
  runApp(const CaseManagerApp());
}

class CaseManagerApp extends StatelessWidget {
  const CaseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CaseProvider(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Case Manager',
        theme: ThemeData(primarySwatch: Colors.indigo),
        home: const CaseListScreen(),
      ),
    );
  }
}
