{
  description = "ThingNix: A NixOS-based OS for IoT penetration testing and hardware hacking";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Hardware specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    
    # Home-manager for user environment configuration
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Useful for creating bootable ISO images
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-hardware, home-manager, nixos-generators, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      
      # Function to get pkgs for a specific system
      pkgsFor = system: import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Some pentesting tools may be unfree
      };
    in {
      nixosConfigurations = {
        # Basic ISO configuration
        thingnix = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./nixos/configurations/thingnix/default.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.thingnix = import ./nixos/home/thingnix.nix;
            }
          ];
          specialArgs = { inherit inputs; };
        };
      };

      # ISO images
      packages = forAllSystems (system: {
        iso = nixos-generators.nixosGenerate {
          inherit system;
          modules = [
            ./nixos/configurations/thingnix/default.nix
            {
              nixpkgs.config.allowUnfree = true;
            }
          ];
          format = "iso";
          specialArgs = { 
            nixpkgs.config.allowUnfree = true;
          };
        };
      });

      # Development shells
      devShells = forAllSystems (system:
        let pkgs = pkgsFor system;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              nix
              git
              nixos-generators
            ];
          };
        });
    };
}
