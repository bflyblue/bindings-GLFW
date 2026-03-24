{
  description = "bindings-GLFW";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];
      forallSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f (rec {
            inherit system;
            pkgs = nixpkgsFor system;
            haskellPackages = hpkgsFor system pkgs;
          })
        );
      nixpkgsFor = system: import nixpkgs { inherit system; };
      hpkgsFor =
        system: pkgs:
        with pkgs.haskell.lib;
        pkgs.haskell.packages.ghc912.override {
          overrides = self: super: {
            bindings-GLFW = pkgs.haskell.lib.overrideCabal
              (self.callCabal2nix "bindings-GLFW" ./. { })
              (drv: {
                doCheck = false; # tests require a display server
                configureFlags = (drv.configureFlags or [ ]) ++ [
                  "-fsystem-GLFW"
                  "-fWayland"
                ];
                libraryPkgconfigDepends = (drv.libraryPkgconfigDepends or [ ]) ++ [
                  pkgs.glfw3
                ];
              });
          };
        };
    in
    {
      packages = forallSystems (
        {
          system,
          pkgs,
          haskellPackages,
        }:
        {
          bindings-GLFW = haskellPackages.bindings-GLFW;
          default = self.packages.${system}.bindings-GLFW;
        }
      );
      devShells = forallSystems (
        {
          system,
          pkgs,
          haskellPackages,
        }:
        {
          bindings-GLFW = haskellPackages.shellFor {
            packages = p: [ self.packages.${system}.bindings-GLFW ];
            buildInputs = with haskellPackages; [
              cabal-install
            ];
          };
          default = self.devShells.${system}.bindings-GLFW;
        }
      );
    };
}
