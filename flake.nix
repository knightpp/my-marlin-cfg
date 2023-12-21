{
  description = "My marlin config for Anycubic i3 Mega";

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
            overlays = [(import ./overlay.nix)];
          };
        });
  in {
    packages = forAllSystems ({pkgs}: {
      default = pkgs.callPackage ./marlin.nix {
        pioEnv = "trigorilla_pro";
        rev = "2.1.2.1";
        configs = pkgs.callPackage ./local_configs.nix {};
      };
    });

    # devShells = forAllSystems ({pkgs}: {
    #   default = pkgs.mkShell {
    #     packages = import ./pkgs.nix {inherit pkgs;};
    #   };
    # });

    formatter = forAllSystems ({pkgs, ...}: pkgs.alejandra);
  };
}
