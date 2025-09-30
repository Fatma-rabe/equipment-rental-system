import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;

class AdminFinancialReportPage extends StatefulWidget {
  const AdminFinancialReportPage({super.key});

  @override
  State<AdminFinancialReportPage> createState() => _AdminFinancialReportPageState();
}

class _AdminFinancialReportPageState extends State<AdminFinancialReportPage> {
  Map<String, Map<String, dynamic>> userReports = {};
  double totalDaily = 0;
  double totalMonthly = 0;
  bool isLoading = true;
  Map<String, double> dailyBreakdown = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    // Placeholder: simulate loading no data without Firebase
    await Future.delayed(const Duration(milliseconds: 200));
    setState(() {
      userReports = {};
      totalDaily = 0;
      totalMonthly = 0;
      dailyBreakdown = {};
      isLoading = false;
    });
  }

  bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
  bool isSameMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }

  Future<void> exportPdf() async {
    final pdf = pw.Document();
    pw.Font? font;
    try {
      font = pw.Font.ttf(await rootBundle.load('assets/fonts/Cairo-Regular.ttf'));
    } catch (_) {
      font = null;
    }

    final formatCurrency = NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م');

    pdf.addPage(
      pw.Page(
        theme: font != null ? pw.ThemeData.withFont(base: font) : null,
        build: (context) => pw.Directionality(
          textDirection: pw.TextDirection.rtl,
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('التقرير المالي', style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 16),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      for (var header in [
                        'user',
                        'equipment rental',
                        'item request',
                        'worker request',
                        'maintenance',
                        'total'
                      ])
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            header,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        )
                    ],
                  ),
                  ...userReports.entries.map((entry) {
                    final data = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(data['name']),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(formatCurrency.format(data['equipment'])),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(formatCurrency.format(data['items'])),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(formatCurrency.format(data['workers'])),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(formatCurrency.format(data['maintenance'])),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(formatCurrency.format(data['total'])),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('التفاصيل اليومية:', style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 8),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('التاريخ'),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text('الإجمالي'),
                      ),
                    ],
                  ),
                  ...dailyBreakdown.entries.map((entry) {
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(entry.key),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(formatCurrency.format(entry.value)),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
              pw.SizedBox(height: 16),
              pw.Text('إجمالي اليوم: ${formatCurrency.format(totalDaily)}'),
              pw.Text('إجمالي الشهر: ${formatCurrency.format(totalMonthly)}'),
            ],
          ),
        ),
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م');

    return Scaffold(
      appBar: AppBar(
        title: const Text('التقرير المالي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: exportPdf,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('المستخدم')),
                  DataColumn(label: Text('تأجير معدات')),
                  DataColumn(label: Text('طلبات مخزن')),
                  DataColumn(label: Text('طلبات عمال')),
                  DataColumn(label: Text('صيانة')),
                  DataColumn(label: Text('الإجمالي')),
                ],
                rows: userReports.entries.map((entry) {
                  final data = entry.value;
                  return DataRow(cells: [
                    DataCell(Text(data['name'])),
                    DataCell(Text(formatCurrency.format(data['equipment']))),
                    DataCell(Text(formatCurrency.format(data['items']))),
                    DataCell(Text(formatCurrency.format(data['workers']))),
                    DataCell(Text(formatCurrency.format(data['maintenance']))),
                    DataCell(Text(formatCurrency.format(data['total']))),
                  ]);
                }).toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Text('إجمالي اليوم: ${formatCurrency.format(totalDaily)}'),
                const SizedBox(height: 4),
                Text('إجمالي الشهر: ${formatCurrency.format(totalMonthly)}'),
                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),
                const Text('التفاصيل اليومية:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                ...dailyBreakdown.entries.map((e) => Text('${e.key} : ${formatCurrency.format(e.value)}')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}