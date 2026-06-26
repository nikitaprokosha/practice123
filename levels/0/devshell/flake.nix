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
        # Чтобы войти в эту среду разработки, выполните "nix develop"
        devShells.default =
          pkgs.mkShell {
            name = "level-0";
            nativeBuildInputs = [
              pkgs.cowsay
              pkgs.cabal-install
              pkgs.ghc
              pkgs.nil
              pkgs.htop
            ];
            shellHook = ''
              echo "Вы в среде разработки nix"
              echo "Выполните 'htop', чтобы увидеть процессы"
            '';
          };

        # Чтобы запустить это приложение, выполните "nix run .#foo"
        apps.foo.program = pkgs.writeShellApplication {
          name = "foo";
          runtimeInputs = [ pkgs.cowsay ];
          text = ''
            cowsay Moo!!!!
          '';
        };

      };
    };
}
