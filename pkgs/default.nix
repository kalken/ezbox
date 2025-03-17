{inputs, pkgs, ...}: {
  # Define your custom packages here
  eznetns = pkgs.callPackage ./eznetns { inherit inputs; };
  prettysocks = pkgs.callPackage ./prettysocks { inherit inputs; };
  wg-tools = pkgs.callPackage ./wg-tools { inherit inputs; };
}
