{
  description = "My own blog site etc";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system} = {
        zenn = pkgs.buildEnv {
          name = "zenn";
          paths = [];
        };
        blog = pkgs.buildEnv {
          name = "blog";
          paths = [];
        };
      };

      apps.${system}.export-to-zenn = {
        type = "app";
        program = "${pkgs.writeShellScriptBin "export-to-zenn" ''
          exec ${pkgs.deno}/bin/deno run --allow-read --allow-write \
            "$PWD/scripts/export-to-zenn.ts" "$@"
        ''}/bin/export-to-zenn";
      };

      devShells.${system}.zenn = pkgs.mkShell {
        buildInputs = [
          pkgs.deno
        ];
      };
    };
}
