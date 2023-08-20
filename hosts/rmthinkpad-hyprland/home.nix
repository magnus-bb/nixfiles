{ inputs, pkgs, lib, config, ... }: 
let
 spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;

 iconTheme = "Papirus-Dark";
in {
  imports = [
		inputs.spicetify-nix.homeManagerModule
	];

	home.stateVersion = "23.05";

	fonts.fontconfig.enable = true;

	home.file = {
		".config/ranger" = {
			recursive = true;
			source = ../../configs/ranger;
		};

		".config/cava" = {
			recursive = true;
			source = ../../configs/cava;
		};

		".config/hypr" = {
			recursive = true;
			source = ../../configs/hypr;
		};

		# For some reason, polkit_gnome does not link the binary out of the nix store
		"polkit-gnome/polkit-gnome-authentication-agent-1" = {
			executable = true;
			source = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
		};

		"Pictures/wallpapers" = {
			recursive = true;
			source = ../../assets/wallpapers;
		};

		".config/swaylock" = {
			recursive = true;
			source = ../../configs/swaylock-effects;
		};

		".config/swaync" = {
			recursive = true;
			source = ../../configs/swaync;
		};

		".config/rofi" = {
			recursive = true;
			source = ../../configs/rofi;
		};
		
		# ".config/mako" = {
		# 	recursive = true;
		# 	source = ../../configs/mako;
		# };

		# DOES NOT HAVE NERD FONT VERSION, USE ARIMO NERD FONT INSTEAD
  	# "local/share/fonts/ProductSans".source = lib.cleanSourceWith {
		# 	filter = name: _: (lib.hasSuffix ".ttf" (baseNameOf (toString name)));
		# 	src = pkgs.fetchzip {
		# 		url = "https://befonts.com/wp-content/uploads/2018/08/product-sans.zip";
		# 		sha256 = "sha256-PF2n4d9+t1vscpCRWZ0CR3X0XBefzL9BAkLHoqWFZR4=";
		# 		stripRoot = false;
		# 	};
		# };

		# ".config/eww" = {
		# 	recursive = true;
		# 	source = ../../dotfiles/eww;
		# };
	};

	services = {
		# Notification daemon
		# mako = {
		#  enable = true;
		# };

		# On-screen display for volume, brightness (and caps + num lock, but backend for caps lock and num lock does not work)
		swayosd = {
			enable = true;
		};
	};
	
	programs = {

		starship.enable = true;

		btop = {
			enable = true;
			settings = {
				theme_background = false;
				# more here: https://github.com/aristocratos/btop#configurability
			};
		};

		bat = {
			enable = true;
			config = {
				theme = "Visual Studio Dark+";
				italic-text = "always";
			};
		};

		git = {
			enable = true;
			userName  = "Magnus Bendix Borregaard";
			userEmail = "magnus.borregaard@gmail.com";
			extraConfig = {
				core = {
					editor = "code";
				};
			};
		};
		
		kitty = {
			enable = true;

			shellIntegration.enableZshIntegration = true;

			theme = "GitHub Dark Colorblind";
			
			font = {
				name = "FiraCode Nerd Font Mono";
				package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" "Arimo" ]; });
			};

			keybindings = {
				"ctrl+v" = "paste_from_clipboard";
			};

			settings = {
				cursor_shape = "beam";
				window_padding_width = 8;
				inactive_text_alpha = "0.9";
				hide_window_decorations = "yes";
				background_opacity = "0.7";
				editor = ".";
			};
		};

		zsh = {
			enable = true;
			plugins = [
				{
					name = "zsh-autosuggestions";
					src = pkgs.fetchFromGitHub {
						owner = "zsh-users";
						repo = "zsh-autosuggestions";
						rev = "v0.7.0";
						sha256 = "KLUYpUu4DHRumQZ3w59m9aTW6TBKMCXl2UcKi4uMd7w=";
					};
				}
				{
					name = "zsh-syntax-highlighting";
					src = pkgs.fetchFromGitHub {
						owner = "zsh-users";
						repo = "zsh-syntax-highlighting";
						rev = "0.7.1";
						sha256 = "gOG0NLlaJfotJfs+SUhGgLTNOnGLjoqnUp54V9aFJg8=";
					};
				}
			];
			oh-my-zsh = {
				enable = true;
				plugins = [
					"docker"          # aliases + autocomplete
					"docker-compose"  # aliases + autocomplete
					# "git"           # own aliases simpler?
					# "git-auto-fetch"  # automatically fetch remotes (not pull) when in repo
					"thefuck"         # fix mistakes
					"dotenv"          # auto source .env when cd-ing into directories
					"golang"          # aliases + autocomplete
					"helm"            # aliases + autocomplete
					"kubectl"         # aliases + autocomplete
					"npm"             # aliases + autocomplete
					"z"               # quickly navigate between places you have been
				];
			};
			# zplug = {
			#   enable = true;
			#   plugins = [
			#     { name = "marlonrichert/zsh-autocomplete"; } # down-key still not working, since it is overwritten by oh-my-zsh
			#   ];
			# };
			shellAliases = {
				sudo = "sudo -A"; # use rofi-askpass to type pw instead of typing in the terminal
				upnix = "sudo -A nixos-rebuild switch --flake /etc/nixos#";
				ednix = "$EDITOR /etc/nixos";

				zshreload = "source ~/.zshrc";

				rmvpn = "sudo -A openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect";

				# filesystem
				".." = "cd ..";
				"..." = "cd ../..";
				"...." = "cd ../../..";
				"....." = "cd ../../../..";
				"......" = "cd ../../../../..";

				# Better ls
				ls = "lsd";
				ll = "lsd -alF";
				la = "lsd -A";
				lsh = "lsd -a --hyperlink=auto"; # --hyperlink=auto allows click-to-download with kitty (also works on remote)

				# Better cat with syntax highlighting, git integration, and line numbers
				cat = "bat --paging=never"; # use -p to remove line numbers (for copy-pasting)

				nuke = "rm -rf";
				rm = "rm -i"; # ask confirmation

				# git
				g = "git";
				gaa = "git add .";
				gc = "git commit";
				gcm = "git commit -m";
				gcam = "git commit -a -m";
				gpl = "git pull";
				gps = "git push";
				grh = "git reset --hard HEAD~1";
				grs = "git reset --soft HEAD~1";
				gs = "git status";
				gu = "git restore --staged"; # unstage
				gr = "git restore";
				gb = "git branch";
				gcb = "git checkout";

				# NPM
				dev = "npm run dev";

				# KITTY
				# Show images in term
				icat = "kitty +kitten icat"; # followed by image file name
				# Download / upload files from / to remote (also works with directories)
				upload = "kitty +kitten transfer"; # then local path and remote path
				download = "kitty +kitten transfer --direction=receive"; # then remote path and local path
				sshkitty = "kitty +kitten ssh"; # fixes ssh issues by copying terminfo files to the server

				# Misc.
				weather = "curl wttr.in";
				dotenv = "export $(cat -p .env | xargs)"; # sources .env file from cwd
			};

			initExtra = ''
				# creates new branch of name $1 and syncs it with origin
				gnb() { # git new branch
					if [ -n "$1" ]
					then
						git checkout -b "$1"
						git push origin -u "$1"
					fi
				}
				# deletes branch of name $1 and syncs it with origin
				gdb() { # git new branch
					if [ -n "$1" ]
					then
						git push origin -d "$1"
						git branch -d "$1"
					fi
				}

				# Fast forwards all possible branches to the state of the remote
				gffwd() {
					REMOTES="$@";
					if [ -z "$REMOTES" ]; then
						REMOTES=$(git remote);
					fi
					REMOTES=$(echo "$REMOTES" | xargs -n1 echo)
					CLB=$(git rev-parse --abbrev-ref HEAD);
					echo "$REMOTES" | while read REMOTE; do
						git remote update $REMOTE
						git remote show $REMOTE -n \
						| awk '/merges with remote/{print $5" "$1}' \
						| while read RB LB; do
							ARB="refs/remotes/$REMOTE/$RB";
							ALB="refs/heads/$LB";
							NBEHIND=$(( $(git rev-list --count $ALB..$ARB 2>/dev/null) +0));
							NAHEAD=$(( $(git rev-list --count $ARB..$ALB 2>/dev/null) +0));
							if [ "$NBEHIND" -gt 0 ]; then
								if [ "$NAHEAD" -gt 0 ]; then
									echo " branch $LB is $NBEHIND commit(s) behind and $NAHEAD commit(s) ahead of $REMOTE/$RB. could not be fast-forwarded";
								elif [ "$LB" = "$CLB" ]; then
									echo " branch $LB was $NBEHIND commit(s) behind of $REMOTE/$RB. fast-forward merge";
									git merge -q $ARB;
								else
									echo " branch $LB was $NBEHIND commit(s) behind of $REMOTE/$RB. resetting local branch to remote";
									git branch -f $LB -t $ARB >/dev/null;
								fi
							fi
						done
					done
				}

				# Make sure keyup works with zsh-autocomplete
				bindkey "''${key[Up]}" up-line-or-search
				bindkey "''${key[Down]}" down-line-or-search

				# Make sure ctrl-left/right jumps words
				bindkey '^[[1;5D' backward-word
				bindkey '^[[1;5C' forward-word

				# Make sure ctrl-backspace/delete deletes whole words
				bindkey '^H' backward-kill-word
				bindkey '^[[3;5~' kill-word
			'';
		};

		spicetify = {
      enable = true;

      theme = spicePkgs.themes.Ziro;

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        hidePodcasts
				trashbin
				powerBar
				skipOrPlayLikedSongs
      ];
    };

		# App launcher / runner
		rofi = {
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

		vscode = {
			enable = true;
			# allow extensions to be handled outside of this config
			mutableExtensionsDir = true; # TODO: turn this off and handle all vscode conf in here 

			# extensions = [
				# e.g.: pkgs.vscode.extensions.bbenoist.nix
			# ];
			globalSnippets = {
				# e.g.:
				# fixme = {
				# 	body = [
				# 		"$LINE_COMMENT FIXME: $0"
				# 	];
				# 	description = "Insert a FIXME remark";
				# 	prefix = [
				# 		"fixme"
				# 	];
				# };
			};

			keybindings = [
				# e.g.:
				# {
				# 	key = "ctrl+c";
				# 	command = "editor.action.clipboardCopyAction";
				# 	when = "textInputFocus";
				# }
			];

			userSettings = {
				# Configuration written to Visual Studio Code’s settings.json.
			};
		};
	};

	gtk = {
		enable = true;
		
		iconTheme = {
		  name = iconTheme;
		  package = pkgs.papirus-icon-theme;
		};

		theme = {
			name = "Layan-Dark";
			package = pkgs.layan-gtk-theme;
		};

		# font = {
		#   name = "FiraCode Nerd Font Mono Medium";
		# };

		cursorTheme = {
			name = "Nordzy-cursors";
			package = pkgs.nordzy-cursor-theme;
		};

		gtk3.extraConfig = {
			Settings = ''
				gtk-application-prefer-dark-theme=1
			'';
		};

		gtk4.extraConfig = {
			Settings = ''
				gtk-application-prefer-dark-theme=1
			'';
		};
	};

	home.sessionVariables.GTK_THEME = "Layan-Dark";

	dconf = {
		enable = true; # allow gnome settings with dconf
		settings = {

		};
	};

	home.packages = with pkgs; [
		# DE
		eww-wayland # bar / panel
    wdisplays # GUI for setting monitors
		qt6.qtwayland # to make qt apps work
		libsForQt5.qt5.qtwayland # to make qt apps work
		swww # wallpapers
		polkit_gnome # authentication agent
		swaylock-effects # lock screen
		wtype # allows programs to send keystrokes and mouse clicks etc (for pasting emojis with rofi-emoji)
		cliphist # clipboard manager
		wl-clip-persist # makes sure clipboard is not cleared when closing programs on wayland
		wl-clipboard # dependency of cliphist
		swaynotificationcenter # notifications and control center
    libnotify # enables notify-send
		rofi-bluetooth # gui for bluetooth (needs rofi and bluez)
		rofi-pulse-select # rofi util for picking input / output devices
		# rofi-power-menu # rofi util for power off, reboot etc
		(callPackage ../../packages/rofi-wifi-menu { }) # gui for wifi selection
		(callPackage ../../packages/rofi-askpass { }) # gui for password prompts with sudo -A and SUDO_ASKPASS
		(callPackage ../../packages/power-menu { }) # gui for power off, reboot etc

		# socat # allows us to hook into the socket that shows which window is active (for window title in panel)
		# jq # json processor used by eww widget for workspaces
		# python312 # used for widgets in eww panel

		# fufexan's eww bar dependencies
		# inputs.fufexan.packages.x86_64-linux.gross
    material-symbols
		# bash
    # blueberry
    # bluez
    # brillo
    # coreutils
    # dbus
    # findutils
    # gawk
    # gnome.gnome-control-center
    # gnused
    # imagemagick
    # jaq
    # jc
    # networkmanager
    # pavucontrol
    # playerctl
    # procps
    # pulseaudio
    # ripgrep
    # socat
    # udev
    # upower
    # util-linux
    # wget
    # wireplumber
    # wlogout

		# Utilities
		hyprpicker # color picker
		grim # screenshot util
		slurp # screen area selector (to be used with grim)
		swappy # gui for annotating images
		killall # helps close all apps with a name (used in hotkeys to toggle rofi)

		# Apps
		# fixes slack screensharing with wayland and forces running under wayland
		(slack.overrideAttrs
			(default: {
				installPhase = default.installPhase + ''
					rm $out/bin/slack

					makeWrapper $out/lib/slack/slack $out/bin/slack \
					--prefix XDG_DATA_DIRS : $GSETTINGS_SCHEMAS_PATH \
					--prefix PATH : ${lib.makeBinPath [pkgs.xdg-utils]} \
					--add-flags "--enable-features=WebRTCPipeWireCapturer"
				'';
			})
		)
		google-chrome
		firefox
		# vscode # has a hm module
		obsidian
		discord
		figma-linux
		libreoffice-fresh
		# spellcheck packages for libreoffice
		hunspell
    hunspellDicts.en_US
    hunspellDicts.da_DK

		# Terminal
		thefuck
		lsd
		ranger
		tty-clock
		cmatrix
		cava

		# Development
		nodejs_20
		nodePackages_latest.pnpm
		bun
		# podman-compose
	];
}
