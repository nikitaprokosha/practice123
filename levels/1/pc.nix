# nix-build pc.nix -A myapp -o myapp
# ./myapp
let
  pkgs = import <nixpkgs> { };
in
rec {
  configFile = pkgs.writeTextFile {
    name = "pc.yaml";
    text = builtins.toJSON {
      processes = {
        clock = {
          command = ''
            bash -c "while true; do date; sleep 1; done"
          '';
        };
      };
    };
  };

  pc = pkgs.process-compose;

  myapp = pkgs.writeShellScript "myapp" ''
    ${pc}/bin/process-compose -f ${configFile} $*
  '';

  # TODO: dockerImage (только Linux)
}

# TODO: Упражнение.
# Воспроизведите демо sqlite-web из ../0/process-compose, но в этом файле.