# NixOS машины

NixOS flake с конфигурациями машин из этого репозитория.

## Удаленный rebuild

Команды запускаются из корня репозитория.

Чтобы собрать и активировать конфигурацию `ares` на удаленной машине:

```sh
nix run nixpkgs#nixos-rebuild -- test --flake .#ares --build-host ares --target-host ares --sudo --show-trace
```

`test` активирует новую конфигурацию, но не делает ее загрузочной по
умолчанию. Это режим для проверки.

Чтобы применить конфигурацию постоянно, используй `switch`:

```sh
nix run nixpkgs#nixos-rebuild -- switch --flake .#ares --build-host ares --target-host ares --sudo --show-trace
```

Для других машин схема такая же: меняется flake-атрибут и имя удаленного хоста.

## Полезные проверки

Посмотреть outputs flake:

```sh
nix flake show --no-write-lock-file
```

Запустить проверки flake без полной сборки систем:

```sh
nix flake check --no-build
```
