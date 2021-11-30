{
  description = "A SLSA demo flake";

  outputs = { self, nixpkgs }: {

    packages.x86_64-linux.hello-sandbox = with nixpkgs.legacyPackages.x86_64-linux; runCommand "hello-sandbox" {
      buildInputs = [curl];
    } ''
      ls -alh /
      ls -alh /nix/store
      echo hello from sandbox
      curl --version
      curl https://example.com
    '';

    packages.x86_64-linux.example = with nixpkgs.legacyPackages.x86_64-linux; runCommand "example" {
      buildInputs = [curl];
      #outputHash = "sha256-6o+sfGX7WJsNU1YPUlH3T56bJDR43Laz6nm142RJyNk=";
      outputHash = "sha256-6x+sfGX7WJsNU1YPUlH3T56bJDR43Laz6nm142RJyNk=";
      outputHashAlg = "sha256";
    } ''
      curl -k -v https://example.com > $out
    '';

    packages.x86_64-linux.toDocker= with nixpkgs.legacyPackages.x86_64-linux; 
      stdenv.mkDerivation {
      name = "toDocker";
      buildCommand = ''
        echo hi > $out
      '';
      passthru = with builtins; (mapAttrs (n: v:
            nixpkgs.legacyPackages.${system}.dockerTools.buildLayeredImage {
              name = v.name;
              tag = "latest";
              contents = [ v ];
            }
          )) nixpkgs.legacyPackages.x86_64-linux;
    };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.hello-sandbox;

    defaultBundler = self.bundlers.toDockerImage;
    bundlers = {
      toDockerImage = {program, system}: nixpkgs.legacyPackages.${system}.dockerTools.buildLayeredImage {
          name = "test";
          tag = "latest";
          contents = [ (with builtins; dirOf (dirOf program)) ];
        };
    };

  };
}
