import 'package:flutter_test/flutter_test.dart';
import 'package:paroquia_mvp/models/access_control_model.dart';

void main() {
  test('rotulos dos perfis estao corretos', () {
    expect(AppRole.usuarioPadrao.label, 'Usuario padrao');
    expect(AppRole.membroPastoral.label, 'Membro de pastoral');
    expect(AppRole.coordenador.label, 'Coordenador');
    expect(AppRole.administrativo.label, 'Administrativo');
  });
}

