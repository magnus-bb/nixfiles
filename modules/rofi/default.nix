{ config, pkgs, lib, ... }:
let
	mkShellPackage = with pkgs; { name, deps ? [] }: callPackage ({ pkgs ? import <nixpkgs> {} }:
		writeShellApplication {
			inherit name;

			runtimeInputs = deps;

			text = builtins.readFile ./${name};
		}) { };

	calculator = mkShellPackage { name = "calculator"; };

	power-menu =  mkShellPackage { name = "power-menu"; deps = [ pkgs.rofi-power-menu ]; };

	askpass = mkShellPackage { name = "askpass"; deps = [ pkgs.gnused ]; };

	run-command = mkShellPackage { name = "run-command"; deps = [ pkgs.kitty pkgs.zsh ]; };

	# Use `mkLiteral` in .rasi theme for string-like values that should show without
	# quotes, e.g.:
	# {
	#   foo = "abc"; => foo: "abc";
	#   bar = mkLiteral "abc"; => bar: abc;
	# };
	inherit (config.lib.formats.rasi) mkLiteral;
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
	rofi.iconTheme = lib.mkOption {
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
			#!font = "Arimo Nerd Font 14";
			terminal = "kitty";
			#!theme = "themes/everblush.rasi";
			theme = ../../configs/rofi/themes/spotlight-dark.rasi;
			plugins = with pkgs; [
				# rofi-calc
				# rofi-emoji
				(pkgs.rofi-calc.override {
					rofi-unwrapped = rofi-wayland-unwrapped;
				})
				(pkgs.rofi-emoji.override {
					rofi-unwrapped = rofi-wayland-unwrapped;
				})
			];
			extraConfig = {
				modi = "drun,run,calc,emoji";
				show-icons = true;
				icon-theme = config.rofi.iconTheme;
				scroll-method = 1;
			};
		};


		home.file = {
			".config/rofi" = {
				recursive = true;
				source = ../../configs/rofi;
			};

			".config/networkmanager-dmenu/config.ini".text = ''
				[dmenu]
				dmenu_command = rofi -dmenu -i
				# # Note that dmenu_command can contain arguments as well like:
				# # `dmenu_command = rofi -dmenu -i -theme nmdm`
				# # `dmenu_command = rofi -dmenu -width 30 -i`
				# # `dmenu_command = dmenu -i -l 25 -b -nb #909090 -nf #303030`
				# # `dmenu_command = fuzzel --dmenu`
				# rofi_highlight = <True or False> (Default: False) use rofi highlighting instead of '=='
				rofi_highlight = True 
				# compact = <True or False> # (Default: False). Remove extra spacing from display
				compact = True
				# pinentry = <Pinentry command>  # (Default: None) e.g. `pinentry-gtk`
				# wifi_chars = <string of 4 unicode characters representing 1-4 bars strength>
				wifi_chars = ▂▄▆█
				# wifi_icons = <characters representing signal strength as an icon>
				wifi_icons = 󰤯󰤟󰤢󰤥󰤨
				# format = <Python style format string for the access point entries>
				# format = {name}  {sec}  {bars}
				# # Available variables are:
				# #  * {name} - Access point name
				# #  * {sec} - Security type
				# #  * {signal} - Signal strength on a scale of 0-100
				# #  * {bars} - Bar-based display of signal strength (see wifi_chars)
				# #  * {icon} - Icon-based display of signal strength (see wifi_icons)
				# #  * {max_len_name} and {max_len_sec} are the maximum lengths of {name} / {sec}
				# #    respectively and may be useful for formatting.
				format = {name}  {sec}  {icon}
				# list_saved = <True or False> # (Default: False) list saved connections

				[dmenu_passphrase]
				# # Uses the -password flag for Rofi, -x for bemenu. For dmenu, sets -nb and
				# # -nf to the same color or uses -P if the dmenu password patch is applied
				# # https://tools.suckless.org/dmenu/patches/password/
				# obscure = True
				# obscure_color = #222222

				[pinentry]
				# description = <Pinentry description> (Default: Get network password)
				# prompt = <Pinentry prompt> (Default: Password:)

				[editor]
				# terminal = <name of terminal program>
				# gui_if_available = <True or False> (Default: True)

				[nmdm]
				# rescan_delay = <seconds>  # (seconds to wait after a wifi rescan before redisplaying the results)
			'';
		};

		home.packages = with pkgs; [
			rofi-pulse-select # rofi util for picking input / output devices (TODO: make this custom to be able to control rofi display)
			# own packages
			calculator
			power-menu
			askpass
			run-command
			networkmanager_dmenu
		];
  };
}