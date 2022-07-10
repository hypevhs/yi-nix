{
  outputs = { self, nixpkgs, flake-utils }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
      };
      set = "haskellPackages";
      project = returnShellEnv: (
        pkgs."${set}".developPackage {
          inherit returnShellEnv;
          name = "yi-custom";
          root = ./yi-config;
          modifier = drv: (
            pkgs.haskell.lib.addBuildTools drv (with pkgs."${set}"; if returnShellEnv then [
              cabal-install
            ] else [])
          );
        }
      );
      yi-custom = project false;
      yi-custom-dev = project true;
    in
    flake-utils.lib.eachDefaultSystem (system: {
      defaultPackage = yi-custom;
      devShell = yi-custom-dev;
    });
}
