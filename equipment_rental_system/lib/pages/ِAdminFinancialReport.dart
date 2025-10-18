import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:equipment_rental_system/api_service.dart';

class AdminFinancialReportPage extends StatefulWidget {
  const AdminFinancialReportPage({super.key});

  @override
  State<AdminFinancialReportPage> createState() => _AdminFinancialReportPageState();
}

class _AdminFinancialReportPageState extends State<AdminFinancialReportPage> {
  final ApiService _api = ApiService();
  bool isLoading = true;

  List<Map<String, dynamic>> _users = [];
  Map<String, dynamic>? _selectedUser;

  List<Map<String, dynamic>> _months = [];
  Map<String, int>? _selectedMonth; // {year, month}

  List<Map<String, dynamic>> _transactions = [];
  Set<DateTime> _transactionDays = <DateTime>{};
  DateTime? _selectedDate;

  // Summaries
  double totalDaily = 0;
  double totalMonthly = 0;
  Map<String, double> dailyBreakdown = {}; // 'yyyy-MM-dd' -> total

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    try {
      final users = await _api.getUsersWithTransactions();
      _users = users.cast<Map<String, dynamic>>();
    } catch (e) {
      _users = [];
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تحميل المستخدمين: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _onSelectUser(Map<String, dynamic> user) async {
    setState(() {
      _selectedUser = user;
      _months = [];
      _selectedMonth = null;
      _transactions = [];
      _transactionDays.clear();
      _selectedDate = null;
      totalDaily = 0;
      totalMonthly = 0;
      dailyBreakdown.clear();
    });
    try {
      final months = await _api.getUserTransactionMonths(user['userId'] ?? user['_id'] ?? user['id']);
      _months = months.cast<Map<String, dynamic>>();
      if (_months.isNotEmpty) {
        final first = _months.first;
        await _onSelectMonth({
          'year': (first['year'] as num).toInt(),
          'month': (first['month'] as num).toInt(),
        });
      } else {
        setState(() {});
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تحميل الشهور: $e')));
    }
  }

  Future<void> _onSelectMonth(Map<String, int> ym) async {
    setState(() {
      _selectedMonth = ym;
      _transactions = [];
      _transactionDays.clear();
      _selectedDate = null;
      totalDaily = 0;
      totalMonthly = 0;
      dailyBreakdown.clear();
    });
    try {
      final userId = _selectedUser!['userId'] ?? _selectedUser!['_id'] ?? _selectedUser!['id'];
      final list = await _api.getTransactionsByMonth(
        userId: userId.toString(),
        year: ym['year']!,
        month: ym['month']!,
      );
      _transactions = list.cast<Map<String, dynamic>>();

      // Parse and compute day totals
      final dateFmt = DateFormat('yyyy-MM-dd');
      for (final t in _transactions) {
        final created = t['createdAt']?.toString();
        if (created != null && created.isNotEmpty) {
          // createdAt from backend is '%Y-%m-%d %H:%M'
          final dayStr = created.substring(0, 10);
          final day = dateFmt.parse(dayStr);
          _transactionDays.add(day);
          final amtStr = t['amount']?.toString() ?? '0';
          final amt = double.tryParse(amtStr.replaceAll(' EGP', '')) ?? 0.0;
          dailyBreakdown[dayStr] = (dailyBreakdown[dayStr] ?? 0) + amt;
          totalMonthly += amt;
        }
      }
      setState(() {});
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('فشل تحميل المعاملات: $e')));
    }
  }

  void _onSelectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      final key = DateFormat('yyyy-MM-dd').format(date);
      totalDaily = dailyBreakdown[key] ?? 0;
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
              if (_selectedUser != null)
                pw.Text('المستخدم: ${_selectedUser!['name'] ?? _selectedUser!['email']}', style: const pw.TextStyle(fontSize: 16)),
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

   // final formatCurrency = NumberFormat.currency(locale: 'ar_EG', symbol: 'ج.م');

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
          : Row(
              children: [
                // Users list
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text('المستخدمون', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _users.length,
                          itemBuilder: (context, index) {
                            final u = _users[index];
                            final isSel = _selectedUser != null && (u['userId'] == _selectedUser!['userId']);
                            return ListTile(
                              title: Text(u['name']?.toString() ?? u['email']?.toString() ?? 'User'),
                              subtitle: Text(u['email']?.toString() ?? ''),
                              selected: isSel,
                              onTap: () => _onSelectUser(u),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // Report panel
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: _selectedUser == null
                        ? const Center(child: Text('اختر مستخدماً لعرض تقريره'))
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text('المستخدم: ${_selectedUser!['name'] ?? _selectedUser!['email']}'),
                                  const Spacer(),
                                  DropdownButton<Map<String, int>>(
                                    hint: const Text('اختر الشهر'),
                                    value: _selectedMonth,
                                    items: _months
                                        .map((m) => DropdownMenuItem(
                                              value: {
                                                'year': (m['year'] as num).toInt(),
                                                'month': (m['month'] as num).toInt(),
                                              },
                                              child: Text('${m['year']}-${m['month'].toString().padLeft(2, '0')} (${m['count']})'),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      if (val != null) _onSelectMonth(val);
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (_selectedMonth != null) _MonthCalendar(
                                year: _selectedMonth!['year']!,
                                month: _selectedMonth!['month']!,
                                markedDays: _transactionDays,
                                onSelect: _onSelectDate,
                              ),
                              const SizedBox(height: 8),
                              Text('إجمالي اليوم: ${formatCurrency.format(totalDaily)}'),
                              Text('إجمالي الشهر: ${formatCurrency.format(totalMonthly)}'),
                              const Divider(),
                              const Text('المعاملات اليومية', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Expanded(
                                child: _selectedDate == null
                                    ? const Center(child: Text('اختر تاريخاً في التقويم'))
                                    : ListView(
                                        children: _transactions
                                            .where((t) => t['createdAt'] != null && t['createdAt'].toString().startsWith(DateFormat('yyyy-MM-dd').format(_selectedDate!)))
                                            .map((t) => ListTile(
                                                  title: Text(t['note']?.toString() ?? ''),
                                                  subtitle: Text(t['createdAt']?.toString() ?? ''),
                                                  trailing: Text(t['amount']?.toString() ?? ''),
                                                ))
                                            .toList(),
                                      ),
                              ),
                            ],
                          ),
                  ),
                )
              ],
            ),
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final int year;
  final int month;
  final Set<DateTime> markedDays;
  final void Function(DateTime) onSelect;

  const _MonthCalendar({
    required this.year,
    required this.month,
    required this.markedDays,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final first = DateTime(year, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    final weekdayOffset = first.weekday % 7; // Sunday=0 in Grid

    final items = <Widget>[];
    // Headers Sun..Sat
    const headers = ['أح', 'إث', 'ثل', 'أر', 'خم', 'جم', 'سب'];
    items.addAll(headers.map((h) => Center(child: Text(h, style: const TextStyle(fontWeight: FontWeight.bold)))));

    // Empty leading
    for (int i = 0; i < weekdayOffset; i++) {
      items.add(const SizedBox());
    }
    // Days
    for (int d = 1; d <= daysInMonth; d++) {
      final date = DateTime(year, month, d);
      final hasTx = markedDays.any((md) => md.year == date.year && md.month == date.month && md.day == date.day);
      items.add(GestureDetector(
        onTap: () => onSelect(date),
        child: Container(
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: hasTx ? Colors.green.withOpacity(0.2) : Colors.transparent,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(child: Text('$d')),
        ),
      ));
    }

    // Build grid with 7 columns, including headers
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الشهر: $year-${month.toString().padLeft(2, '0')}'),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 7,
          childAspectRatio: 1.4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: items,
        ),
      ],
    );
  }
}