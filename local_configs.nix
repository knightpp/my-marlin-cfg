{mkDerivation}:
mkDerivation {
  name = "custom-configs";
  src = ./configs;

  dontBuild = true;
  dontConfigure = true;
  dontFixup = true;

  installPhase = ''
    cp * $out/
  '';
}
