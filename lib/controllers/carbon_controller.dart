import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/carbon_record.dart';

class CarbonController {
  static final _col = FirebaseFirestore.instance.collection('carbon_records');

  static Stream<QuerySnapshot> stream() => _col.snapshots();

  static Future<void> add(CarbonRecord r) async {
    await _col.add({...r.toMap(), 'createdAt': FieldValue.serverTimestamp()});
  }

  static Future<void> update(CarbonRecord r) async {
    await _col.doc(r.id).update(r.toMap());
  }

  static Future<void> delete(String id) async {
    await _col.doc(id).delete();
  }
}
