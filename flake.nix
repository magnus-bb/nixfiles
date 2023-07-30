{
  description = "Magnus Bendix Borregaard NixOS flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixpkgs-un.url = "github:NixOS/nixpkgs/nixos-23.05";

    # Nix user repository packages
    nur.url = github:nix-community/NUR;
    
    home-manager = {
      url = "github:nix-community/home-manager";
      # home-manager.url = "github:nix-community/home-manager/release-23.05";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    # spicetify-nix.url = "github:the-argus/spicetify-nix";

    # TODO: Add any other flake you might need
    # hardware.url = "github:nixos/nixos-hardware";

    # Shameless plug: looking for a way to nixify your themes and make
    # everything match nicely? Try nix-colors!
    # nix-colors.url = "github:misterio77/nix-colors";
  };
  
  outputs = { nixpkgs, nur, home-manager, ... }@inputs: 
  let
    system = "x86_64-linux";
    host = "rmthinkpad";
    user = "magnus";
  in {
    # Available through 'nixos-rebuild --flake .#host'
    nixosConfigurations.${host} = nixpkgs.lib.nixosSystem {
      inherit system;

      specialArgs = { inherit inputs host user; }; # Pass flake inputs to our config

      modules = [
        # This adds a nur configuration option.
        # Use `config.nur` for packages like this:
        # ({ config, ... }: {
        #   environment.systemPackages = [ config.nur.repos.mic92.hello-nur ];
        # })
        nur.nixosModules.nur

        ./hosts/${host}/configuration.nix # system wide configuration

        ./hosts/${host}/hardware-configuration.nix # generated machine configuration ('nixos-generate-config')

        home-manager.nixosModules.home-manager {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.${user} = import ./hosts/${host}/home.nix;
            # Use extraSpecialArgs to pass arguments to home.nix
            extraSpecialArgs = { inherit inputs; };
          };
        }
      ];
    };
  };
}
