let
  # Стандартная библиотека Nix
  pkgs = import <nixpkgs> { };
in
rec {
  # Один файл
  aFile1 = pkgs.writeTextFile {
    name = "aFile";
    text = "Single file path";
  };

  aFile2 = pkgs.runCommand "aFile" { } ''
    echo "Single file path" > $out
  '';

  # Папка
  aFolder = pkgs.runCommand "aFolder" { } ''
    mkdir -p $out
    echo "Hello, world!" > $out/someFile
    echo "Hello, world!!!!" > $out/anotherFile
    ln -sf ${aFile2} $out/aFile
    # ПРИМЕЧАНИЕ: сеть недоступна, так как деривации изолированы
  '';

  # Скачано из интернета
  downloadedZip = pkgs.fetchzip {
    url = "https://github.com/readmeio/import-samples/raw/master/import-sample-single-version.zip";
    sha256 = "sha256-uqMV+1AyXtJcs3C7NacEjhK+dDKj9QDwxOPS6sgtZlY=";
  };
  # ^ Также есть `pkgs.fetchgit` для загрузки из Git-репозитория.
  # Но лучше использовать flake-inputs (rev и hash отслеживаются в `flake.lock`).

  # Может быть просто локальными путями
  myself = ./.;

  # Запуск произвольного преобразования из одного пути в другой
  converted = pkgs.stdenv.mkDerivation {
    name = "nix-html";
    buildInputs = [ pkgs.highlight ];
    src = ./.;
    installPhase = ''
      mkdir -p $out
      highlight -d $out $src/drv.nix
    '';
  };

  rustc = pkgs.rustc;

  # Сборка простого Rust-программы
  someBinary = pkgs.stdenv.mkDerivation {
    name = "some-binary";
    src = ./rust;
    buildInputs = [ pkgs.rustc ];
    phases = [ "buildPhase" ];
    buildPhase = ''
      mkdir -p $out/bin
      cd $src
      rustc main.rs -o $out/bin/some-binary
    '';
  };

  someShell = pkgs.mkShell {
    name = "some-shell";
    nativeBuildInputs = [ 
      pkgs.htop 
      someBinary
    ];
  };
}
