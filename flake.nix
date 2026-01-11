{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    flake-utils.url = "github:numtide/flake-utils";
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      gitignore,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = nixpkgs.lib;

        toolchains = [
          "gnu"
          "llvm"
        ];
      in
      {
        packages = {
          default = pkgs.callPackage ./nix/zug.nix { sources = ./.; };

          zug = pkgs.callPackage ./nix/zug.nix { sources = ./.; };

          tests = pkgs.callPackage ./nix/zug.nix {
            sources = ./.;
            withTests = true;
            withExamples = true;
          };

          tests-debug = pkgs.callPackage ./nix/zug.nix {
            sources = ./.;
            withTests = true;
            withExamples = true;
            withDebug = true;
          };
        };

        devShells = {
          default = pkgs.callPackage ./shell.nix { };
        }
        // lib.attrsets.genAttrs toolchains (
          toolchain: pkgs.callPackage ./shell.nix { inherit toolchain; }
        );

        checks = self.packages.${system};
      }
    );
}
