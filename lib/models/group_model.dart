class GroupModel {
  final String id;
  final String nome;
  final String descricao;
  final String? responsavel;
  final String? horarioEncontros;
  final String? localEncontro;
  final String? imagemUrl;
  final String? contato;
  final String? whatsappLink;
  final String? coordenadorUserId;
  final bool permitePdfUpload;
  final bool permiteFormularios;
  final bool permiteNoticias;
  final bool permiteEventos;

  GroupModel({
    required this.id,
    required this.nome,
    required this.descricao,
    this.responsavel,
    this.horarioEncontros,
    this.localEncontro,
    this.imagemUrl,
    this.contato,
    this.whatsappLink,
    this.coordenadorUserId,
    this.permitePdfUpload = true,
    this.permiteFormularios = true,
    this.permiteNoticias = true,
    this.permiteEventos = true,
  });
}
