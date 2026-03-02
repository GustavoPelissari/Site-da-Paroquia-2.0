import 'access_control_model.dart';

class UserModel {
  final String id;
  final String nome;
  final String email;
  int nivelAcesso; // 0 a 3
  final Set<String> groupIds;

  UserModel({
    required this.id,
    required this.nome,
    required this.email,
    required this.nivelAcesso,
    Set<String>? groupIds,
  }) : groupIds = groupIds ?? <String>{};

  AppRole get role {
    switch (nivelAcesso) {
      case 1:
        return AppRole.membroPastoral;
      case 2:
        return AppRole.coordenador;
      case 3:
        return AppRole.administrativo;
      case 4:
      default:
        return nivelAcesso >= 4 ? AppRole.padre : AppRole.usuarioPadrao;
    }
  }

  String get roleLabel => role.label;

  Set<AppCapability> get capabilities {
    switch (role) {
      case AppRole.usuarioPadrao:
        return {
          AppCapability.viewPublicContent,
          AppCapability.joinGroups,
        };
      case AppRole.membroPastoral:
        return {
          AppCapability.viewPublicContent,
          AppCapability.joinGroups,
          AppCapability.viewPrivateGroupNews,
          AppCapability.respondForms,
        };
      case AppRole.coordenador:
        return {
          AppCapability.viewPublicContent,
          AppCapability.joinGroups,
          AppCapability.viewPrivateGroupNews,
          AppCapability.respondForms,
          AppCapability.createNews,
          AppCapability.createEvents,
          AppCapability.setVisibility,
          AppCapability.createForms,
          AppCapability.viewFormResponses,
          AppCapability.uploadPdfSchedules,
          AppCapability.addScheduleDescription,
        };
      case AppRole.administrativo:
        return {
          AppCapability.viewPublicContent,
          AppCapability.joinGroups,
          AppCapability.viewPrivateGroupNews,
          AppCapability.respondForms,
          AppCapability.createNews,
          AppCapability.createEvents,
          AppCapability.setVisibility,
          AppCapability.createForms,
          AppCapability.viewFormResponses,
          AppCapability.uploadPdfSchedules,
          AppCapability.addScheduleDescription,
          AppCapability.manageUsersHierarchy,
          AppCapability.setGroupPermissions,
          AppCapability.manageMassSchedules,
        };
      case AppRole.padre:
        return AppCapability.values.toSet();
    }
  }
}
