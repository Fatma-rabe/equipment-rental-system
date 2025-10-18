import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:equipment_rental_system/api_service.dart';

class EquipmentRentalRequestPage extends StatefulWidget {
  final String equipmentId;
  final Map<String, dynamic> equipmentData;

  const EquipmentRentalRequestPage({
    Key? key,
    required this.equipmentId,
    required this.equipmentData,
  }) : super(key: key);

  @override
  State<EquipmentRentalRequestPage> createState() => _EquipmentRentalRequestPageState();
}

class _EquipmentRentalRequestPageState extends State<EquipmentRentalRequestPage> {
  String _selectedUnit = 'ساعة';
  int _quantity = 0; // fallback if user chooses manual quantity
  double _totalPrice = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _submitting = false;

  final TextEditingController _quantityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_calculateTotal);
  }

  void _calculateTotal() {
    final pricePerUnit = double.tryParse(widget.equipmentData['price'].toString()) ?? 0.0;
    int qty = int.tryParse(_quantityController.text) ?? 0;
    // If date range selected and unit is hour, derive hours; for meter keep manual qty
    if (_selectedUnit == 'ساعة' && _startDate != null && _endDate != null) {
      final hours = _endDate!.difference(_startDate!).inHours;
      if (hours > 0) qty = hours;
    }
    setState(() {
      _quantity = qty;
      _totalPrice = qty * pricePerUnit;
    });
  }

  Future<void> _sendRentalRequest() async {
    if (_selectedUnit == 'ساعة' && (_startDate == null || _endDate == null)) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار فترة التأجير.')));
      return;
    }
    if (_quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكمية غير صحيحة')));
      return;
    }
    setState(() => _submitting = true);
    try {
      final api = ApiService();
      final rentalMethod = _selectedUnit == 'ساعة' ? 'hour' : 'meter';
      await api.requestEquipment(
        equipmentId: widget.equipmentId,
        volume: _quantity,
        rentalMethod: rentalMethod,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلب الإيجار بنجاح')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل إرسال الطلب: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.equipmentData['price'];
    final df = DateFormat('yyyy-MM-dd HH:mm');

    return Scaffold(
      appBar: AppBar(title: Text('طلب تأجير ${widget.equipmentData['name']}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate ?? now,
                        firstDate: now,
                        lastDate: now.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setState(() => _startDate = DateTime(picked.year, picked.month, picked.day, now.hour, 0));
                        _calculateTotal();
                      }
                    },
                    child: Text(_startDate == null ? 'اختر تاريخ البداية' : 'البداية: ${df.format(_startDate!)}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final base = _startDate ?? DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? base.add(const Duration(days: 1)),
                        firstDate: base,
                        lastDate: base.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        // Use end-of-day default 23:59 to cover whole day
                        setState(() => _endDate = DateTime(picked.year, picked.month, picked.day, 23, 59));
                        _calculateTotal();
                      }
                    },
                    child: Text(_endDate == null ? 'اختر تاريخ النهاية' : 'النهاية: ${df.format(_endDate!)}'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedUnit,
              items: ['ساعة', 'متر'].map((unit) {
                return DropdownMenuItem(value: unit, child: Text(unit));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedUnit = value!;
                });
                _calculateTotal();
              },
              decoration: InputDecoration(labelText: 'الوحدة'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'الكمية ($_selectedUnit)'),
              onChanged: (_) => _calculateTotal(),
            ),
            SizedBox(height: 16),
            Text('سعر الوحدة: $price ج.م'),
            SizedBox(height: 8),
            Text('الإجمالي: ${_totalPrice.toStringAsFixed(2)} ج.م', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Spacer(),
            ElevatedButton.icon(
              onPressed: _submitting ? null : _sendRentalRequest,
              icon: Icon(Icons.send),
              label: _submitting ? const Text('جارٍ الإرسال...') : const Text('إرسال الطلب'),
            ),
          ],
        ),
      ),
    );
  }
}
