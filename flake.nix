{
  description = "My marlin config for Anycubic i3 Mega";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    # Systems supported
    allSystems = [
      "x86_64-linux"
      "aarch64-linux"
      # "x86_64-darwin"
      # "aarch64-darwin"
    ];

    # Helper to provide system-specific attributes
    forAllSystems = f:
      nixpkgs.lib.genAttrs allSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
          };
        });

    rev = "2.1.2.1";
    marlinHash = "sha256-UvpWzozPVMODzXhswfkdrlF7SGUlaa5ZxrzQNuHlOlM=";
    configTemplatePath = "Configurations/config/examples/AnyCubic/i3 Mega/Trigorilla Pro STM32";
    pioEnv = "trigorilla_pro";
  in {
    packages = forAllSystems ({pkgs}: {
      default = pkgs.callPackage ./marlin.nix {
        inherit rev;
        inherit pioEnv;
        hash = marlinHash;
        configs = ./configs;
      };

      genPatches = pkgs.writeShellScriptBin "gen-patches.sh" ''
        cp $PWD/Marlin/Marlin/Configuration*.h $PWD/configs
        git add $PWD/configs
        git commit -m "update configs"

        cp $PWD/configs/* "$PWD/${configTemplatePath}/"
        cd $PWD/Configurations/
        git diff --patch > $PWD/../patches/template-patch.patch
        git reset --hard HEAD
      '';

      build = pkgs.writeShellScriptBin "builds.sh" ''
        cd $PWD/Marlin
        ${pkgs.platformio}/bin/pio run --environment ${pioEnv}
        cp .pio/build/${pioEnv}/firmware.* ../
      '';
    });

    devShells = forAllSystems ({pkgs}: {
      default = pkgs.mkShell {
        packages = [pkgs.platformio];
      };
    });

    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);
  };
}
