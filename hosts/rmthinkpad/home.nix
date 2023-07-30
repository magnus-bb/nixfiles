{ inputs, pkgs, lib, ... }: { # use lib.fakeSha256 as the sha256 for a github release and run to get the real sha256 to insert
	home.stateVersion = "23.05";

	fonts.fontconfig.enable = true;

	#* Use this to manage dotfiles
	# home.activation.linkDotfiles = lib.hm.dag.entryAfter [ "writeBoundary" ]
	#   ''
	#     ln -sfn ./ranger/rc.conf $HOME/.config/ranger/rc.conf
	#     ...
	#   '';
	#* Or something like this perhaps
	home.file = {
		".config/ranger/rc.conf".source = ../../ranger/rc.conf; # ranger config
		".config/ranger/plugins/ranger_devicons/__init__.py".source = ../../ranger/plugins/ranger_devicons/__init__.py; # ranger icons plugin
		".config/ranger/plugins/ranger_devicons/devicons.py".source = ../../ranger/plugins/ranger_devicons/devicons.py; # ranger icons plugin

		# # Links whole ranger directory dotfiles into .config/ranger
		# ".config/ranger" = {
		# 	recursive = true;
		# 	source = /etc/nixos/ranger; # ranger config
		# };
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

			theme = "GitHub Dark Colorblind";
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
				# ednix = "$EDITOR /etc/nixos/configuration.nix";

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
			"org/gnome/shell" = {
				disable-user-extensions = false;

				# `gnome-extensions list` to list extensions
				enabled-extensions = [
					"clipman@popov895.ukr.net"
					"blur-my-shell@aunetx"
					"gTile@vibou"
					"scroll-workspaces@gfxmonk.net"
					"vertical-workspaces@G-dH.github.com"
					"user-theme@gnome-shell-extensions.gcampax.github.com"
					"appindicatorsupport@rgcjonas.gmail.com"
				];

			};

			"org/gnome/shell/extensions/clipman" = {
				history-size = 25;
				toggle-menu-shortcut = [ "<Super>c" ];
				web-search-url = "https://google.com/?q=%s";
			};
			"org/gnome/shell/extensions/blur-my-shell" = {
				hacks-level = 3;
			};
			"org/gnome/shell/extensions/blur-my-shell/panel" = {
				unblur-in-overview = true;
			};
			"org/gnome/shell/extensions/gtile" = {
				insets-primary-bottom = 8;
				insets-primary-left = 8;
				insets-primary-right = 8;
				insets-primary-top = 8;
				insets-secondary-bottom = 8;
				insets-secondary-left = 8;
				insets-secondary-right = 8;
				insets-secondary-top = 8;
				window-margin = 8;
				theme = "Minimal Dark";
			};
			"org/gnome/shell/extensions/vertical-workspaces" = {
				dash-position = 2;
				dash-show-recent-files-icon = 0;
				dash-show-windows-icon = false;
				hot-corner-action = 0;
				hot-corner-fullscreen = 0;
				hot-corner-position = 0;
				overview-bg-blur-sigma = 40;
				overview-bg-brightness = 100;
				search-windows-enable = false;
				show-app-icon-position = 2;
				show-bg-in-overview = true;
				startup-state = 0;
			};
			"org/gnome/shell/extensions/net/gfxmonk/scroll-workspaces" = {
				indicator = true;
				scroll-delay = 50;
			};

			"org/gnome/shell/extensions/user-theme" = {
				name = "Layan-Dark";
			};

			"org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
			};

			"org/gnome/desktop/wm/preferences" = {
				resize-with-right-button = true;
			};

			"org/gnome/desktop/peripherals/touchpad" = {
				tap-to-click = true;
			};

			"org/gnome/desktop/wm/keybindings" = {
				switch-to-workspace-up = ["<Control><Super>Up"];
				switch-to-workspace-down = ["<Control><Super>Down"];
				maximize = ["<Super>M" "<Super>Up"];
				close = ["<Super>Q"];
				# switch-panels = ["<Shift><Control>Tab"]; # only rebound so ctrl+right-alt+tab can be bound to the overview (because logitech mx master mouse will trigger this keybind with thumb button)
			};

			# "org/gnome/desktop/input-sources" = {
			#   xkb-options = [ "lv3:ralt_alt" ]; # allows binding right-alt (used by logitech mx master mouse to show overview)
			# };

			"org/gnome/shell/keybindings" = {
				# toggle-overview = [ "<Control><Alt>Tab" ]; # logitech mx master thumb button sends this keybind
				show-screenshot-ui = [ "<Shift><Super>s" ];
			};

			"org/gnome/mutter" = {
				workspaces-only-on-primary = true;
				dynamic-workspaces = true;
				edge-tiling = true;
			};

			"org/gnome/desktop/calendar" = {
				show-weekdate = true;
			};

			"org/gnome/desktop/interface" = {
				clock-show-weekday = true;
			};

			# Shortcuts for launching Kitty and System Monitor on GNOME
			"org/gnome/settings-daemon/plugins/media-keys" = {
				calculator = [ "Calculator" ];
				home = [ "<Super>f" ];
				www = [ "<Super>b" ];

				custom-keybindings = [
					"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" # Kitty
					"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/" # System Monitor
				];
			};
			# Kitty
			"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
				binding = "<Super>T";
				command = "kitty";
				name = "Launch Kitty";
			};
			# System Monitor
			"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
				binding = "<Shift><Control>Escape";
				command = "gnome-system-monitor";
				name = "Launch System Monitor";
			};
		};
	};

	home.packages = with pkgs; [
		# GNOME
		gnome.dconf-editor
		gnome.gnome-tweaks
		gnomeExtensions.gtile
		gnomeExtensions.top-panel-workspace-scroll
		gnomeExtensions.blur-my-shell
		gnomeExtensions.vertical-workspaces
		gnomeExtensions.gsconnect
		gnomeExtensions.user-themes
		gnomeExtensions.clipman
		layan-gtk-theme

		# Apps
		# fixes slack screensharing with wayland
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
		vscode
		spotify
		obsidian
		discord

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
