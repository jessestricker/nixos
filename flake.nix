{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    naersk.url = "github:nix-community/naersk";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    naersk,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages."${system}";
        naersk-lib = naersk.lib."${system}";
      in rec {
        # nix build
        packages.nixos = naersk-lib.buildPackage {
          pname = "nixos";
          root = ./.;
        };
        packages.default = packages.nixos;

        # nix run
        apps.nixos = flake-utils.lib.mkApp {
          drv = packages.nixos;
        };
        apps.default = apps.nixos;

        # nix develop
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [cargo rustfmt clippy];
        };

        # nix fmt
        formatter = pkgs.alejandra;
      }
    );
}
