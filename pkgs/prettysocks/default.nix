{ inputs, config, pkgs, lib, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "prettysocks";
  version = inputs.prettysocks.rev;
  src = inputs.prettysocks;
  
  dontUnpack = true;
  # Skip setuptools, no setup.py
  dontUseSetuptools = true;
  
  # Python dependencies that are required at runtime
  propagatedBuildInputs = [
    (pkgs.python3.withPackages (pythonPackages: with pythonPackages; [ async-stagger ]))
  ];
  
  #postFixup = ''
  #substituteInPlace $out/bin/prettysocks \
  #  --replace "USE_BUILTIN_HAPPY_EYEBALLS = False" "USE_BUILTIN_HAPPY_EYEBALLS = True"
  #'';

  # Install phase: manually copy the script and make it executable
  installPhase = ''
    install -Dm755 ${src}/prettysocks.py $out/bin/prettysocks
  '';


  # Meta data
  meta = with lib; {
    description = "A tool for managing SOCKS5 proxies";
    license = licenses.mit;
  };
}

