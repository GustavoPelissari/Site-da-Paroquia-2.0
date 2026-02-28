# Paróquia MVP (Flutter)

## Como rodar

1. Instale o Flutter SDK.
2. No diretório do projeto, rode:

```bash
flutter pub get
flutter run
```

## Telas

- Home (Próxima Missa + feed de notícias)
- Grupos (lista + detalhe com Escalas/Docs e Notícias)
- Eventos (lista com filtro por tipo)
- Perfil (dados mock + troca de nível de acesso)

## Onde trocar mocks

- Dados em memória: `lib/services/mock_repository.dart`
- Estado e regras de UI/permissão: `lib/state/app_state.dart`
