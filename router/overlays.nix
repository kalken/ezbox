{ inputs, variables, ... }: 

{
  nixpkgs.overlays = [
    (final: prev: {
      # add all unstable packages to nixpkgs.unstable.<name>
      unstable = import inputs.nixpkgs-unstable {
        inherit (final) system;
        # allow allowUnfree 
        config.allowUnfree = final.config.allowUnfree;
      };
    })
    
    (final: prev: 
    # merge all packages from ../pkgs to nixpkgs
      import ../pkgs { pkgs = final;  inherit inputs; })
  ];
}
