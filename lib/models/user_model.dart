class UserModel {
  final String id;
  final String nome;
  final String email;
  int nivelAcesso; // 0 a 3

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.nivelAcesso,
  });
}