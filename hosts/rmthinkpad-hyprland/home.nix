{ inputs, pkgs, lib, config, ... }: 
let
 spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [
		inputs.spicetify-nix.homeManagerModule
	];

	home.stateVersion = "23.05";

	fonts.fontconfig.enable = true;

	# Dotfiles
	home.file = {
		".config/ranger" = {
			recursive = true;
			source = ../../dotfiles/ranger;
		};

		".config/cava" = {
			recursive = true;
			source = ../../dotfiles/cava;
		};

		".config/hypr" = {
			recursive = true;
			source = ../../dotfiles/hypr;
		};

		# For some reason, polkit_gnome does not link the binary out of the nix store
		"polkit-gnome/polkit-gnome-authentication-agent-1" = {
			executable = true;
			source = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
		};

		"Pictures/wallpapers" = {
			recursive = true;
			source = ../../dotfiles/assets/wallpapers;
		};

		# # Product Sans font used by fufexan's eww bar
  	# "${config.xdg.dataHome}/fonts/ProductSans".source = lib.cleanSourceWith {
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
		mako = {
			enable = true;
		};
	};

	programs = {

		starship.enable = true;

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

			# theme = "GitHub Dark Colorblind";
			
			font = {
				name = "FiraCode Nerd Font Mono";
				package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" "DroidSansMono" ]; });
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

			extraConfig = ''
				# EVERBLUSH THEME
				# Base colors
				foreground              #dadada
				background              #141b1e
				selection_foreground    #dadada
				selection_background    #2d3437

				# Cursor colors
				cursor                  #2d3437
				cursor_text_color       #dadada

				# Normal colors
				color0                  #232a2d
				color1                  #e57474
				color2                  #8ccf7e
				color3                  #e5c76b
				color4                  #67b0e8
				color5                  #c47fd5
				color6                  #6cbfbf
				color7                  #b3b9b8

				# Bright colors
				color8                  #2d3437
				color9                  #ef7e7e
				color10                 #96d988
				color11                 #f4d67a
				color12                 #71baf2
				color13                 #ce89df
				color14                 #67cbe7
				color15                 #bdc3c2

				# Tab colors 
				active_tab_foreground   #e182e0
				active_tab_background   #1b2224
				inactive_tab_foreground #cd69cc
				inactive_tab_background #232a2c
			'';
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
				upnix = "sudo nixos-rebuild switch --flake /etc/nixos/#";
				ednix = "$EDITOR /etc/nixos";

				zshreload = "source ~/.zshrc";

				rmvpn = "sudo openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect";

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
	};

	gtk = {
		enable = true;
		
		# iconTheme = {
		#   name = "Papirus-Dark";
		#   package = pkgs.papirus-icon-theme;
		# };

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
		nwg-drawer # launcher (like gnome search)
    wdisplays # GUI for setting monitors
		qt6.qtwayland # to make qt apps work
		libsForQt5.qt5.qtwayland # to make qt apps work
		swww # wallpapers
		# polkit_gnome # authentication agent

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
    libnotify # enables notify-send
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
		vscode # has a hm module
		# spotify: spicetify installs spotify too
		obsidian
		discord
		figma-linux

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
