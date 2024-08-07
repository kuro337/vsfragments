{
  description = "A flake for building and testing with Zig";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          name = "zig-project";
          src = self;
          nativeBuildInputs = [ pkgs.zig ];
          buildPhase = "zig build";
          checkPhase = "zig build test --summary all";
          installPhase = ''
            mkdir -p $out/bin
            cp zig-out/bin/* $out/bin/
          '';
        };

        devShell = pkgs.mkShell { buildInputs = [ pkgs.zig ]; };
      }
    );
}
