{ inputs, pkgs, lib, config, ... }: 
let
 spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};

 iconTheme = "Papirus-Dark";
 gtkTheme = "";
in {
  imports = [
		inputs.spicetify-nix.homeManagerModules.default
		# inputs.ags.homeManagerModules.default
		../../modules/rofi
		../../modules/ags
	];

	home.stateVersion = "23.05";

	fonts.fontconfig.enable = true;

	home.file = {
		".config/ranger" = {
			recursive = true;
			source = ../../configs/ranger;
		};

		".local/share/applications/ranger.desktop" = {
			text = ''
				[Desktop Entry]
				Type=Application
				Name=ranger
				Comment=Launches the ranger file manager
				Icon=utilities-terminal
				Terminal=false
				Exec=kitty ranger
				Categories=ConsoleOnly;System;FileTools;FileManager
				MimeType=inode/directory;
				Keywords=File;Manager;Browser;Explorer;Launcher;Vi;Vim;Python
			'';
		};

		".config/cava" = {
			recursive = true;
			source = ../../configs/cava;
		};

		".config/waybar/scripts/get-power-profile" = {
			executable = true;
			source = ../../configs/waybar/scripts/get-power-profile;
		};
		".config/waybar/scripts/cycle-power-profile" = {
			executable = true;
			source = ../../configs/waybar/scripts/cycle-power-profile;
		};
		".config/waybar/scripts/spotify.sh" = {
			executable = true;
			source = ../../configs/waybar/scripts/spotify.sh;
		};

		".config/avizo" = {
			recursive = true;
			source = ../../configs/avizo;
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


		".config/swaylock" = {
			recursive = true;
			source = ../../configs/swaylock-effects;
		};

		# ".config/mako" = {
		# 	recursive = true;
		# 	source = ../../configs/mako;
		# };

		"Pictures/wallpapers" = {
			recursive = true;
			source = ../../assets/wallpapers;
		};

		#!".local/share/icons/Vimix Cursors" = {
		#!	recursive = true;
		#!	source = ../../assets/cursors/vimix-cursors;
		#!};

		#!".local/share/icons/Vimix Cursors - White" = {
		#!	recursive = true;
		#!	source = ../../assets/cursors/vimix-cursors-white;
		#!};
	};

	# Custom module that handles setup of rofi + plugins and custom scripts
	rofi.iconTheme = iconTheme;

	stylix = {
		targets = {
			vscode.enable = false;
			rofi.enable = false;
			btop.enable = true;
			firefox.enable = true;
			fzf.enable = true;
			swaylock.enable = false;
		};
	};

	wayland.windowManager.hyprland = {
		enable = true;
		systemd.variables = ["--all"]; # https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#programs-dont-work-in-systemd-services-but-do-on-the-terminal
		plugins = [
			# inputs.split-monitor-workspaces.packages.${pkgs.system}.split-monitor-workspaces
			# pkgs.hyprlandPlugins.hyprexpo
			# inputs.hyprland-plugins.packages.${pkgs.system}.hyprbars
		];

		# settings = {
		# 	general = {
		# 		"col.active.border" = lib.mkForce "rgb(${config.stylix.base16Scheme.base0E})";
		# 	};
		# };
	};
	
	programs = {
		# TODO: install udiskie OR udisks2 service AND/OR gnome-disks (if this does not also install udisks2)

		starship.enable = true;

		#! ags = {
		#! 	enable = true;

		#! 	# null or path, leave as null if you don't want hm to manage the config
		#! 	# configDir = ../../configs/ags;
		#! 	configDir = null;

		#! 	# additional packages to add to gjs's runtime
		#! 	extraPackages = with pkgs; [
		#! 		gtksourceview
		#! 		webkitgtk
		#! 		accountsservice
		#! 	];
		#! };

		#! Used by Aylur's ags dots
		#! fd = {
		#! 	enable = true;
		#! 	hidden = true;
		#! };

		waybar = {
			enable = true;
			settings = [{
				### GLOBAL ###
				layer = "top";
				spacing = 16;
				margin-top = 12;
				margin-left = 12;
				margin-right = 12;

				### LEFT ###
				modules-left = [
					"clock"
					"group/audio"
					"custom/spotify"
					# "hyprland/window"
				];

				clock = {
					format = " {:%H:%M}";
					tooltip-format = "{:%A %d. %b. %Y}";
				};

				"group/audio" = {
					orientation = "inherit";
					modules = [ "pulseaudio" "cava" ];
				};

				pulseaudio = {
					tooltip = false;
					format = "{icon} {volume}%";
					format-muted = "󰖁";
					on-click = "pavucontrol";
					on-click-right = "pactl set-sink-mute @DEFAULT_SINK@ toggle";
					reverse-scrolling = true;
					smooth-scrolling-threshold = 0.5;
					format-icons = {
						car = "";
						default = [ "" "" "" ];
						handsfree = "󱡏";
						headphones = "";
						headset = "";
						phone = "";
						portable = "";
					};
				};

				cava = {
					hide_on_silence = true;
					method = "pipewire";
					format-icons = ["▁" "▂" "▃" "▄" "▅" "▆" "▇" "█" ];
					framerate = 60;
					autosens = 1;
					bars = 12;
					sleep_timer = 5;
					stereo = true;
					noise_reduction = 0.5;
					input_delay = 5;
					bar_delimiter = 0;
				};

				"custom/spotify" = {
					interval = 1;
					return-type = "json";
					exec = "~/.config/waybar/scripts/spotify.sh";
					exec-if = "pgrep spotify";
					escape = true;
					on-click = "playerctl play-pause";
				};


				# "hyprland/window" = {
				# 	max-length = 130;
				# 	separate-outputs = true;
				# };

				### CENTER ###
				modules-center = [ "hyprland/workspaces" ];

				"hyprland/workspaces" = {
					format = "{icon}";
					format-icons = {
						active = "<span size=\"large\"></span>";
						default = "";
					};
					on-scroll-up = "hyprctl dispatch workspace r+1";
					on-scroll-down = "hyprctl dispatch workspace r-1";
					on-click = "activate";
					smooth-scrolling-threshold = 0.5;
					reverse-mouse-scrolling = true;
					# 	format = "<big>{windows}</big>";
					# 	format-window-separator = " ";
					# 	window-rewrite-default = "";
					# 	window-rewrite = {
					# 		"class<google-chrome>" = ""; # Windows whose classes are "chrome"
					# 		kitty = ""; # Windows that contain "kitty" in either class or title. For optimization reasons, it will only match against a title if at least one other window explicitly matches against a title.
					# 		code = "󰨞";
					# 	};
				};

				### RIGHT ###
				modules-right = [ 
					"tray"
					"network"
					"bluetooth"
					"idle_inhibitor"
					"backlight"
					"group/power-mode"
					"custom/power"
				];

				tray = {
					icon-size = 18;
					spacing = 8;
					reverse-direction = true;
				};

				network = {
					# "interface": "wlp2*", // (Optional) To force the use of this interface
					tooltip = false;
					format-wifi = "{icon} {essid}";
					format-ethernet = "󰈀";
					format-linked = "{ifname} (No IP) 󰈁";
					format-disconnected = "󱚵";
					format-icons = ["󰤯" "󰤟" "󰤢" "󰤥" "󰤨"];
					on-click = "networkmanager_dmenu";
				};

				bluetooth = {
					tooltip = false;
					format = "󰂯";
					format-disabled = "󰂲";
					format-off = "󰂲";
					format-on = "󰂯";
					format-connected = "󰂯 {device_alias}";
					format-connected-battery = "󰂯 {device_alias} {device_battery_percentage}%";
					on-click = "blueberry";
				};


				idle_inhibitor = {
					tooltip = false;
					format = "<big>{icon}</big>";
					format-icons = {
						activated = "󰅶";
						deactivated = "󰛊";
					};
				};

				backlight = {
					tooltip = false;
					format = "{icon} {percent}%";
					format-icons = ["󰃞" "󰃟" "󰃝" "󰃠"];
					reverse-scrolling = true;
					smooth-scrolling-threshold = 0.5;
				};

				"group/power-mode" = {
					orientation = "inherit";
					modules = [ "battery" "custom/power-profile"];
					drawer = {
						transition-duration = 300;
        		transition-left-to-right = false;
					};
				};

				battery = {
					states = {
							good = 95;
							warning = 30;
							critical = 20;
					};
					format = "{icon}  {capacity}%";
					format-charging = " {capacity}%";
					format-plugged = " {capacity}%";
					format-alt = "{time} {icon}";
					format-icons = ["" "" "" "" ""];
    		};

				"custom/power-profile" = {
					interval = "once";
					exec = "~/.config/waybar/scripts/get-power-profile";
					exec-on-event = false;
					return-type = "json";
					signal = 8;
					on-click = "~/.config/waybar/scripts/cycle-power-profile; pkill -SIGRTMIN+8 waybar";
				};

				"custom/power" = {
					format = "<big></big>";
					tooltip = false;
					on-click = "sleep 0.1 && power-menu"; # hack to fix rofi bug with panels on hyprland https://github.com/Alexays/Waybar/issues/1850
				};
			}];

			style = ''
				/* Everblush colors */
				@define-color bg rgba(20, 27, 30, 0.50);
				@define-color bg-lighter rgba(35, 42, 45, 0.75);
				@define-color border rgba(218, 218, 218, 0.4);
				@define-color muted #3D3D3D;
				@define-color red #e57474;
				@define-color green #8ccf7e;
				@define-color yellow #e5c76b;
				@define-color blue	#67b0e8;
				@define-color magenta #c47fd5;
				@define-color cyan	#6cbfbf;
				@define-color gray	#b3b9b8;
				@define-color fg #dadada;

				* {
					border: none;
					border-radius: 8px;
					font-family: "Arimo Nerd Font" ;
					font-weight: 600;
					font-size: 14px;
					min-height: 0px;
				}

				widget {
					background-color: transparent;
				}

				window#waybar {
					background: transparent;
					border: none;
				}

				window#waybar.hidden {
					opacity: 0.2;
				}

				#custom-logo {
					background: @bg;
					color: @fg;
					/* border: 2px solid @fg; */
					padding-top: 0px;
					padding-left: 0px;
					padding-left: 0px;
					padding-right: 0px;
					border-radius: 999px;
				}

				#window {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					font-family: "FiraCode Nerd Font Mono";
					background: @bg;
					color: @fg;
					border: 2px solid @fg;
				}

				#workspaces {
					border-radius: 8px;
					min-height: 28px;
				}

				#workspaces button {
					color: @fg; 
					background: @bg;
					border: 2px solid @border;
					border-bottom-color: @border;
					border-radius: 999px;
					padding-left: 4px;
					padding-right: 4px;
					padding-top: 0px;
					padding-bottom: 0px;
				}

				#workspaces button + button {
					margin-left: 8px;
				}

				#workspaces button.active {
					/*padding-left: 2px;
					padding-right: 2px;*/
					border-bottom-color: @border;
				}

				#workspaces button:hover {
					background: @gray;
				}

				#clock {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					color: @green;
					border: 2px solid @green;
					background: @bg;
				}


				#audio {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					border: 2px solid @green;
					color: @green;
					background: @bg;
				}

				#custom-spotify {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					color: @green;
					border: 2px solid @green;
					background: @bg;
				}

				#cava {
					margin-left: 10px;
					font-family: "bargraph";
				}

				#bluetooth {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					color: @blue;
					border: 2px solid @blue;
					background: @bg;
				}

				#network {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					color: @blue;
					border: 2px solid @blue;
					background: @bg;
				}

				#power-mode {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					color: @red;
					border: 2px solid @red;
					background: @bg;
				}

				#battery.charging, #battery.plugged {
					/*color: @green;
					border: 2px solid @green;*/
				}

				#battery.critical:not(.charging) {
					/*color: @red;*/
				}

				#idle_inhibitor {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					color: @yellow;
					border: 2px solid @yellow;
					background: @bg;
				}

				#backlight {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					color: @yellow;
					border: 2px solid @yellow;
					background: @bg;
				}

				#tray {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					color: @gray;
					border: 2px solid @gray;
					background: @bg;
				}

				#custom-power {
					padding-left: 10px;
					padding-right: 10px;
					border-radius: 8px;
					transition: none;
					color: @red;
					border: 2px solid @red;
					background: @bg;
				}

				#custom-power-profile {
					margin-right: 10px;
				}

				#custom-wallpaper {
					padding-left: 10px;
					padding-right: 5px;
					border-radius: 8px;
					transition: none;
					color: #161320;
					background: #C9CBFF;
				}
			'';
		};

		btop = {
			enable = true;
			settings = {
				theme_background = false;
				update_ms = 500;
				# more here: https://github.com/aristocratos/btop#configurability
			};
		};

		bat = {
			enable = true;
			config = {
				#!theme = "Visual Studio Dark+";
				italic-text = "always";
			};
		};

		git = {
			enable = true;
			userName  = "magbor";
			userEmail = "magbor@rm.dk";
			extraConfig = {
				core = {
					editor = "code";
				};
				pull.rebase = false;
			};
			lfs.enable = true;
		};

		go = {
			enable = true;
			package = pkgs.go;
		};
		
		kitty = {
			enable = true;

			shellIntegration.enableZshIntegration = true;

			theme = "GitHub Dark Colorblind";
			
			#!font = {
			#!	name = "FiraCode Nerd Font Mono";
			#!	package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" "Arimo" ]; });
			#!};

			keybindings = {
				"ctrl+v" = "paste_from_clipboard";
			};

			settings = {
				cursor_shape = "beam";
				window_padding_width = 8;
				inactive_text_alpha = "0.9";
				hide_window_decorations = "yes";
				#!background_opacity = "0.7";
				editor = ".";
			};
		};

		fzf.enable = true;

		zsh = {
			enable = true;
			enableCompletion = true;
			autocd = true;
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
				relags = "ags -q && hyprctl dispatch exec ags";

				zshreload = "source ~/.zshrc";

				rmvpn = "sudo -A openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect --useragent=AnyConnect";

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

				# git
				g = "git";
				gaa = "git add .";
				gc = "git commit";
				gcm = "git commit -m";
				gcam = "git commit -a -m";
				gamend = "git commit --amend";
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
				dev = "pnpm dev";

				# KITTY
				# Show images in term
				icat = "kitty +kitten icat"; # followed by image file name
				# Download / upload files from / to remote (also works with directories)
				upload = "kitty +kitten transfer"; # then local path and remote path
				download = "kitty +kitten transfer --direction=receive"; # then remote path and local path
				sshkitty = "kitty +kitten ssh"; # fixes ssh issues by copying terminfo files to the server

				# Misc.
				weather = "curl wttr.in/lystrup";
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
				gdb() { # git delete branch
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

				# fzf plugin (ctrl + r to search history & ctrl + t to search disk)
				if [ -n "''${commands[fzf-share]}" ]; then
					source "$(fzf-share)/key-bindings.zsh"
					source "$(fzf-share)/completion.zsh"
				fi

				# Zsh options
				setopt correct						# Asks if you want to correct misspelled commands
				setopt rcexpandparam      # Array expansion with parameters
				setopt nocheckjobs        # Don't warn about running processes when exiting
				setopt numericglobsort    # Sort filenames numerically when it makes sense
				setopt nobeep             # No beep
				setopt appendhistory      # Immediately append history instead of overwriting
				setopt histignorealldups  # If a new command is a duplicate, remove the older one
				setopt autocd             # if only directory path is entered, cd there.
				setopt auto_pushd					# cd will actually use 'pushd' which allows the use of 'popd' that will take you back to your last directory (can be chained, which 'cd -' cannot)
				setopt pushd_ignore_dups
				setopt pushdminus

				# Completion options
				zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'       # Case insensitive tab completion
				zstyle ':completion:*' rehash true                              # automatically find new executables in path 
				zstyle ':completion:*' list-colors "''${(s.:.)LS_COLORS}"         # Colored completion (different colors for dirs/files/etc)
				zstyle ':completion:*' completer _expand _complete _ignored _approximate
				zstyle ':completion:*' menu select
				zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
				zstyle ':completion:*:descriptions' format '%U%F{cyan}%d%f%u'
				# Speed up completions
				zstyle ':completion:*' accept-exact '*(N)'
				zstyle ':completion:*' use-cache on
				zstyle ':completion:*' cache-path ~/.cache/zcache
			'';
		};

		spicetify = {
      enable = false;

      theme = spicePkgs.themes.ziro;

      enabledExtensions = with spicePkgs.extensions; [
        fullAppDisplay
        shuffle
        hidePodcasts
				trashbin
				powerBar
				skipOrPlayLikedSongs
      ];
    };

		vscode = {
			enable = true;
			# allow extensions to be handled outside of this config
			mutableExtensionsDir = true; 

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

		k9s = {
			enable = true;
			settings = {

			};
		};
	};

	gtk = {
		enable = true;
		
		iconTheme = {
		  name = iconTheme;
		  package = pkgs.papirus-icon-theme;
		};

		#!theme = {
		#!	name = gtkTheme;
		#!	package = (pkgs.callPackage ../../packages/everblush-gtk-theme { }); # custom package for theme
		#!};

		#!cursorTheme = {
		#!	name = "Vimix Cursors";
		#!	package = (pkgs.callPackage ../../packages/vimix-cursors { }); # custom package for theme;
		#!};

		gtk2.extraConfig = ''
			gtk-application-prefer-dark-theme=1
		'';

		gtk3.extraConfig = {
			gtk-application-prefer-dark-theme = 1;
		};

		gtk4.extraConfig = {
			gtk-application-prefer-dark-theme = 1;
		};
	};

	home.sessionVariables.GTK_THEME = gtkTheme;

	# Configuration manager (made for GSettings)
	dconf = {
		enable = true; # allow gnome settings with dconf

		settings = {
			# Configuration to make virtmanager work
			"org/virt-manager/virt-manager/connections" = {
				autoconnect = ["qemu:///system"];
				uris = ["qemu:///system"];
			};

			# Tells xdg-desktop-portal-gtk to tell chrome to prefer dark mode on webpages
			"org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
			};
		};
	};

	xdg = {
		# Set default file picker etc
		mimeApps = {
			enable = true;
			associations = {
				added = {
					"inode/directory" = "thunar.desktop";
					"application/pdf" = "org.gnome.Papers.desktop";
					"application/sql" = "mysql-workbench.desktop;code.desktop";
					"image/svg+xml" = "code.desktop";
					"text/vnd.trolltech.linguist" = "code.desktop";
				};
				removed = {
					"inode/directory" = "code.desktop";
				};
			};
			defaultApplications = {
				"inode/directory" = "thunar.desktop";
				"text/html" = "google-chrome.desktop";
				"x-scheme-handler/http" = "google-chrome.desktop";
				"x-scheme-handler/https" = "google-chrome.desktop";
				"x-scheme-handler/about" = "google-chrome.desktop";
				"x-scheme-handler/unknown" = "google-chrome.desktop";
			};
		};
	};

	home.packages = with pkgs; [
		# DE
		qt6.qtwayland # to make qt apps work
		libsForQt5.qt5.qtwayland # to make qt apps work
		swww # wallpapers
		polkit_gnome # authentication agent
		swaylock-effects # lock screen
		swayidle # automatic locking of screen, turning off screen and suspension
		wtype # allows programs to send keystrokes and mouse clicks etc (for pasting emojis with rofi-emoji)
		cliphist # clipboard manager
		wl-clip-persist # makes sure clipboard is not cleared when closing programs on wayland
		wl-clipboard # dependency of cliphist
		libnotify # enables notify-send
		playerctl # control music playback (pause, skip etc)
		blueberry # gnome's bluetooth frontend
		pavucontrol # sound configuration
		ripdrag # drag and drop files from terminal
		avizo # OSD with volume and brightness control
		poweralertd # show notifications when battery is low on pc and devices (uses upower and notification daemon)
		networkmanagerapplet # network picker in waybar
		ffmpegthumbnailer # maybe necessary for thumbnails in thunar for videos?
		xfce.tumbler # necessary for tumbler thumbnails, maybe services.tumbler is not?
		caffeine-ng # Systray caffeine

		# Utilities
		hyprpicker # color picker
		hyprcursor
		kazam # screen recorder
		grim # screenshot util
		slurp # screen area selector (to be used with grim, wl-screenrec etc)
		swappy # gui for annotating images
		killall # helps close all apps with a name (used in hotkeys to toggle rofi)
		jq # json processer used by some eww widgets
		unzip

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
		wdisplays # GUI for setting monitors
		google-chrome
		firefox
		obsidian
		discord
		figma-linux
		libreoffice-fresh
		# spellcheck packages for libreoffice
		hunspell
		hunspellDicts.en_US
		hunspellDicts.da_DK
		caprine-bin
		signal-desktop
		nextcloud-client
		quickemu # VM for windows 11
		# Terminal
		thefuck
		lsd # get exa instead
		ranger
		tty-clock
		cmatrix
		cava
		papers # gnome pdf viewer
		gnome.gnome-calculator
		spotify

		# Development
		nodejs_20
		nodePackages_latest.pnpm
		pkgs.unstable.bun
		python312
		ngrok
		oauth2-proxy
		bruno
		# postman
		kubectl
		kubectx
		kubeseal
		kubelogin-oidc
		wails # gui framework for Go
		openssl # makes postman work
		docker-compose
		lazydocker
		mysql-workbench
		mongodb-compass
		pkgs.unstable.android-studio-full
		
		# Assets
		material-symbols
	];
}
