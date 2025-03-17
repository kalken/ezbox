{ ... }: 

{
  nixpkgs.overlays = [
    (final: prev: {
      # force htop to point unstable.htop
      # htop = prev.unstable.htop;
    })
  ];
}
