{
  flake ? import ./nix/flake-compat.nix { },
  pkgs ? import flake.inputs.nixpkgs { },
  toolchain ? "",
  ...
}@args:
let
  lib = pkgs.lib;

  toolchain-stdenv = pkgs.callPackage ./nix/choose-stdenv.nix {
    inherit toolchain;
  };
  stdenv = toolchain-stdenv;

  zug = pkgs.callPackage ./nix/zug.nix {
    inherit stdenv;
    withTests = true;
    withExamples = true;
    withDocs = stdenv.isLinux;
  };

in
pkgs.mkShell.override { stdenv = toolchain-stdenv; } {
  inputsFrom = [ zug ];
  packages =
    with pkgs;
    [ ccache ]
    ++ lib.optionals toolchain-stdenv.cc.isClang [ lldb ]
    ++ lib.optionals toolchain-stdenv.cc.isGNU [ gdb ];
  hardeningDisable = [ "fortify" ];
}
