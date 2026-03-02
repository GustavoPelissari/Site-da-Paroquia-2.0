enum AppRole {
  usuarioPadrao,
  membroPastoral,
  coordenador,
  administrativo,
}

enum AppCapability {
  viewPublicContent,
  joinGroups,
  viewPrivateGroupNews,
  respondForms,
  createNews,
  createEvents,
  setVisibility,
  createForms,
  viewFormResponses,
  uploadPdfSchedules,
  addScheduleDescription,
  manageUsersHierarchy,
  setGroupPermissions,
  manageMassSchedules,
}

extension AppRoleX on AppRole {
  String get label {
    switch (this) {
      case AppRole.usuarioPadrao:
        return 'Usuario padrao';
      case AppRole.membroPastoral:
        return 'Membro de pastoral';
      case AppRole.coordenador:
        return 'Coordenador';
      case AppRole.administrativo:
        return 'Administrativo';
    }
  }
}
