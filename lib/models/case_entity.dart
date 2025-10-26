class CaseEntity {
  final int? id;
  final String caseNumber; 
  final String title; 
  final String court; 
  final String clientName; 
  final String status; 
  final DateTime? filingDate;
  final DateTime? nextHearingDate;
  final String summary;
  final String? attachments; 

  CaseEntity({
    this.id,
    required this.caseNumber,
    required this.title,
    required this.court,
    required this.clientName,
    required this.status,
    this.filingDate,
    this.nextHearingDate,
    this.summary = '',
    this.attachments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'caseNumber': caseNumber,
      'title': title,
      'court': court,
      'clientName': clientName,
      'status': status,
      'filingDate': filingDate?.toIso8601String(),
      'nextHearingDate': nextHearingDate?.toIso8601String(),
      'summary': summary,
      'attachments': attachments,
    };
  }

  factory CaseEntity.fromMap(Map<String, dynamic> map) {
    return CaseEntity(
      id: map['id'],
      caseNumber: map['caseNumber'],
      title: map['title'],
      court: map['court'],
      clientName: map['clientName'],
      status: map['status'] ?? '',
      filingDate: map['filingDate'] != null
          ? DateTime.parse(map['filingDate'])
          : null,
      nextHearingDate: map['nextHearingDate'] != null
          ? DateTime.parse(map['nextHearingDate'])
          : null,
      summary: map['summary'] ?? '',
      attachments: map['attachments'],
    );
  }
}
