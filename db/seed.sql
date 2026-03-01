USE pdgp;

-- Admin inicial:
-- Email: admin@paroquia.local
-- Senha: admin123
-- Hash bcrypt: $2b$10$Xnz/iOd4D4r48GLv9uZ8eO.gK.cYo2anrzS6JijLEC3eC59yjrLKW

INSERT INTO users (nome, email, senha_hash, nivel_acesso)
VALUES (
  'Administrador',
  'admin@paroquia.local',
  '$2b$10$Xnz/iOd4D4r48GLv9uZ8eO.gK.cYo2anrzS6JijLEC3eC59yjrLKW',
  3
)
ON DUPLICATE KEY UPDATE email=email;