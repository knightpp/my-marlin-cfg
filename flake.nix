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
  in {
    packages = forAllSystems ({pkgs}: {
      default = pkgs.callPackage ./marlin.nix {
        pioEnv = "trigorilla_pro";
        rev = "2.1.2.1";
        configs = ./configs;
      };
    });

    devShells = forAllSystems ({pkgs}: {
      default = pkgs.mkShell {
        packages = [pkgs.platformio];
      };
    });

    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);
  };
}
