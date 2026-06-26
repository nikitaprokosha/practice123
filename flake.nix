{
  description = "Тренажёр Nix - обучающие материалы и примеры";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem = { self', pkgs, system, ... }: {
        # ============================================
        # ПАКЕТ 1: Статический веб-сайт
        # ============================================
        packages.website = pkgs.stdenv.mkDerivation {
          name = "nix-training-website";
          src = ./.;

          nativeBuildInputs = [ pkgs.python3 pkgs.bash ];

          buildPhase = ''
            echo "Генерация статического сайта..."
            
            # Создаём директорию для сайта
            mkdir -p public
            
            # Копируем README как главную страницу
            cp README.md public/index.md
            
            # Копируем все уровни
            cp -r levels public/
            
            # Копируем дополнительные файлы если существуют
            cp STRUCTURE.md public/ 2>/dev/null || true
            cp AGENTS.md public/ 2>/dev/null || true
            
            # Запускаем скрипт генерации
            bash ${./build-site.sh}
          '';

          installPhase = ''
            mkdir -p $out
            cp -r public/* $out/
          '';
        };

        # ============================================
        # ПАКЕТ 2: Docker-образ с тренажёром
        # ============================================
        packages.docker = pkgs.dockerTools.buildImage {
          name = "nix-training";
          tag = "latest";
          
          copyToRoot = pkgs.buildEnv {
            name = "nix-training-tools";
            paths = with pkgs; [
              # Базовые инструменты
              bash
              coreutils
              
              # Nix инструменты (если доступны)
              # nix
              
              # Инструменты из уровней
              cowsay
              process-compose
              sqlite
              sqlite-web
              ponysay
              
              # Языки программирования
              ghc
              cabal-install
              rustc
              
              # Утилиты
              htop
              nil  # Nix LSP
            ];
          };

          # Копируем учебные материалы
          extraCommands = ''
            mkdir -p ./training
            cp -r ${./.}/* ./training/
          '';

          config = {
            WorkingDir = "/training";
            Cmd = [ "bash" ];
            Env = [
              "PS1=\\[\\e[36m\\]nix-training\\[\\e[0m\\]:\\w$ "
            ];
          };
        };

        # ============================================
        # ПАКЕТ 3: Образ только с материалами
        # ============================================
        packages."materials-image" = pkgs.dockerTools.buildImage {
          name = "nix-training-materials";
          tag = "latest";
          
          copyToRoot = pkgs.buildEnv {
            name = "materials";
            paths = with pkgs; [
              bash
              coreutils
              nix
            ];
          };

          extraCommands = ''
            mkdir -p /training
            cp -r ${./.}/* /training/
            echo "echo 'Добро пожаловать в тренажёр Nix!'" >> /etc/bashrc
            echo "echo 'Перейдите в /training и начните с уровня 0'" >> /etc/bashrc
          '';

          config = {
            WorkingDir = "/training";
            Cmd = [ "bash" ];
          };
        };

        # ============================================
        # Приложения для запуска
        # ============================================
        apps.website = {
          type = "app";
          program = pkgs.writeShellApplication {
            name = "serve-website";
            runtimeInputs = [ pkgs.python3 ];
            text = ''
              echo "Запуск веб-сервера..."
              echo "Откройте http://localhost:8000"
              cd ${self'.packages.website}
              python3 -m http.server 8000
            '';
          };
        };

        apps.docker = {
          type = "app";
          program = pkgs.writeShellApplication {
            name = "load-docker";
            runtimeInputs = [ pkgs.docker ];
            text = ''
              echo "Загрузка Docker-образа..."
              docker load -i ${self'.packages.docker}
              echo ""
              echo "Образ загружен!"
              echo "Запустите: docker run -it nix-training:latest"
            '';
          };
        };

        # ============================================
        # DevShell для разработки тренажёра
        # ============================================
        devShells.default = pkgs.mkShell {
          name = "nix-training-dev";
          
          nativeBuildInputs = with pkgs; [
            # Инструменты для работы с Nix
            nil
            nixfmt-classic
            
            # Для генерации сайта
            python3
            
            # Для тестирования примеров
            cowsay
            ponysay
            process-compose
            sqlite
            sqlite-web
          ];

          shellHook = ''
            echo "=============================================="
            echo "  Среда разработки тренажёра Nix"
            echo "=============================================="
            echo ""
            echo "Доступные команды:"
            echo "  nix build .#website     - Собрать веб-сайт"
            echo "  nix run .#website       - Запустить веб-сервер"
            echo "  nix build .#docker      - Собрать Docker-образ"
            echo "  nix run .#docker        - Загрузить образ в Docker"
            echo ""
            echo "Примеры из уровней:"
            echo "  cd levels/0/devshell && nix develop"
            echo "  cd levels/0/process-compose && nix run"
            echo "  cd levels/0/docker-image && nix build"
            echo ""
          '';
        };
      };
    };
}
