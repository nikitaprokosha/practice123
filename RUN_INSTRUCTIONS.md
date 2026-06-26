# Инструкция по запуску тренажёра Nix

## 🎯 Быстрый старт

### 1. Веб-сайт (статический)

Веб-сайт уже собран в результате выполнения `nix build .#website`.

**Просмотреть содержимое:**
```bash
ls -lh result/
```

**Запустить локальный веб-сервер:**
```bash
nix run .#website
```
Откройте http://localhost:8000 в браузере.

**Скопировать сайт:**
```bash
cp -r result/ /path/to/webserver/
```

### 2. Docker-образ с тренажёром

Docker-образ собран в файле `result` (ссылка на `.tar.gz`).

**Загрузить образ в Docker:**
```bash
docker load -i result
```

**Запустить контейнер:**
```bash
docker run -it nix-training:latest
```

**Запустить с интерактивной сессией:**
```bash
docker run -it --rm nix-training:latest bash
```

---

## 📦 Детали сборки

### Веб-сайт

**Что входит:**
- HTML-страницы, сгенерированные из Markdown
- Навигация между уровнями
- Стильный CSS для удобного чтения

**Команды:**
```bash
# Собрать сайт
nix build .#website

# Результат в ./result
# Или получить путь явно:
nix path-info .#website

# Запустить сервер разработки
nix run .#website
```

**Структура сайта:**
```
result/
├── index.html          # Главная страница
├── levels/
│   ├── 0/
│   │   ├── README.html
│   │   ├── devshell/README.html
│   │   ├── process-compose/README.html
│   │   └── docker-image/README.html
│   └── 1/
│       └── README.html
├── STRUCTURE.html      # Архитектура
└── AGENTS.html         # Для агента
```

### Docker-образы

Доступны 2 образа:

#### 1. `nix-training:latest` (полный)
Содержит все инструменты для практики:
- cowsay, ponysay
- process-compose, sqlite, sqlite-web
- GHC, Cabal, Rust
- htop, nil (Nix LSP)

**Сборка:**
```bash
nix build .#docker
```

**Использование:**
```bash
# Загрузить
docker load -i result

# Запустить
docker run -it nix-training:latest

# Внутри контейнера:
cd /training
ls -la
```

#### 2. `nix-training-materials:latest` (минимальный)
Только материалы и базовый Nix.

**Сборка:**
```bash
nix build .#materials-image
```

**Использование:**
```bash
docker load -i result
docker run -it nix-training-materials:latest
```

---

## 🚀 Практические примеры

### Уровень 0: Devshell

```bash
# Внутри Docker или локально
cd /training/levels/0/devshell
nix develop

# Вы в среде с cowsay, ghc, cabal, htop
cowsay "Hello Nix!"
```

### Уровень 0: Process-compose

```bash
cd /training/levels/0/process-compose
nix run

# Запустится sqlite-web с базой Chinook
# Откройте http://localhost:8213
```

### Уровень 0: Docker-образ

```bash
cd /training/levels/0/docker-image
nix build

# Только Linux!
docker load -i $(nix build --print-out-paths)
docker run -it nix-demo bash
```

### Уровень 1: Деривации

```bash
cd /training/levels/1

# Сборка Rust-программы
nix-build drv.nix -A someBinary
./result/bin/some-binary

# Process-compose пример
nix-build pc.nix -A myapp
./myapp
```

---

## 🛠️ Разработка

### Среда разработки

```bash
# Войти в devshell для разработки тренажёра
nix develop

# Доступные команды:
# - nix build .#website   (собрать сайт)
# - nix run .#website     (запустить сервер)
# - nix build .#docker    (собрать Docker)
# - nix run .#docker      (загрузить в Docker)
```

### Добавление нового уровня

1. Создайте каталог `levels/N/`
2. Добавьте `README.md` с описанием
3. Добавьте демо с `flake.nix`
4. Обновите главный `README.md`

### Тестирование

```bash
# Проверка всех примеров
nix flake check

# Форматирование кода
nix fmt
```

---

## 📊 Сводка команд

| Действие | Команда |
|----------|---------|
| Собрать сайт | `nix build .#website` |
| Запустить сайт | `nix run .#website` |
| Собрать Docker | `nix build .#docker` |
| Загрузить Docker | `docker load -i result` |
| Запустить Docker | `docker run -it nix-training:latest` |
| Среда разработки | `nix develop` |
| Проверить flake | `nix flake check` |
| Отформатировать | `nix fmt` |

---

## 🔧 Требования

- **Nix** с поддержкой flakes
- **Docker** (для Docker-образов)
- **Linux** (для некоторых демо с Docker)

---

## 📝 Примечания

1. Веб-сайт использует простую конвертацию Markdown → HTML
2. Docker-образы работают на Linux (для создания образов)
3. Некоторые примеры требуют сеть для загрузки пакетов
4. Для ускорения используйте Nix cache (cachix)
