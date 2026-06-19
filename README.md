# NixOS машины

NixOS flake с конфигурациями машин из этого репозитория.

## Удаленный rebuild

Команды запускаются из корня репозитория.

Чтобы собрать и активировать конфигурацию `finland` на удаленной машине:

```sh
nix run nixpkgs#nixos-rebuild -- test --flake .#finland --build-host finland --target-host finland --sudo --show-trace
```

`test` активирует новую конфигурацию, но не делает ее загрузочной по
умолчанию. Это режим для проверки.

Чтобы применить конфигурацию постоянно, используй `switch`:

```sh
nix run nixpkgs#nixos-rebuild -- switch --flake .#finland --build-host finland --target-host finland --sudo --show-trace
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
