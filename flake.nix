{
  description = "My own blog site etc";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    let system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system}
    in
      packages.${system} = {
        zenn = ${pkgs}.buildEnv {
          name = "zenn";
        };
        blog = ${pkgs}.buildEnv {
          name = "blog";
        };
      };

      devShells.${system}.zenn = ${pkgs}.mkShell {
        buildInputs = [
          pkgs.deno
        ];
      };
    
      packages.${system}.default = self.packages.${system}.hello;
  };
}
