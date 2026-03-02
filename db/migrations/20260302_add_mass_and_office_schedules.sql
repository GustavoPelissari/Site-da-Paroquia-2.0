USE pdgp;

CREATE TABLE IF NOT EXISTS mass_schedules (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  weekday TINYINT UNSIGNED NOT NULL,
  time TIME NOT NULL,
  location_name VARCHAR(160) NOT NULL,
  is_active TINYINT NOT NULL DEFAULT 1,
  notes TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_mass_schedules_weekday_time (weekday, time),
  CONSTRAINT chk_mass_schedules_weekday CHECK (weekday BETWEEN 0 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS office_hours (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  weekday TINYINT UNSIGNED NOT NULL,
  open_time TIME NOT NULL,
  close_time TIME NULL,
  label VARCHAR(120) NOT NULL DEFAULT 'Secretaria',
  is_active TINYINT NOT NULL DEFAULT 1,
  notes TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_office_hours_weekday_open (weekday, open_time),
  CONSTRAINT chk_office_hours_weekday CHECK (weekday BETWEEN 0 AND 6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 1, '06:00:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 1 AND time = '06:00:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 2, '06:00:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 2 AND time = '06:00:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 4, '06:00:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 4 AND time = '06:00:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 5, '06:00:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 5 AND time = '06:00:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 3, '06:30:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 3 AND time = '06:30:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 6, '18:00:00', 'Capela Nossa Senhora de Fatima', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 6 AND time = '18:00:00' AND location_name = 'Capela Nossa Senhora de Fatima'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 6, '19:30:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 6 AND time = '19:30:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 0, '08:00:00', 'Capela Santo Antonio', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 0 AND time = '08:00:00' AND location_name = 'Capela Santo Antonio'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 0, '09:30:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 0 AND time = '09:30:00' AND location_name = 'Paroquia'
);
INSERT INTO mass_schedules (weekday, time, location_name, is_active, notes)
SELECT 0, '18:00:00', 'Paroquia', 1, NULL WHERE NOT EXISTS (
  SELECT 1 FROM mass_schedules WHERE weekday = 0 AND time = '18:00:00' AND location_name = 'Paroquia'
);

INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 1, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 1 AND open_time = '08:00:00' AND close_time = '12:00:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 1, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 1 AND open_time = '13:30:00' AND close_time = '17:30:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 2, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 2 AND open_time = '08:00:00' AND close_time = '12:00:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 2, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 2 AND open_time = '13:30:00' AND close_time = '17:30:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 3, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 3 AND open_time = '08:00:00' AND close_time = '12:00:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 3, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 3 AND open_time = '13:30:00' AND close_time = '17:30:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 4, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 4 AND open_time = '08:00:00' AND close_time = '12:00:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 4, '13:30:00', '17:30:00', 'Secretaria', 1, 'Atendimento da tarde'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 4 AND open_time = '13:30:00' AND close_time = '17:30:00'
);
INSERT INTO office_hours (weekday, open_time, close_time, label, is_active, notes)
SELECT 5, '08:00:00', '12:00:00', 'Secretaria', 1, 'Atendimento da manha'
WHERE NOT EXISTS (
  SELECT 1 FROM office_hours WHERE weekday = 5 AND open_time = '08:00:00' AND close_time = '12:00:00'
);
