#  nix build '.?submodules=1#'

# git submodule add https://github.com/username/repo-name.git path/to/submodule

# git clone git@github.com:Hejsil/zig-clap.git
# git submodule add git@github.com:Hejsil/zig-clap.git dependencies/zig-clap

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

          buildPhase = ''
            # Resolves ReadOnly errors
              export HOME=$TMPDIR

              zig build
              if [ ! -d zig-out/bin ]; then
                echo "zig-out/bin directory not found. Build may have failed."
                exit 1
              fi
              echo 'bin contents'
              ls zig-out/bin/
              echo 'bin contents printed'
          '';

          checkPhase = ''
            zig build test --summary all --global-cache-dir $PWD/zig-cache --cache-dir $PWD/zig-cache --verbose
          '';

          installPhase = ''
            mkdir -p $out/bin
            cp -r zig-out/bin/* $out/bin/
          '';
        };

        devShell = pkgs.mkShell { buildInputs = [ pkgs.zig ]; };
      }
    );
}
