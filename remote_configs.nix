{
  fetchFromGitHub,
  rev,
  hash ? lib.fakeSHA256,
  lib,
  dir,
}: {
  src = fetchFromGitHub {
    owner = "MarlinFirmware";
    repo = "Configurations";
    rev = rev;
    sha256 = hash;
  };

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    cp -r config/examples/${dir} $out
  '';
}
