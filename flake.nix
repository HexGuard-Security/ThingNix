{ 
  description = "ThingNix: A NixOS-based OS for IoT penetration testing and hardware hacking";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11"; # Stable 23.11
    
    # Hardware specific configurations
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    
    # Home-manager for user environment configuration
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11"; # Matching 23.11
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    # Useful for creating bootable ISO images - use a specific version tag
    nixos-generators = {
      url = "github:nix-community/nixos-generators/1.7.0"; # Use specific version tag
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
        config = {
          allowUnfree = true; # Some pentesting tools may be unfree
          permittedInsecurePackages = []; # Allow any insecure packages if needed
        };
      };
    in {
      nixosConfigurations = {
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

      packages = forAllSystems (system: 
        let 
          pkgs = pkgsFor system;
        in {
          iso = nixos-generators.nixosGenerate {
            inherit pkgs;
            # Use our custom ISO configuration that doesn't set nixpkgs.config
            modules = [ ./nixos/iso.nix ];
            format = "iso";
          };
        });

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
