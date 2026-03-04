# PDGP - Plataforma Digital de Gestao Paroquial

Projeto com 3 camadas:

- `backend`: API NestJS + TypeORM + MySQL
- `web-next`: frontend web (Next.js)
- `lib`: app Flutter (Android/iOS/Desktop)

---

## 1. Pre-requisitos

Instale antes de iniciar:

1. Node.js 20+ e npm
2. Flutter SDK 3.3+
3. Android Studio (SDK Android + Emulator)
4. MySQL 8+ (ou XAMPP com MySQL)
5. Git

Verificacoes rapidas:

```bash
node -v
npm -v
flutter --version
```

---

## 2. Estrutura do repositorio

```text
backend/     # API NestJS
web-next/    # Frontend web Next.js
lib/         # Codigo Flutter
db/          # Schema, seed e migrations SQL
```

---

## 3. Banco de dados (MySQL)

### 3.1 Iniciar MySQL

Se usar XAMPP:

1. Abra o XAMPP Control Panel
2. Inicie o servico `MySQL`

### 3.2 Criar schema e tabelas

Execute os scripts SQL na ordem:

1. `db/schema.sql`
2. `db/migrations/20260302_add_mass_and_office_schedules.sql`
3. `db/seed.sql`

Exemplo via terminal (Windows + XAMPP):

```powershell
Get-Content .\db\schema.sql | & 'C:\xampp\mysql\bin\mysql.exe' -u root
Get-Content .\db\migrations\20260302_add_mass_and_office_schedules.sql | & 'C:\xampp\mysql\bin\mysql.exe' -u root
Get-Content .\db\seed.sql | & 'C:\xampp\mysql\bin\mysql.exe' -u root
```

---

## 4. Backend (NestJS)

### 4.1 Configurar `.env`

Arquivo: `backend/.env`

```env
PORT=3001

DB_HOST=127.0.0.1
DB_PORT=3306
DB_USER=root
DB_PASS=
DB_NAME=pdgp

JWT_SECRET=troque-essa-chave-em-producao
JWT_EXPIRES_IN=7d

SMTP_HOST=127.0.0.1
SMTP_PORT=1025
SMTP_SECURE=false
SMTP_USER=
SMTP_PASS=
SMTP_FROM=no-reply@paroquia.local
RESET_PASSWORD_BASE_URL=http://localhost:3000/reset-password
```

### 4.2 Instalar e rodar

```bash
cd backend
npm install
npm run start:dev
```

API base:

- `http://localhost:3001/api`

Health-check:

- `GET http://localhost:3001/api/time`

---

## 5. Frontend Web (Next.js)

```bash
cd web-next
npm install
npm run dev
```

Abre em:

- `http://localhost:3000` (padrao do Next)

Variavel opcional:

- `API_BASE_URL` (default: `http://localhost:3001/api`)

---

## 6. Flutter + Android Studio (passo a passo)

### 6.1 Preparar Android Studio

1. Abra Android Studio
2. Instale:
   - Android SDK
   - Android SDK Platform
   - Android SDK Build-Tools
   - Android Emulator
3. Abra o Device Manager e crie um emulador (ex.: Pixel + API 34)
4. Inicie o emulador

### 6.2 Rodar Flutter

No diretorio raiz do projeto:

```bash
flutter pub get
flutter devices
flutter run -d emulator-5554
```

### 6.3 URL da API no Android

No emulador Android, `localhost` do app aponta para o emulador, nao para seu PC.

Use:

- `http://10.0.2.2:3001/api`

Se quiser forcar manualmente:

```bash
flutter run -d emulator-5554 --dart-define=API_BASE_URL=http://10.0.2.2:3001/api
```

Em desktop/web Flutter, pode usar:

- `http://localhost:3001/api`

---

## 7. Fluxo de autenticacao (resumo)

- Login: `POST /api/auth/login`
- Cadastro: `POST /api/auth/register`
- Refresh: `POST /api/auth/refresh`
- Perfil autenticado: `GET /api/auth/me`
- Logout: `POST /api/auth/logout`
- Solicitar reset: `POST /api/auth/forgot-password`
- Validar token reset: `GET /api/auth/reset-password/validate?token=...`
- Confirmar reset: `POST /api/auth/reset-password`

Tokens:

- Access token JWT
- Refresh token JWT (com hash no banco)

Fluxo de reset:

- Resposta generica no forgot-password (nao revela se email existe)
- Token de uso unico com expiracao (tabela `password_reset_tokens`)
- Senha alterada invalida refresh token anterior

---

## 7.1 Migration de reset de senha

Rode tambem:

1. `db/migrations/20260303_add_password_reset_tokens.sql`

Exemplo:

```powershell
Get-Content .\db\migrations\20260303_add_password_reset_tokens.sql | & 'C:\xampp\mysql\bin\mysql.exe' -u root
```

---

## 7.2 Migration de conteudo e midia

Para habilitar os novos campos de noticias/eventos/grupos e biblioteca de midia:

1. `db/migrations/20260304_enhanced_content_media.sql`

Exemplo:

```powershell
Get-Content .\db\migrations\20260304_enhanced_content_media.sql | & 'C:\xampp\mysql\bin\mysql.exe' -u root
```

Pastas de upload suportadas pela API:

- `/uploads/noticias`
- `/uploads/eventos`
- `/uploads/grupos`
- `/uploads/geral`

Endpoints:

- `POST /api/uploads/image?folder=noticias|eventos|grupos|geral`
- `GET /api/uploads/gallery?folder=noticias|eventos|grupos|geral`

---

## 7.3 Usuarios de teste (seed)

Depois de rodar `db/seed.sql`, voce pode usar:

- Senha para todos: `123456`
- `ana.fiel@paroquia.local` (nivel 0)
- `bruno.membro@paroquia.local` (nivel 1)
- `maria.coordenadora@paroquia.local` (nivel 2)
- `carlos.admin@paroquia.local` (nivel 3)
- `padre.jose@paroquia.local` (nivel 3)
- `usuario.teste@paroquia.local` (nivel 3)
- `teste.nivel0@paroquia.local` (nivel 0)
- `teste.nivel1@paroquia.local` (nivel 1)
- `teste.nivel2@paroquia.local` (nivel 2)
- `teste.nivel3@paroquia.local` (nivel 3)

---

## 8. Horarios dinamicos (banco + API)

Dados nao ficam hardcoded:

- Missas: tabela `mass_schedules`
- Secretaria: tabela `office_hours`

Endpoints publicos:

- `GET /api/public/mass-schedules`
- `GET /api/public/office-hours`
- `GET /api/public/masses/next` (calculo por horario do servidor)

Endpoints admin protegidos (JWT + nivel >= 1):

- `POST /api/mass-schedules`
- `PATCH /api/mass-schedules/:id`
- `PATCH /api/mass-schedules/:id/deactivate`
- `POST /api/office-hours`
- `PATCH /api/office-hours/:id`
- `PATCH /api/office-hours/:id/deactivate`

---

## 9. Assets principais

Em `web-next/public/img`:

- Logo: `IMAGEM DE SÃO PAULO APOSTOLO MONOCROMATICA.png`
- Foto da paroquia: `IMAGEM DA PAROQUIA.jpeg`

Declarados em `pubspec.yaml` para uso no Flutter.

---

## 10. Solucao de problemas

### Erro `ECONNREFUSED 127.0.0.1:3306`

- MySQL nao esta rodando.
- Inicie MySQL no XAMPP.

### Login retorna 401

- Usuario/senha nao batem no banco.
- Rode novamente o `db/seed.sql`.

### Login com timeout no Android emulator

- API URL incorreta.
- Use `10.0.2.2` no `--dart-define`.

### Rotas de horarios retornam 500

- Migration de horarios nao aplicada.
- Rode `db/migrations/20260302_add_mass_and_office_schedules.sql`.

---

## 11. Comandos uteis

Backend:

```bash
cd backend
npm run build
npm run start:dev
```

Flutter:

```bash
flutter pub get
flutter analyze lib
flutter run -d emulator-5554
```

Web:

```bash
cd web-next
npm run dev
```
