{
  description = "Демонстрация sqlite-web";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    process-compose-flake.url = "github:Platonic-Systems/process-compose-flake";

    chinookDb.url = "github:lerocha/chinook-database";
    chinookDb.flake = false;
  };
  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;
      imports = [
        inputs.process-compose-flake.flakeModule
      ];
      perSystem = { self', pkgs, lib, ... }: {
        # Это добавляет `self.packages.default`
        process-compose."default" =
          let
            port = 8213;
            dataFile = "data.sqlite";
          in
          {
            settings = {
              environment = {
                SQLITE_WEB_PASSWORD = "demo";
              };

              processes = {
                # Выводим пони каждые 2 секунды, почему бы и нет.
                ponysay.command = ''
                  while true; do
                    ${lib.getExe pkgs.ponysay} "Наслаждайтесь нашей демонстрацией sqlite-web!"
                    sleep 2
                  done
                '';

                # Создаём .sqlite базу данных из базы chinook.
                sqlite-init.command = ''
                  echo "$(date): Импорт базы данных Chinook (${dataFile}) ..."
                  ${lib.getExe pkgs.sqlite} "${dataFile}" < ${inputs.chinookDb}/ChinookDatabase/DataSources/Chinook_Sqlite.sql
                  echo "$(date): Готово."
                '';

                # Запускаем sqlite-web на локальной базе chinook.
                sqlite-web = {
                  command = ''
                    ${pkgs.sqlite-web}/bin/sqlite_web \
                      --password \
                      --port ${builtins.toString port} "${dataFile}"
                  '';
                  # 'depends_on' заставит этот процесс ждать завершения предыдущего.
                  depends_on."sqlite-init".condition = "process_completed_successfully";
                  readiness_probe.http_get = {
                    host = "localhost";
                    inherit port;
                  };
                };
              };
            };

            testScript = ''
              process_compose.wait_until(lambda procs:
                procs["sqlite-web"]["is_ready"] == "Ready"
              )
              machine.succeed("curl -v http://localhost:${builtins.toString port}/")
            '';
          };
      };
    };
}
