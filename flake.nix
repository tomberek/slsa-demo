{
  description = "A SLSA demo flake";
  inputs.cyclonedx.url = "github:sudo-bmitch/convert-nix-cyclonedx";

  outputs = { self, cyclonedx , nixpkgs }: {

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
    packages.x86_64-linux.toReport = with nixpkgs.legacyPackages.x86_64-linux;
      stdenv.mkDerivation {
      name = "toReport";
      passthru = with builtins; (mapAttrs (n: v:
            (import ./default.nix {
              program = v;
              inherit system;
              pkgs = nixpkgs.legacyPackages.${system};
            }).runtimeReport
          )) nixpkgs.legacyPackages.${system};
    };
    packages.x86_64-linux.toSBOM = with nixpkgs.legacyPackages.x86_64-linux;
      stdenv.mkDerivation {
      name = "toSBOM";
      passthru = with builtins; (mapAttrs (n: v:
      runCommand v.name {
        buildInputs = [ nixUnstable jq ];
        } ''
          export NIX_CONFIG='experimental-features = nix-command flakes'
          echo ${v.drvPath}
          export NIX_STATE_DIR=$(mktemp -d)
          ls -alh ${v.drvPath}
          nix --offline show-derivation ${v.drvPath} || true
          exit 2
          nix --offline show-derivation ${v.drvPath} --recursive | \
            ${cyclonedx.defaultPackage.x86_64-linux}/bin/convert-nix-cyclonedx | \
            jq
      '')) nixpkgs.legacyPackages.x86_64-linux;
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
