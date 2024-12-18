{
  description = "Magnus Bendix Borregaard NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Nix user repository packages
    # nur = {
    #   url = "github:nix-community/NUR";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      # url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1"; # use this
    # hyprland.url = "github:hyprwm/Hyprland";
    # hyprland = {
    #   type = "github";
    #   owner = "hyprwm";
    #   repo = "Hyprland";
    #   rev = "fe7b748eb668136dd0558b7c8279bfcd7ab4d759"; #v0.39.1
    # };

    # hyprland-plugins = {
    #   url = "github:hyprwm/hyprland-plugins";
    #   inputs.hyprland.follows = "hyprland";
    # };

    # split-monitor-workspaces = {
    #   url = "github:Duckonaut/split-monitor-workspaces";
    #   inputs.hyprland.follows = "hyprland"; # <- make sure this line is present for the plugin to work as intended
    # };

    ags.url = "github:Aylur/ags/v1";
    matugen.url = "github:InioX/matugen?ref=v2.2.0"; # used by Aylur's ags dots

    # spicetify-nix.url = "github:Gerg-L/spicetify-nix"; # theming for spotify
		# Theming for spotify
		spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix.url = "github:danth/stylix/1ff9d37d27377bfe8994c24a8d6c6c1734ffa116"; # latest (2024-09-30) hadd a bug with regreet and cursorTheme, so I rolled back
  };
  
  outputs = { self, nixpkgs, unstable, stylix, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    user = "magnus";
    overlay-unstable = final: prev: {
      unstable = import unstable {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [ "electron-25.9.0" ];
          android_sdk.accept_license = true;
        };
        # legacyPackages.${prev.system};
      };
    };
  in {
    packages.x86_64-linux.default =
      nixpkgs.legacyPackages.x86_64-linux.callPackage ./packages/ags {inherit inputs;};

    # Available through 'nixos-rebuild --flake .#host'
    nixosConfigurations = {
      rmthinkpad-gnome = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs user; host = "rmthinkpad-gnome"; }; # Pass flake inputs to our config

        modules = [
          # Allows the use of unstable packages with pkgs.unstable.<pkg>
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })

          ./hosts/rmthinkpad-gnome/configuration.nix # system wide configuration

          ./hosts/rmthinkpad-gnome/hardware-configuration.nix # generated machine configuration ('nixos-generate-config')

          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./hosts/rmthinkpad-gnome/home.nix;
              # Use extraSpecialArgs to pass arguments to home.nix
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup"; # rename file collisions instead of erroring
            };
          }
        ];
      };

      # Hyprland
      rmthinkpad = nixpkgs.lib.nixosSystem {
        inherit system;

        specialArgs = { inherit inputs user; host = "rmthinkpad"; asztal = self.packages.${system}.default; }; # Pass flake inputs to our config

        modules = [
          # Allows the use of unstable packages with pkgs.unstable.<pkg>
          ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })

          stylix.nixosModules.stylix

          ./hosts/rmthinkpad/configuration.nix # system wide configuration

          ./hosts/rmthinkpad/hardware-configuration.nix # generated machine configuration ('nixos-generate-config')
          
          home-manager.nixosModules.home-manager {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${user} = import ./hosts/rmthinkpad/home.nix;
              # Use extraSpecialArgs to pass arguments to home.nix
              extraSpecialArgs = { inherit inputs; };
              backupFileExtension = "backup"; # rename file collisions instead of erroring
            };
          }
        ];
      };
    };
  };
}
