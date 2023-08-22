{ config, pkgs, lib, ... }:
let
	calculator = pkgs.callPackage ({ pkgs ? import <nixpkgs> {} }:
		pkgs.writeShellApplication {
			name = "calculator";

			text = builtins.readFile ./calculator;
		}) { };

	power-menu = pkgs.callPackage ({ pkgs ? import <nixpkgs> {} }:
		pkgs.writeShellApplication {
			name = "power-menu";

			runtimeInputs = with pkgs; [ rofi-power-menu ];

			text = builtins.readFile ./power-menu;
		}) { };

	askpass = pkgs.callPackage ({ pkgs ? import <nixpkgs> {} }:
		pkgs.writeShellApplication {
			name = "askpass";

			runtimeInputs = with pkgs; [ gnused ];

			text = builtins.readFile ./askpass;
		}) { };
in
{
  # imports = [
    # Paths to other modules.
    # Compose this module out of smaller ones.
  # ];

  options = {
    # Option declarations.
    # Declare what settings a user of this module module can set.
    # Usually this includes an "enable" option to let a user of this module choose.

		# This allows us to pass in iconTheme, so we can control it from home.nix
		rofi.iconTheme= lib.mkOption {
      type = lib.types.str;
      example = "Papirus-Dark";
      description = ''
				The name of the installed icon theme to use for rofi.
      '';
    };
  };

  config = {
    # Option definitions.
    # Define what other settings, services and resources should be active.
    # Usually these are depend on whether a user of this module chose to "enable" it
    # using the "option" above. 
    # You also set options here for modules that you imported in "imports".

		programs.rofi = {
			enable = true;
			package = pkgs.rofi-wayland;
			font = "Arimo Nerd Font 14";
			# pass = {
			# 	enable = true;
			# 	stores = ["$HOME/passwords"];
			# };
			terminal = "kitty";
			theme = "themes/everblush.rasi";
			plugins = with pkgs; [
				rofi-calc
				rofi-emoji
			];

			extraConfig = {
				modi = "drun,run,calc,emoji";
				show-icons = true;
				icon-theme = config.rofi.iconTheme;
				scroll-method = 1;
			};
		};


		home.file.".config/rofi" = {
			recursive = true;
			source = ../../configs/rofi;
		};

		home.packages = with pkgs; [
			calculator
			power-menu
			askpass
		];
  };
}