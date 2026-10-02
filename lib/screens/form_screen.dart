import 'package:flutter/material.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../controllers/carbon_controller.dart';
import '../model/carbon_record.dart';

/// ใช้ทั้งหน้าบันทึกใหม่ (record == null) และหน้าแก้ไข (record != null, Admin เท่านั้น)
class FormScreen extends StatefulWidget {
  final CarbonRecord? record;
  final VoidCallback? onSaved;
  const FormScreen({super.key, this.record, this.onSaved});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final CarbonRecord _data;
  late final TextEditingController _cc, _src, _email, _tco2e, _budget;
  bool _saving = false;

  bool get _isEdit => widget.record != null;

  @override
  void initState() {
    super.initState();
    _data = widget.record ?? CarbonRecord();
    String n(double v) => v == 0 ? '' : v.toString();
    _cc = TextEditingController(text: _data.costCenterId);
    _src = TextEditingController(text: _data.emissionSource);
    _email = TextEditingController(text: _data.auditorEmail);
    _tco2e = TextEditingController(text: n(_data.tco2e));
    _budget = TextEditingController(text: n(_data.offsetBudget));
  }

  String? _numValidator(String? v) {
    if (v == null || v.trim().isEmpty) return 'กรุณากรอกตัวเลข';
    final x = double.tryParse(v.trim());
    if (x == null) return 'ต้องเป็นตัวเลขเท่านั้น';
    if (x < 0) return 'ต้องไม่ติดลบ';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    _data
      ..costCenterId = _cc.text.trim()
      ..emissionSource = _src.text.trim()
      ..auditorEmail = _email.text.trim()
      ..tco2e = double.parse(_tco2e.text.trim())
      ..offsetBudget = double.parse(_budget.text.trim());

    setState(() => _saving = true);
    try {
      if (_isEdit) {
        await CarbonController.update(_data);
      } else {
        await CarbonController.add(_data);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEdit ? 'แก้ไขข้อมูลแล้ว' : 'บันทึกข้อมูลแล้ว')));
      if (!_isEdit) {
        _formKey.currentState!.reset();
        for (final c in [_cc, _src, _email, _tco2e, _budget]) {
          c.clear();
        }
      }
      widget.onSaved?.call();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
      labelText: label, hintText: hint, border: const OutlineInputBorder());

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 14);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(children: [
          TextFormField(
            controller: _cc,
            decoration: _dec('รหัสศูนย์ต้นทุน / แผนก (Cost Center ID)', 'เช่น CC-ENG-04'),
            validator: RequiredValidator(errorText: 'กรุณากรอกรหัสศูนย์ต้นทุน').call,
          ),
          gap,
          TextFormField(
            controller: _src,
            decoration: _dec('แหล่งกำเนิดการปล่อย', 'เช่น การใช้ไฟฟ้า, ยานพาหนะ, ขนส่ง'),
            validator: RequiredValidator(errorText: 'กรุณากรอกแหล่งกำเนิดการปล่อย').call,
          ),
          gap,
          TextFormField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            decoration: _dec('อีเมลเจ้าหน้าที่ตรวจสอบ (Auditor Email)', 'name@company.co.th'),
            validator: MultiValidator([
              RequiredValidator(errorText: 'กรุณากรอกอีเมล'),
              EmailValidator(errorText: 'รูปแบบอีเมลไม่ถูกต้อง'),
            ]).call,
          ),
          gap,
          TextFormField(
            controller: _tco2e,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('ปริมาณการปล่อย (tCO2e)', 'เช่น 12.5'),
            validator: _numValidator,
          ),
          gap,
          TextFormField(
            controller: _budget,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: _dec('งบประมาณชดเชย (THB)', 'เช่น 50000'),
            validator: _numValidator,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.save),
              label: Text(_isEdit ? 'บันทึกการแก้ไข' : 'บันทึกข้อมูล'),
            ),
          ),
        ]),
      ),
    );
  }
}
