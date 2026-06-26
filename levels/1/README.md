# Уровень 1

## Nix Store

### Store Paths (пути в хранилище)

- Файлы и папки в `/nix/store`, каждый с уникальным хешем
- CLI для их создания:
    ```
    nix store add-file
    nix store add-path
    nix store delete

    # Скачано из интернета
    nix store prefetch-file https://nammayatri.in/
    ```

### Деривация

- `.drv`: Рецепты или функции, которые знают, как создать путь в хранилище, используя только другие пути хранилища в качестве входа.
- `nix-build` (или `:b` в `nix repl`) вычисляет деривацию для получения результата в Nix store.

## Написание Nix для создания дериваций

### Builtin (встроенные функции)

Простейший пример:

```sh
nix-build -E '
    derivation {
        name="test"; 
        src=./.; 
        builder="/bin/bash"; 
        system="aarch64-darwin"; 
        args=["-c" "echo Hello > $out"];
    }'
```

### `mkDerivation`

Это слишком низкоуровнево. Давайте используем nixpkgs («стандартную библиотеку» Nix):

```nix
let 
    pkgs = import <nixpkgs> {};
in 
    pkgs.stdenv.mkDerivation {
        name = "test";
        src = ./.;
        installPhase = ''
            echo Hello > $out
        '';
    }
```

### `runCommand`

Поднимемся на уровень выше:

### `writeFile`

Ещё выше.

## Пример process-compose!

pc.nix