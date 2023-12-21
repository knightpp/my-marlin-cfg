{
  fetchFromGitHub,
  lib,
  stdenv,
  platformio,
  configs,
  pioEnv ? "trigorilla_pro",
  rev ? "2.1.2.1",
}:
stdenv.mkDerivation {
  pname = "marlin-firmware-${pioEnv}";
  version = rev;

  src = fetchFromGitHub {
    owner = "MarlinFirmware";
    repo = "Marlin";
    rev = rev;
    sha256 = "sha256-UvpWzozPVMODzXhswfkdrlF7SGUlaa5ZxrzQNuHlOlM=";
  };

  nativeBuildInputs = [platformio];

  configurePhase = ''
    cp ${configs}/* Marlin/
  '';

  buildPhase = ''
    pio run --target build --environment ${pioEnv}
  '';

  installPhase = ''
    ls -l .pio/build/
    exit 1
  '';

  meta = with lib; {
    description = "Marlin is an optimized firmware for RepRap 3D printers based on the Arduino platform.";
    license = licenses.gpl3;
    maintainers = with maintainers; [knightpp];
    platforms = platforms.linux;
    homepage = "https://github.com/MarlinFirmware/Marlin";
  };
}
