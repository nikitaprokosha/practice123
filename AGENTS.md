# Руководство для агента: Тренажёр Nix

## Обзор проекта

Это **серия обучающих материалов по Nix**, обучающая пользователей от основ до продвинутых концепций. Проект структурирован как прогрессивные «уровни» с демонстрациями и упражнениями.

**Статус**: В разработке (уровни 0-1 завершены, 2-5 запланированы)

## Структура репозитория

```
nix-training/
├── README.md           # Основной обзор с таблицей уровней
├── index.yaml          # Конфигурация сайта (вероятно, для генерации статического сайта)
├── levels/
│   ├── 0/              # Вводные демо (менеджер пакетов, devshell, docker, процессы)
│   │   ├── README.md
│   │   ├── devshell/
│   │   ├── process-compose/
│   │   └── docker-image/
│   └── 1/              # Основы Nix (store, деривации, язык)
│       ├── README.md
│       ├── drv.nix
│       ├── pc.nix
│       └── rust/
```

## Основные команды

### Операции Nix
```bash
# Сборка деривации
nix-build <file.nix> -A <attribute>

# Вход в среду разработки
nix develop

# Запуск приложения flake
nix run .#<app-name>

# Сборка и загрузка Docker-образа (только Linux)
docker load -i $(nix build --print-out-paths)

# Поиск пакетов
nix search nixpkgs <keyword>

# Установка пакета в профиль
nix profile install nixpkgs#<package>
```

## Структура Flake

Все демо используют **flake-parts** для модульной структуры:

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      perSystem = { self', pkgs, lib, ... }: {
        # devShells.default, apps.<name>, packages.default
      };
    };
}
```

## Важные соглашения

### Именование
- Каталоги уровней используют числовые имена: `0/`, `1/`, и т.д.
- Подкаталоги демо описательные: `devshell/`, `process-compose/`, `docker-image/`
- Nix-файлы: `flake.nix` (flakes), `*.nix` (выражения)

### Перекрёстные ссылки
- README используют синтаксис `![[путь/файл]]` для ссылок на другие файлы (вероятно, для генерации статического сайта)
- При перемещении/переименовании файлов сохраняйте эти ссылки действительными

### Совместимость с системами
- Демо Docker-образов работают **только на Linux** (`pkgs.dockerTools.buildImage`)
- Список систем flake импортируется из `nix-systems/default` для кроссплатформенной поддержки

## Распространённые паттерны Nix

### Деривации
- `pkgs.stdenv.mkDerivation` — стандартный билдер
- `pkgs.runCommand` — простой исполнитель команд
- `pkgs.writeTextFile` / `pkgs.writeShellScript` — создатели файлов
- `pkgs.fetchzip` / `pkgs.fetchgit` — загрузчики (предпочитайте flake-inputs)

### Среды разработки
```nix
devShells.default = pkgs.mkShell {
  name = "...";
  nativeBuildInputs = [ pkgs.pkg1 pkgs.pkg2 ];
  shellHook = ''echo "Добро пожаловать"'';
};
```

### Приложения
```nix
apps.<name>.program = pkgs.writeShellApplication {
  name = "...";
  runtimeInputs = [ pkgs.dep ];
  text = ''command'';
};
```

## Тестирование

Модуль `process-compose-flake` включает `testScript` для тестирования процессов:

```nix
testScript = ''
  process_compose.wait_until(lambda procs:
    procs["sqlite-web"]["is_ready"] == "Ready"
  )
  machine.succeed("curl -v http://localhost:${port}/")
'';
```

## Подводные камни

1. **Изоляция (sandboxing)**: Деривации изолированы — нет доступа к сети во время сборок. Используйте `fetchzip`/`fetchgit` или flake-inputs для загрузок.

2. **Docker только на Linux**: Функция `dockerTools.buildImage` работает только на Linux.

3. **Flake-inputs**: Когда установлено `flake = false` (например, для chinookDb), вход обрабатывается как обычный git-репозиторий, а не как flake.

4. **Пути вывода**: Используйте `--print-out-paths`, чтобы получить путь к результату сборки для таких команд, как `docker load`.

5. **Фазы**: Пользовательские деривации могут указывать `phases = [ "buildPhase" ]`, чтобы пропустить ненужные фазы.

## Упражнения

Уровень 1 включает упражнение в `pc.nix`: воспроизведите демо sqlite-web из `levels/0/process-compose`, используя подход без flake.

## Зависимости

Ключевые входы, используемые в проекте:
- **nixpkgs**: `github:nixos/nixpkgs/nixpkgs-unstable`
- **flake-parts**: `github:hercules-ci/flake-parts`
- **systems**: `github:nix-systems/default`
- **process-compose-flake**: `github:Platonic-Systems/process-compose-flake`
