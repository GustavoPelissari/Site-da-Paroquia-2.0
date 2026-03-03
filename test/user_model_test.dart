import 'package:flutter_test/flutter_test.dart';
import 'package:paroquia_mvp/models/access_control_model.dart';
import 'package:paroquia_mvp/models/user_model.dart';

void main() {
  group('UserModel role mapping', () {
    test('nivel 0 vira usuario padrao', () {
      final user = UserModel(
        id: '1',
        nome: 'Usuario',
        email: 'usuario@paroquia.local',
        nivelAcesso: 0,
      );

      expect(user.role, AppRole.usuarioPadrao);
      expect(user.roleLabel, 'Usuario padrao');
      expect(user.capabilities.contains(AppCapability.manageUsersHierarchy), false);
    });

    test('nivel 2 vira coordenador com permissoes de criacao', () {
      final user = UserModel(
        id: '2',
        nome: 'Coord',
        email: 'coord@paroquia.local',
        nivelAcesso: 2,
      );

      expect(user.role, AppRole.coordenador);
      expect(user.capabilities.contains(AppCapability.createNews), true);
      expect(user.capabilities.contains(AppCapability.createEvents), true);
      expect(user.capabilities.contains(AppCapability.manageUsersHierarchy), false);
    });

    test('nivel 3 vira administrativo com permissao de gerenciar usuarios', () {
      final user = UserModel(
        id: '3',
        nome: 'Admin',
        email: 'admin@paroquia.local',
        nivelAcesso: 3,
      );

      expect(user.role, AppRole.administrativo);
      expect(user.capabilities.contains(AppCapability.manageUsersHierarchy), true);
      expect(user.capabilities.contains(AppCapability.manageMassSchedules), true);
    });
  });
}

