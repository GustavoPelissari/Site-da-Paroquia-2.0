class FormModel {
  final String id;
  final String titulo;
  final String? groupId;
  final bool publico;
  final bool ativo;

  FormModel({
    required this.id,
    required this.titulo,
    this.groupId,
    this.publico = true,
    this.ativo = true,
  });
}

class FormResponseModel {
  final String id;
  final String formId;
  final String userId;
  final String resposta;
  final DateTime createdAt;

  FormResponseModel({
    required this.id,
    required this.formId,
    required this.userId,
    required this.resposta,
    required this.createdAt,
  });
}
