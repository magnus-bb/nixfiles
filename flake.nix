{
  description = "Magnus Bendix Borregaard NixOS flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nix user repository packages
    # nur = {
    #   url = "github:nix-community/NUR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    
    home-manager = {
      # url = "github:nix-community/home-manager/release-23.05";
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "github:hyprwm/Hyprland";

    spicetify-nix.url = "github:the-argus/spicetify-nix"; # theming for spotify

    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };
  
  outputs = { nixpkgs, nixpkgs-stable, nur, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    user = "magnus";
    overlay-stable = final: prev: {
      stable = import nixpkgs-stable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron-25.9.0" ];
        };
        # legacyPackages.${prev.system};
      };
    };
  in {
    # Available through 'nixos-rebuild --flake .#host'
    nixosConfigurations = {
      rmthinkpad-gnome = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs user; host = "rmthinkpad-gnome"; }; # Pass flake inputs to our config

        modules = [
          ./hosts/rmthinkpad-gnome/configuration.nix # system wide configuration

          ./hosts/rmthinkpad-gnome/hardware-configuration.nix # generated machine configuration ('nixos-generate-config')

          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./hosts/rmthinkpad-gnome/home.nix;
              # Use extraSpecialArgs to pass arguments to home.nix
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };

      # Hyprland
      rmthinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs user; host = "rmthinkpad"; }; # Pass flake inputs to our config

        modules = [
          # Allows the use of stable packages with pkgs.stable.<pkg>
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-stable ]; })

          ./hosts/rmthinkpad/configuration.nix # system wide configuration

          ./hosts/rmthinkpad/hardware-configuration.nix # generated machine configuration ('nixos-generate-config')

          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./hosts/rmthinkpad/home.nix;
              # Use extraSpecialArgs to pass arguments to home.nix
              extraSpecialArgs = { inherit inputs; };
            };
          }
        ];
      };
    };
  };
}
