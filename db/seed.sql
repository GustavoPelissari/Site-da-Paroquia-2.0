USE pdgp;

-- Senha comum para testes: 123456
-- Hash bcrypt: $2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6

INSERT INTO users (id, nome, email, senha_hash, nivel_acesso) VALUES
  (1, 'Ana Fiel', 'ana.fiel@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 0),
  (2, 'Bruno Membro', 'bruno.membro@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 1),
  (3, 'Maria Coordenadora', 'maria.coordenadora@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 2),
  (4, 'Carlos Administrativo', 'carlos.admin@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 3),
  (5, 'Padre Jose', 'padre.jose@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 3),
  (6, 'Usuario Teste', 'usuario.teste@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 3),
  (7, 'Teste Nivel 0', 'teste.nivel0@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 0),
  (8, 'Teste Nivel 1', 'teste.nivel1@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 1),
  (9, 'Teste Nivel 2', 'teste.nivel2@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 2),
  (10, 'Teste Nivel 3', 'teste.nivel3@paroquia.local', '$2b$10$KzSNsO.C7Ly9/Rb.pli0suXbcwKRYJ60FV2y0R.ymuIJXaCEVRFD6', 3)
ON DUPLICATE KEY UPDATE
  nome = VALUES(nome),
  email = VALUES(email),
  senha_hash = VALUES(senha_hash),
  nivel_acesso = VALUES(nivel_acesso),
  refresh_token_hash = NULL;

INSERT INTO groups (
  id, nome, descricao, coordenador_id,
  permite_pdf_upload, permite_formularios, permite_noticias, permite_eventos
) VALUES
  (1, 'Pastoral da Juventude', 'Encontros e missoes com jovens.', 3, 1, 1, 1, 1),
  (2, 'Coroinhas', 'Escalas liturgicas e formacao de altar.', 3, 1, 0, 1, 0),
  (3, 'Pastoral Familiar', 'Acolhimento e acompanhamento de familias.', 4, 0, 1, 1, 1)
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT INTO group_members (group_id, user_id) VALUES
  (1, 2),
  (1, 3),
  (2, 2),
  (2, 3),
  (3, 4)
ON DUPLICATE KEY UPDATE group_id=group_id;

INSERT INTO news (titulo, conteudo, imagem_url, link_externo, publico, group_id) VALUES
  (
    'Festa da Padroeira',
    'Programacao geral com missa, quermesse e momentos de convivencia.',
    'https://images.unsplash.com/photo-1515150144380-bca9f1650ed9',
    'https://paroquia.local/festa-padroeira',
    1,
    NULL
  ),
  (
    'Escala interna da Juventude',
    'Escala de servico dos membros no retiro do mes.',
    NULL,
    NULL,
    0,
    1
  ),
  (
    'Aviso dos Coroinhas',
    'Encontro mensal dos coroinhas no salao paroquial.',
    NULL,
    NULL,
    1,
    2
  );

INSERT INTO events (nome, data_hora, local, tipo, imagem_url, link_externo, publico, group_id) VALUES
  (
    'Missa Dominical',
    DATE_ADD(NOW(), INTERVAL 1 DAY),
    'Igreja Matriz',
    'MISSA',
    'https://images.unsplash.com/photo-1529074963764-98f45c47344b',
    NULL,
    1,
    NULL
  ),
  (
    'Reuniao da Juventude',
    DATE_ADD(NOW(), INTERVAL 2 DAY),
    'Salao Paroquial',
    'REUNIAO',
    NULL,
    NULL,
    0,
    1
  ),
  (
    'Encontro da Pastoral Familiar',
    DATE_ADD(NOW(), INTERVAL 3 DAY),
    'Auditorio',
    'FESTA',
    'https://images.unsplash.com/photo-1438232992991-995b7058bbb3',
    'https://paroquia.local/pastoral-familiar',
    1,
    3
  );

INSERT INTO forms (titulo, config_json, visibilidade, consentimento_lgpd, ativo, group_id) VALUES
  (
    'Inscricao para retiro jovem',
    JSON_OBJECT('campos', JSON_ARRAY('nome', 'telefone', 'idade')),
    'GRUPO',
    1,
    1,
    1
  ),
  (
    'Atualizacao cadastral da comunidade',
    JSON_OBJECT('campos', JSON_ARRAY('nome', 'email', 'endereco')),
    'PUBLICO',
    1,
    1,
    NULL
  );

INSERT INTO form_responses (form_id, user_id, respostas_json) VALUES
  (1, 2, JSON_OBJECT('nome', 'Bruno Membro', 'telefone', '44999999999', 'idade', 22)),
  (2, 1, JSON_OBJECT('nome', 'Ana Fiel', 'email', 'ana.fiel@paroquia.local', 'endereco', 'Rua Central, 100'));

INSERT INTO schedules (group_id, pdf_url, descricao) VALUES
  (2, 'https://paroquia.local/escala-coroinhas-abril.pdf', 'Escala mensal dos coroinhas'),
  (1, 'https://paroquia.local/escala-juventude-retiro.pdf', 'Escala de servico para retiro da juventude');

INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes) VALUES
  (1, '06:00:00', 'Paroquia', 1, NULL),
  (2, '06:00:00', 'Paroquia', 1, NULL),
  (4, '06:00:00', 'Paroquia', 1, NULL),
  (5, '06:00:00', 'Paroquia', 1, NULL),
  (3, '06:30:00', 'Paroquia', 1, NULL),
  (6, '18:00:00', 'Capela Nossa Senhora de Fatima', 1, NULL),
  (6, '19:30:00', 'Paroquia', 1, NULL),
  (0, '08:00:00', 'Capela Santo Antonio', 1, NULL),
  (0, '09:30:00', 'Paroquia', 1, NULL),
  (0, '18:00:00', 'Paroquia', 1, NULL);

INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes) VALUES
  (1, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'),
  (1, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'),
  (2, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'),
  (2, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'),
  (3, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'),
  (3, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'),
  (4, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'),
  (4, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'),
  (5, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha');
