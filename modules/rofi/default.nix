{ config, pkgs, iconTheme, ... }:
{
  # imports = [
    # Paths to other modules.
    # Compose this module out of smaller ones.
  # ];

  # options = {
    # Option declarations.
    # Declare what settings a user of this module module can set.
    # Usually this includes an "enable" option to let a user of this module choose.
  # };

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
				icon-theme = iconTheme;
				scroll-method = 1;
			};
		};
  };
}