{
  fetchFromGitHub,
  lib,
  stdenv,
  platformio,
  configs,
  pioEnv ? "trigorilla_pro",
  rev,
  hash,
}: let
  src = fetchFromGitHub {
    owner = "MarlinFirmware";
    repo = "Marlin";
    inherit rev;
    sha256 = hash;
  };

  deps = stdenv.mkDerivation {
    pname = "marlin-firmware-${pioEnv}-deps";
    version = rev;
    inherit src;

    nativeBuildInputs = [platformio];

    configurePhase = ''
      runHook preConfigure

      export HOME=$(mktemp -d)

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      pio pkg install --project-dir . --environment ${pioEnv}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      find $HOME/.platformio/ -type d -name __pycache__ -prune -exec rm -rf {} \;
      mkdir -p $out
      cp -r --reflink=auto $HOME/.platformio/{packages,platforms} $out/

      runHook postInstall
    '';

    dontFixup = true;

    outputHashAlgo = "sha256";
    outputHashMode = "recursive";
    outputHash = "sha256-AK9kBoDLY5i1vC6sEUbJ855rHUXim4LIgvHsHoAhk4o=";
  };
in
  stdenv.mkDerivation {
    pname = "marlin-firmware-${pioEnv}";
    version = rev;

    src = fetchFromGitHub {
      owner = "MarlinFirmware";
      repo = "Marlin";
      inherit rev;
      sha256 = hash;
    };

    nativeBuildInputs = [platformio];

    configurePhase = ''
      runHook preConfigure

      export HOME=$(mktemp -d)
      mkdir -p $HOME/.platformio
      cp -r --reflink=auto ${deps}/* $HOME/.platformio
      chmod -R u+rw $HOME/.platformio

      cp ${configs}/* Marlin/

      runHook postConfigure
    '';

    buildPhase = ''
      runHook preBuild

      pio run --environment ${pioEnv}

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp $PWD/.pio/build/${pioEnv}/firmware.* $out

      runHook postInstall
    '';

    passthru = {inherit deps;};

    meta = with lib; {
      description = "Marlin is an optimized firmware for RepRap 3D printers based on the Arduino platform.";
      license = licenses.gpl3;
      maintainers = with maintainers; [knightpp];
      platforms = platforms.linux;
      homepage = "https://github.com/MarlinFirmware/Marlin";
    };
  }
