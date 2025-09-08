import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class FabricationReportPage extends StatefulWidget {
  const FabricationReportPage({super.key});

  @override
  State<FabricationReportPage> createState() => _FabricationReportPageState();
}

class _FabricationReportPageState extends State<FabricationReportPage> {
  DateTimeRange? _range;
  List<Map<String, dynamic>> _results = [];

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
    );
    if (picked != null) setState(() => _range = picked);
  }

  Future<void> _generateReport() async {
    if (_range == null) return;

    final startIso = _range!.start.toIso8601String();
    final endIso = _range!.end.toIso8601String();

    final query = await FirebaseFirestore.instance
        .collection('fabrications')
        .where('date', isGreaterThanOrEqualTo: startIso)
        .where('date', isLessThanOrEqualTo: endIso)
        .get();

    _results = query.docs.map((d) {
      final data = d.data();
      return {
        'SN': data['sn'] ?? '',
        'Description': data['description'] ?? '',
        'Date': data['date'] ?? '',
        'Note': data['note'] ?? '',
        'User': data['userEmail'] ?? '',
      };
    }).toList();

    setState(() {});
  }

  List<String> get _headers => ['SN', 'Description', 'Date', 'Note', 'User'];

  Future<void> _exportExcel() async {
    final excel = Excel.createExcel();
    // Remove the default "Sheet1"
    excel.delete('Sheet1');
    final sheet = excel['Fabrications'];

    // Add headers
    sheet.appendRow(_headers.map((h) => TextCellValue(h)).toList());

    // Add data
    for (var row in _results) {
      sheet.appendRow(
        _headers.map((h) => TextCellValue(row[h]?.toString() ?? '')).toList(),
      );
    }

    final bytes = Uint8List.fromList(excel.encode()!);
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/Fabrications.xlsx');
    await file.writeAsBytes(bytes);

    // New SharePlus usage
    await SharePlus.instance.share(
      ShareParams(
        text: 'Here is the Fabrications report',
        files: [XFile(file.path)],
      ),
    );
  }

  // Future<void> _exportExcel() async {
  //   final excel = Excel.createExcel();
  //   final sheet = excel['Fabrications'];

  //   sheet.appendRow(_headers.map((h) => CellValue(h)).toList());

  //   for (var row in _results) {
  //     sheet.appendRow(_headers.map((h) => CellValue(row[h]?.toString() ?? '')).toList());
  //   }

  //   final bytes = Uint8List.fromList(excel.encode()!);
  //   final dir = await getTemporaryDirectory();
  //   final file = File('${dir.path}/fabrications.xlsx');
  //   await file.writeAsBytes(bytes);

  //   await Share.shareXFiles([XFile(file.path)]);
  // }

  Future<void> _exportPdf() async {
    final pdf = pw.Document();

    if (_results.isNotEmpty) {
      final data = _results
          .map((r) => _headers.map((h) => r[h] ?? '').toList())
          .toList();
      pdf.addPage(
        pw.Page(
          build: (context) => pw.Table.fromTextArray(
            headers: _headers,
            data: data,
            border: null,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
          ),
        ),
      );
    }

    final bytes = await pdf.save();
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/fabrications.pdf');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fabrication Report')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _pickDateRange,
              child: const Text('Pick Date Range'),
            ),
            if (_range != null)
              Text(
                  'Selected range: ${_range!.start.toLocal().toString().split(' ')[0]} → ${_range!.end.toLocal().toString().split(' ')[0]}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Generate Report'),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: _results.length,
                itemBuilder: (_, i) {
                  final row = _results[i];
                  return Card(
                    child: ListTile(
                      title: Text(row['Description'] ?? 'Unknown'),
                      subtitle: Text(
                        _headers.map((h) => '$h: ${row[h]}').join(', '),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_results.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                      onPressed: _exportExcel,
                      child: const Text('Export Excel')),
                  ElevatedButton(
                      onPressed: _exportPdf, child: const Text('Export PDF')),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:excel/excel.dart';
// import 'dart:typed_data';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:pdf/pdf.dart';

// class ReportsPage extends StatefulWidget {
//   const ReportsPage({super.key});

//   @override
//   State<ReportsPage> createState() => _ReportsPageState();
// }

// class _ReportsPageState extends State<ReportsPage> {
//   DateTimeRange? _range;
//   String _reportType = 'fabrications'; // or 'deliveries'
//   List<Map<String, dynamic>> _results = [];

//   Future<void> _pickDateRange() async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 5),
//       lastDate: DateTime(now.year + 1),
//     );
//     if (picked != null) setState(() => _range = picked);
//   }

//   Future<void> _generateReport() async {
//     if (_range == null) return;

//     final startIso = _range!.start.toIso8601String();
//     final endIso = _range!.end.toIso8601String();

//     if (_reportType == 'fabrications') {
//       final query = await FirebaseFirestore.instance
//           .collection('fabrications')
//           .where('date', isGreaterThanOrEqualTo: startIso)
//           .where('date', isLessThanOrEqualTo: endIso)
//           .get();

//       _results = query.docs.map((d) {
//         final data = d.data();
//         return {
//           'SN': data['sn'] ?? '',
//           'Description': data['description'] ?? '',
//           'Date': data['date'] ?? '',
//           'Note': data['note'] ?? '',
//           'User': data['userEmail'] ?? '',
//         };
//       }).toList();
//     } else {
//       final query = await FirebaseFirestore.instance
//           .collection('deliveries')
//           .where('date', isGreaterThanOrEqualTo: startIso)
//           .where('date', isLessThanOrEqualTo: endIso)
//           .get();

//       _results = [];
//       for (var doc in query.docs) {
//         final data = doc.data();
//         final client = data['client'] ?? '';
//         final note = data['note'] ?? '';
//         final date = data['date'] ?? '';
//         final productsRaw = data['products'] as List<dynamic>? ?? [];

//         for (var p in productsRaw) {
//           // Ensure p is a Map<String, dynamic>
//           if (p is Map<String, dynamic>) {
//             _results.add({
//               'SN': p['sn'] ?? '',
//               'Description': p['description'] ?? '',
//               'Client': client,
//               'Date': date,
//               'Note': note,
//             });
//           }
//         }
//       }
//     }

//     setState(() {});
//   }

//   List<String> get _headers {
//     if (_reportType == 'fabrications') {
//       return ['SN', 'Description', 'Date', 'Note', 'User'];
//     } else {
//       return ['SN', 'Description', 'Client', 'Date', 'Note'];
//     }
//   }

//   Future<void> _exportExcel() async {
//     final excel = Excel.createExcel();
//     final sheet = excel[_reportType];

//     // Add headers
//     sheet.appendRow(_headers.map((h) => TextCellValue(h)).toList());

//     // Add data
//     for (var row in _results) {
//       sheet.appendRow(
//         _headers.map((h) => TextCellValue(row[h]?.toString() ?? '')).toList(),
//       );
//     }

//     final bytes = Uint8List.fromList(excel.encode()!);
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$_reportType.xlsx');
//     await file.writeAsBytes(bytes);

//     // New SharePlus usage
//     await SharePlus.instance.share(
//       ShareParams(
//         text: 'Here is the $_reportType report',
//         files: [XFile(file.path)],
//       ),
//     );
//   }

//   Future<void> _exportPdf() async {
//     final pdf = pw.Document();

//     if (_results.isNotEmpty) {
//       final data = _results
//           .map((r) => _headers.map((h) => r[h] ?? '').toList())
//           .toList();

//       pdf.addPage(
//         pw.Page(
//           build: (context) => pw.Table.fromTextArray(
//             headers: _headers,
//             data: data,
//             border: null,
//             headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
//             cellAlignment: pw.Alignment.centerLeft,
//             headerDecoration: pw.BoxDecoration(color: PdfColors.grey300),
//           ),
//         ),
//       );
//     }

//     final bytes = await pdf.save();
//     final dir = await getTemporaryDirectory();
//     final file = File('${dir.path}/$_reportType.pdf');
//     await file.writeAsBytes(bytes);

//     await Share.shareXFiles([XFile(file.path)]);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Reports')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             DropdownButton<String>(
//               value: _reportType,
//               items: const [
//                 DropdownMenuItem(
//                   value: 'fabrications',
//                   child: Text('Fabrications'),
//                 ),
//                 DropdownMenuItem(
//                   value: 'deliveries',
//                   child: Text('Deliveries'),
//                 ),
//               ],
//               onChanged: (v) => setState(() => _reportType = v!),
//             ),
//             ElevatedButton(
//               onPressed: _pickDateRange,
//               child: const Text('Pick Date Range'),
//             ),
//             ElevatedButton(
//               onPressed: _generateReport,
//               child: const Text('Generate Report'),
//             ),
//             const SizedBox(height: 12),
//             Expanded(
//               child: ListView.builder(
//                 itemCount: _results.length,
//                 itemBuilder: (_, i) {
//                   final row = _results[i];
//                   return Card(
//                     child: ListTile(
//                       title: Text(row['Description'] ?? 'Unknown'),
//                       subtitle: Text(
//                         _headers.map((h) => '$h: ${row[h]}').join(', '),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//             if (_results.isNotEmpty)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _exportExcel,
//                     child: const Text('Export Excel'),
//                   ),
//                   ElevatedButton(
//                     onPressed: _exportPdf,
//                     child: const Text('Export PDF'),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }
