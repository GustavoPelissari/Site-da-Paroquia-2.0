# Paroquia MVP

Projeto com 3 camadas:

- `backend`: API NestJS + TypeORM + MySQL
- `web-next`: landing em Next.js
- `lib`: app Flutter

## 1) Banco de dados

Execute os scripts:

- `db/schema.sql`
- `db/seed.sql`

## 2) Backend (NestJS)

```bash
cd backend
npm install
npm run start:dev
```

Variaveis esperadas:

- `DB_HOST`
- `DB_PORT`
- `DB_USER`
- `DB_PASS`
- `DB_NAME`
- `JWT_SECRET`
- `JWT_EXPIRES_IN` (opcional)

Rotas principais:

- `POST /api/auth/login`
- `GET /api/time`
- `GET /api/events`
- `GET /api/news`

## 3) Web (Next.js)

```bash
cd web-next
npm install
npm run dev
```

Opcional:

- `API_BASE_URL` (default: `http://localhost:3001/api`)

## 4) Flutter

```bash
flutter pub get
flutter run
```

Opcional:

- `--dart-define=API_BASE_URL=http://localhost:3001/api`
