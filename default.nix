let
  hostPkgs = import <nixpkgs> {};
  nixpkgs = (hostPkgs.fetchFromGitHub {
    owner = "NixOS";
    repo = "nixpkgs-channels";
    rev = "nixos-18.03";
    sha256 = "1qiihxa2qdrij735rglfrx24nhn72kby44lkm1dxph395qy8fg1h";
  });
in
  with import nixpkgs {
    overlays = [(self: super:
      {
        python3 = super.python3.override {
          packageOverrides = py-self: py-super: {
            matplotlib = py-super.matplotlib.override {
              enableTk = true;
              enableQt = true;
            };
          };
        };
      }
    )];
  };
  stdenv.mkDerivation {
    name = "RT-spectra-dev";
    buildInputs = [
      ffmpeg
      gcc
      gfortran
      python3Full
      python3Packages.click
      python3Packages.jupyter
      python3Packages.jupyterlab
      python3Packages.matplotlib
      python3Packages.numpy
      python3Packages.scipy
      zlib
    ];
    src = null;
    shellHook = ''
    export NINJA_STATUS="[Built edge %f of %t in %e sec]"
    SOURCE_DATE_EPOCH=$(date +%s)
    '';
  }
