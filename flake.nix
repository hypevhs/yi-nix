{
  inputs = {
    flake-utils.url = github:numtide/flake-utils;
    git-ignore-nix.url = github:IvanMalison/gitignore.nix/master;
    nixpkgs = {
      url = github:NixOS/nixpkgs/a3962299f14944a0e9ccf8fd84bd7be524b74cd6;
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, git-ignore-nix }:
    let
      system = "x86_64-linux";
      npkgs = import nixpkgs { inherit system; };
      name = "yi";
      set = "haskellPackages";
      bldr = "callCabal2nix";
      buildA = self: super: n: s: b: p: {
        ${n} = self.${b} name (git-ignore-nix.lib.gitignoreSource p) { };
      };
      buildB = self: super: n: s: b: p: {
        ${n} = with npkgs; stdenv.mkDerivation {
          name = n;
          src = p;
          nativeBuildInputs = deps npkgs;
          buildPhase = b;
        };
      };

      # sub-dependencies
      deps = p: (with p.${set}; [
        gtk2hs-buildtools
      ]) // (with p; [
        cairo
        pango
        gtk2
        ghc
        icu.out
        ncurses.out
        pkgconfig
        glibcLocales
        which
        xsel
        zlib.out
      ]);

      overlay = self: super: {
        ${set} = super.${set}.override (old: {
          overrides = super.lib.composeExtensions (old.overrides or (_: _: { }))
            (self: super:

              # overrides {
              ((buildA self super name set bldr ./yi)

                // (buildA self super "yi-core" set bldr ./yi-core)
                // (buildA self super "yi-frontend-vty" set bldr ./yi-frontend-vty)
                // (buildA self super "yi-frontend-pango" set bldr ./yi-frontend-pango)
                // (buildA self super "yi-fuzzy-open" set bldr ./yi-fuzzy-open)
                // (buildA self super "yi-ireader" set bldr ./yi-ireader)
                // (buildA self super "yi-keymap-cua" set bldr ./yi-keymap-cua)
                // (buildA self super "yi-keymap-emacs" set bldr ./yi-keymap-emacs)
                // (buildA self super "yi-keymap-vim" set bldr ./yi-keymap-vim)
                // (buildA self super "yi-language" set bldr ./yi-language)
                // (buildA self super "yi-misc-modes" set bldr ./yi-misc-modes)
                // (buildA self super "yi-mode-haskell" set bldr ./yi-mode-haskell)
                // (buildA self super "yi-mode-javascript" set bldr ./yi-mode-javascript)
                // (buildA self super "yi-snippet" set bldr ./yi-snippet)

                ## buildA self super "yi-rope"            "haskellPackages" "callCabal2Nix" ./yi/yi-source/yi/yi-rope
              )
              # }
            );

        });
      };

    in
    { inherit overlay; } // flake-utils.lib.eachDefaultSystem (system: # leverage flake-utils
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay ];
        };
      in
      {
        defaultPackage = pkgs.${name};
        devShell = pkgs.mkShell {
          # development environment
          packages = p: [ p.${name} ];
          buildInputs = deps pkgs;
        };
      });
}
