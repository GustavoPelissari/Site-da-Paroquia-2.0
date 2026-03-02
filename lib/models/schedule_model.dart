class ScheduleModel {
  final String id;
  final String groupId;
  final String pdfLabel;
  final String pdfUrl;
  final String? descricao;
  final DateTime dataUpload;

  ScheduleModel({
    required this.id,
    required this.groupId,
    required this.pdfLabel,
    required this.pdfUrl,
    this.descricao,
    required this.dataUpload,
  });
}
