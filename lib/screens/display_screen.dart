import 'package:flutter/material.dart';
import '../controllers/carbon_controller.dart';
import '../model/app_user.dart';
import '../model/carbon_record.dart';
import 'form_screen.dart';

class DisplayScreen extends StatelessWidget {
  final AppUser user;
  const DisplayScreen({super.key, required this.user});

  Future<void> _confirmDelete(BuildContext context, CarbonRecord r) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ยืนยันการลบ'),
        content: Text('ต้องการตัดจำหน่ายรายการ ${r.costCenterId} ใช่หรือไม่?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('ยกเลิก')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('ลบ', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (ok == true) await CarbonController.delete(r.id!);
  }

  void _edit(BuildContext context, CarbonRecord r) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => Scaffold(
          appBar: AppBar(title: const Text('แก้ไขข้อมูล')),
          body: FormScreen(record: r, onSaved: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: CarbonController.stream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('ยังไม่มีข้อมูล'));

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final r = CarbonRecord.fromDoc(docs[i]);
            return ListTile(
              leading: CircleAvatar(
                radius: 28,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: FittedBox(
                    child: Text('${r.tco2e}\ntCO2e',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12)),
                  ),
                ),
              ),
              title: Text(r.costCenterId),
              subtitle: Text(
                  '${r.emissionSource}\nงบชดเชย: ${r.offsetBudget.toStringAsFixed(2)} THB'),
              isThreeLine: true,
              // Operator: ซ่อนปุ่ม Edit/Delete ทั้งหมด
              trailing: user.isAdmin
                  ? Row(mainAxisSize: MainAxisSize.min, children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _edit(context, r),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _confirmDelete(context, r),
                      ),
                    ])
                  : null,
            );
          },
        );
      },
    );
  }
}
