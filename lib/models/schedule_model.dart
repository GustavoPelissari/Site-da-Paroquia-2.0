class ScheduleModel {
  final String id;
  final String groupId;
  final String pdfLabel;
  final DateTime dataUpload;

  ScheduleModel({
    required this.id,
    required this.groupId,
    required this.pdfLabel,
    required this.dataUpload,
  });
}