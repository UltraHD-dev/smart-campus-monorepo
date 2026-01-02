# 🎓 Smart Campus Platform

Универсальная платформа "Умный Кампус" для любого университета.

## 🚀 Технологии

- **Frontend**: Flutter (Android, iOS, Linux, Windows, macOS)
- **Backend**: Go + gRPC + PostgreSQL + Redis
- **Архитектура**: Микросервисы + Monorepo
- **CI/CD**: GitHub Actions
- **Инфраструктура**: Docker, Docker Compose

## 📁 Структура

```
smart-campus-monorepo/
├── mobile/          # Flutter приложение
├── services/        # Go микросервисы
├── proto/           # Protobuf контракты
├── shared/          # Общие библиотеки
├── infrastructure/  # Docker, мониторинг
└── .github/         # CI/CD
```

## 🔧 Установка

```bash
# Установить зависимости
make install-deps

# Сгенерировать код из proto
make proto

# Запустить инфраструктуру
docker-compose -f infrastructure/docker-compose.yml up -d

# Запустить сервисы
make run-all
```

## 📱 Поддерживаемые платформы

- ✅ Android
- ✅ iOS
- ✅ Linux
- ✅ Windows
- ✅ macOS
- ❌ Web (не поддерживается)

## 📄 Лицензия

MIT
