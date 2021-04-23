{ pkgs ? import <nixpkgs> { } }:

with pkgs;

let
  messctl = rustPlatform.buildRustPackage rec {
    pname = "messctl";
    version = "0.0.1";

    src = fetchFromGitHub {
      owner = "bonfire-networks";
      repo = pname;
      rev = "8421d5ee91b120f1fe78fe8b123fc0fdf59609ff";
      sha256 = "sha256-MniXkng8v30xzSC+cIZ+K6DWeJLCFDieXZioAQFU4/s=";
    };
    cargoSha256 = "sha256-z8SdQKME9/6O6ZRkNRI+vYZSf6fxAG4lz0Muv7876fY=";
  };

  # define packages to install with special handling for OSX
  shellBasePackages = [
    git
    beam.packages.erlang.elixir_1_11
    nodejs-15_x
    postgresql_13
    messctl
    # for NIFs
    rustfmt
    clippy
  ];

  shellBuildInputs = shellBasePackages ++ lib.optional stdenv.isLinux inotify-tools
    ++ lib.optionals stdenv.isDarwin
    (with darwin.apple_sdk.frameworks; [ CoreFoundation CoreServices ]);

  # define shell startup command
  shellHooks = ''
    # this allows mix to work on the local directory
    mkdir -p $PWD/.nix-mix
    mkdir -p $PWD/.nix-hex
    export MIX_HOME=$PWD/.nix-mix
    export HEX_HOME=$PWD/.nix-mix
    export PATH=$MIX_HOME/bin:$PATH
    export PATH=$HEX_HOME/bin:$PATH
    mix local.hex --force
    export LANG=en_US.UTF-8
    export ERL_AFLAGS="-kernel shell_history enabled"

    # postges related
    export PGDATA="$PWD/db"

    # elixir
    export MIX_ENV=dev
  '';

in

mkShell
{
  nativeBuildInputs = [ rustc cargo gcc ]; # for NIFs
  buildInputs = shellBuildInputs;
  shellHook = shellHooks;
  RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
}

