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
  id, nome, descricao, responsavel, horario_encontros, local_encontro, imagem_url, contato, whatsapp_link, coordenador_id,
  permite_pdf_upload, permite_formularios, permite_noticias, permite_eventos
) VALUES
  (1, 'Pastoral da Juventude', 'Encontros e missoes com jovens.', 'Maria Coordenadora', 'Sabados 19:30', 'Salao Jovem', NULL, 'juventude@paroquia.local', 'https://wa.me/5544999990001', 3, 1, 1, 1, 1),
  (2, 'Coroinhas', 'Escalas liturgicas e formacao de altar.', 'Bruno Membro', 'Domingos 07:30', 'Sacristia', NULL, 'coroinhas@paroquia.local', 'https://wa.me/5544999990002', 3, 1, 0, 1, 0),
  (3, 'Pastoral Familiar', 'Acolhimento e acompanhamento de familias.', 'Carlos Administrativo', 'Quartas 20:00', 'Auditorio', NULL, 'familiar@paroquia.local', 'https://wa.me/5544999990003', 4, 0, 1, 1, 1)
ON DUPLICATE KEY UPDATE nome=VALUES(nome);

INSERT INTO group_members (group_id, user_id) VALUES
  (1, 2),
  (1, 3),
  (2, 2),
  (2, 3),
  (3, 4)
ON DUPLICATE KEY UPDATE group_id=group_id;

INSERT INTO news (
  titulo, subtitulo, categoria, conteudo, imagem_url, galeria_json, link_externo,
  publico, destaque, aviso_paroquial, data_publicacao, agendamento_publicacao, data_expiracao, group_id, autor_nome
) VALUES
  (
    'Festa da Padroeira',
    'Programacao completa da semana festiva',
    'Liturgia',
    'Programacao geral com missa, quermesse e momentos de convivencia.',
    'https://images.unsplash.com/photo-1515150144380-bca9f1650ed9',
    JSON_ARRAY('https://images.unsplash.com/photo-1469474968028-56623f02e42e'),
    'https://paroquia.local/festa-padroeira',
    1,
    1,
    1,
    NOW(),
    NULL,
    NULL,
    NULL,
    'Padre Jose'
  ),
  (
    'Escala interna da Juventude',
    'Equipe de acolhida e musica',
    'Pastoral',
    'Escala de servico dos membros no retiro do mes.',
    NULL,
    JSON_ARRAY(),
    NULL,
    0,
    0,
    0,
    NOW(),
    NULL,
    NULL,
    1,
    'Maria Coordenadora'
  ),
  (
    'Aviso dos Coroinhas',
    'Preparacao liturgica mensal',
    'Comunicado',
    'Encontro mensal dos coroinhas no salao paroquial.',
    NULL,
    JSON_ARRAY(),
    NULL,
    1,
    0,
    1,
    NOW(),
    NULL,
    NULL,
    2,
    'Bruno Membro'
  );

INSERT INTO events (
  nome, descricao, data_hora, data_final, local, tipo, imagem_url, link_externo, link_inscricao, limite_participantes, publico, group_id
) VALUES
  (
    'Missa Dominical',
    'Celebracao comunitaria de domingo.',
    DATE_ADD(NOW(), INTERVAL 1 DAY),
    NULL,
    'Igreja Matriz',
    'MISSA',
    'https://images.unsplash.com/photo-1529074963764-98f45c47344b',
    NULL,
    NULL,
    NULL,
    1,
    NULL
  ),
  (
    'Reuniao da Juventude',
    'Planejamento das atividades missionarias.',
    DATE_ADD(NOW(), INTERVAL 2 DAY),
    NULL,
    'Salao Paroquial',
    'REUNIAO',
    NULL,
    NULL,
    'https://paroquia.local/inscricao-juventude',
    60,
    0,
    1
  ),
  (
    'Encontro da Pastoral Familiar',
    'Noite de espiritualidade para familias.',
    DATE_ADD(NOW(), INTERVAL 3 DAY),
    DATE_ADD(DATE_ADD(NOW(), INTERVAL 3 DAY), INTERVAL 2 HOUR),
    'Auditorio',
    'FESTA',
    'https://images.unsplash.com/photo-1438232992991-995b7058bbb3',
    'https://paroquia.local/pastoral-familiar',
    NULL,
    120,
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
