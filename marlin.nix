{
  fetchFromGitHub,
  lib,
  stdenv,
  platformio,
  configs,
  pioEnv ? "trigorilla_pro",
  rev,
  hash,
}:
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
    cp ${configs}/* Marlin/
  '';

  buildPhase = ''
    pio run --environment ${pioEnv}
  '';

  installPhase = ''
    cp .pio/build/${pioEnv}/firmware.* $out
  '';

  meta = with lib; {
    description = "Marlin is an optimized firmware for RepRap 3D printers based on the Arduino platform.";
    license = licenses.gpl3;
    maintainers = with maintainers; [knightpp];
    platforms = platforms.linux;
    homepage = "https://github.com/MarlinFirmware/Marlin";
  };
}
