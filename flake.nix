{
  nixConfig = {
    extra-substituters = "https://cache.garnix.io";
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };

  inputs = {
    emanote.url = "github:srid/emanote";
    emanote.inputs.emanote-template.follows = "";
    nixpkgs.follows = "emanote/nixpkgs";
    flake-parts.follows = "emanote/flake-parts";
  };

  outputs = inputs@{ self, flake-parts, nixpkgs, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.emanote.flakeModule ];
      perSystem = { self', pkgs, system, ... }: {
        emanote = {
          # By default, the 'emanote' flake input is used.
          # package = inputs.emanote.packages.${system}.default;
          sites."default" = {
            layers = [{ path = ./.; pathString = "."; }];
            # port = 8080;
            # prettyUrls = true;
          };
        };
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nixpkgs-fmt
          ];
        };
        packages.image =
          let emanote = inputs.emanote.packages.${system}.default; in
          pkgs.dockerTools.buildImage {
            name = "emanote";
            tag = "latest";

            copyToRoot = [
              pkgs.bashInteractive
              pkgs.busybox
              emanote
            ];
            
            runAsRoot = ''
              mkdir -p /data
              mkdir -p /public
            '';

            config = {
              Cmd = [ "emanote" "gen" "/public" ];
              WorkingDir = "/data";
              Volumes = {
                "/data" = { };
                "/public" = { };
              };
            };
          };
        formatter = pkgs.nixpkgs-fmt;
      };
    };
}
