{
  inputs = {
    # use nixpkgs revision with the last nonbroken build of yi-core
    nixpkgs.url = "nixpkgs/0026c79c5509d9d170e85cab71ed7c256b4b0c7b";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      set = "haskellPackages";
      project = returnShellEnv: system:
        let
          pkgs = import nixpkgs {
            inherit system;
          };
        in
        pkgs."${set}".developPackage {
          inherit returnShellEnv;
          name = "yi-custom";
          # ./yi-config is just a copy of github:yi/example-configs/yi-vim-vty-static/
          root = ./yi-config;
          modifier = pkgs.haskell.lib.compose.addBuildTools (with pkgs."${set}"; pkgs.lib.optional returnShellEnv [
            cabal-install
          ]);
        };
    in
    (
      flake-utils.lib.eachDefaultSystem (system: {
        packages.yi-custom = project false system;
        packages.default = self.packages."${system}".yi-custom;
        devShells.yi-custom = project true system;
        devShells.default = self.devShells."${system}".yi-custom;
      })
    ) // {
      overlays.yi-custom = final: prev: {
        yi-custom = self.packages."${final.system}".yi-custom;
      };
      overlays.default = self.overlays.yi-custom;
    };
}
