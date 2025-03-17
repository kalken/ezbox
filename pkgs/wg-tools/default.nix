{ inputs, config, pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "wg-tools";
  version = inputs.wg-tools.rev;
  src = inputs.wg-tools;

  # Python dependencies that are required at runtime
  propagatedBuildInputs = [
    (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [
      cryptography
    ]))
  ];

  dontUnpack = true;
  # Skip setuptools, no setup.py
  dontUseSetuptools = true;

  # nativeBuildInputs = [ pkgs.makeWrapper ];
  installPhase = ''
    install -Dm755 ${src}/wg-mullvad.py $out/bin/wg-mullvad
  '';

  # Meta data
  meta = with lib; {
    description = "A tool for managing mullvad WireGuard files";
    license = licenses.gpl3;
  };
}
