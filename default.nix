{
  flake ? import ./nix/flake-compat.nix { },
  pkgs ? import flake.inputs.nixpkgs { },
}:

let
  inherit (pkgs) lib;
  inherit (import flake.inputs.gitignore { inherit lib; })
    gitignoreSource
    ;

  nixFilter = name: type: !(lib.hasSuffix ".nix" name);
  srcFilter =
    src:
    lib.cleanSourceWith {
      filter = nixFilter;
      src = gitignoreSource src;
    };

in
pkgs.callPackage ./nix/zug.nix { sources = srcFilter ./.; }
