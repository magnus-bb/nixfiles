{
  description = "Magnus Bendix Borregaard NixOS flake";

  inputs = {
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
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
  
  outputs = { nixpkgs, nur, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    user = "magnus";
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
