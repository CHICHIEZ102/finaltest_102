import 'package:cloud_firestore/cloud_firestore.dart';

class CarbonRecord {
  String? id;
  String costCenterId;
  String emissionSource;
  String auditorEmail;
  double tco2e;
  double offsetBudget;

  CarbonRecord({
    this.id,
    this.costCenterId = '',
    this.emissionSource = '',
    this.auditorEmail = '',
    this.tco2e = 0,
    this.offsetBudget = 0,
  });

  Map<String, dynamic> toMap() => {
        'costCenterId': costCenterId,
        'emissionSource': emissionSource,
        'auditorEmail': auditorEmail,
        'tco2e': tco2e,
        'offsetBudget': offsetBudget,
      };

  factory CarbonRecord.fromDoc(QueryDocumentSnapshot d) {
    final m = d.data() as Map<String, dynamic>;
    return CarbonRecord(
      id: d.id,
      costCenterId: m['costCenterId'] ?? '',
      emissionSource: m['emissionSource'] ?? '',
      auditorEmail: m['auditorEmail'] ?? '',
      tco2e: (m['tco2e'] ?? 0).toDouble(),
      offsetBudget: (m['offsetBudget'] ?? 0).toDouble(),
    );
  }
}
