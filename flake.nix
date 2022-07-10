{
  inputs = {
    # use nixpkgs revision with the last nonbroken build of yi-core
    nixpkgs.url = "nixpkgs/0026c79c5509d9d170e85cab71ed7c256b4b0c7b";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        set = "haskellPackages";
        pkgs = import nixpkgs {
          inherit system;
        };
        project = returnShellEnv: (
          pkgs."${set}".developPackage {
            inherit returnShellEnv;
            name = "yi-custom";
            # ./yi-config is just a copy of github:yi/example-configs/yi-vim-vty-static/
            root = ./yi-config;
            modifier = drv: (
              pkgs.haskell.lib.addBuildTools drv (with pkgs."${set}"; if returnShellEnv then [
                cabal-install
              ] else [ ])
            );
          }
        );
        yi-custom = project false;
        yi-custom-dev = project true;
      in
      {
        defaultPackage = yi-custom;
        devShell = yi-custom-dev;
      });
}
