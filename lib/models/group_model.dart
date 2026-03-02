class GroupModel {
  final String id;
  final String nome;
  final String descricao;
  final String? coordenadorUserId;
  final bool permitePdfUpload;
  final bool permiteFormularios;
  final bool permiteNoticias;
  final bool permiteEventos;

  GroupModel({
    required this.id,
    required this.nome,
    required this.descricao,
    this.coordenadorUserId,
    this.permitePdfUpload = true,
    this.permiteFormularios = true,
    this.permiteNoticias = true,
    this.permiteEventos = true,
  });
}
