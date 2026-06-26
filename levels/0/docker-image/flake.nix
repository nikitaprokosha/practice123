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
        # Сборка Docker-образа
        # Для создания образа: `docker load -i $(nix build --print-out-paths)`
        # ПРИМЕЧАНИЕ: Работает только на Linux
        packages.default =
          pkgs.dockerTools.buildImage {
            name = "nix-demo";
            copyToRoot = pkgs.buildEnv {
              name = "nix-demo";
              paths = [
                pkgs.cowsay
                pkgs.bashInteractive
                pkgs.coreutils
              ];
            };
          };
      };
    };
}
