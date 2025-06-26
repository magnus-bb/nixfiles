{ inputs, pkgs, lib, config, ... }: 
let
 spicePkgs = inputs.spicetify-nix.packages.${pkgs.system}.default;

  iconTheme = "Papirus-Dark";
 	gtkTheme = "Layan-Dark";
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

		"Pictures/wallpapers" = {
			recursive = true;
			source = ../../assets/wallpapers;
		};
	};
	
	programs = {
		starship.enable = true;

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
				theme = "Visual Studio Dark+";
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
		};

		go = {
			enable = true;
			package = pkgs.go;
		};
		
		kitty = {
			enable = true;

			shellIntegration.enableZshIntegration = true;

			theme = "GitHub Dark Colorblind";
			
			font = {
				name = "FiraCode Nerd Font Mono";
				# package = (pkgs.nerdfonts.override { fonts = [ "FiraCode" "Arimo" ]; });
				package = pkgs.nerd-fonts.fira-code; # TODO: use after 25.05
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
				upnix = "sudo nixos-rebuild switch --flake /etc/nixos/#";
				ednix = "$EDITOR /etc/nixos";

				zshreload = "source ~/.zshrc";

				rmvpn = "sudo -A openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect --useragent AnyConnect";

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

		# theme = {
		# 	name = gtkTheme;
		# 	package = pkgs.layan-gtk-theme;
		# };

		# font = {
		#   name = "FiraCode Nerd Font Mono Medium";
		# };

		cursorTheme = {
			name = "Vimix Cursors - White";
			package = (pkgs.callPackage ../../packages/vimix-cursors { }); # custom package for theme;
		};

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

	# home.sessionVariables.GTK_THEME = gtkTheme;

	dconf = {
		enable = true; # allow gnome settings with dconf

		settings = {
			"org/gnome/shell" = {
				disable-user-extensions = false;

				# `gnome-extensions list` to list extensions
				enabled-extensions = [
					"user-theme@gnome-shell-extensions.gcampax.github.com"
					"blur-my-shell@aunetx"
					"panel-workspace-scroll@polymeilex.github.io"
					"vertical-workspaces@G-dH.github.com"
					"appindicatorsupport@rgcjonas.gmail.com"
					"caffeine@patapon.info"
					"pop-shell@system76.com"
					"emoji-copy@felipeftn"
					"clipboard-indicator@tudmotu.com"
					"mprisLabel@moon-0xff.github.com"
					"compiz-windows-effect@hermes83.github.com"
					"no-overview@fthx"
				];
			};

			"/org/gnome/shell/extensions/com/github/hermes83/compiz-windows-effect" = {
				friction = 8.0;
				mass = 80.0;
				maximize-effect = true;
				resize-effect = true;
				speedup-factor-divider = 6.0;
				spring-k = 8.0;
			};
			

			"/org/gnome/shell/extensions/mpris-label" = {
				auto-switch-to-most-recent = true;
				divider-string = " | ";
				extension-place = "left";
				left-click-action = "play-pause";
				middle-click-action = "open-menu";
				left-padding = 0;
				right-padding = 0;
				remove-text-when-paused = false;
				use-album = false;
			};

			"/org/gnome/shell/extensions/pop-shell" = {
				active-hint = true;
				active-hint-border-radius = 8;
				gap-inner = 2;
				gap-outer = 2;
				mouse-cursor-focus-location = 4;
				smart-gaps = true;
				snap-to-grid = true;
				stacking-with-mouse = false;
				tile-by-default = true;
				# These remove hjkl bindings
				focus-left = ["<Super>Left"];
				focus-right = ["<Super>Right"];
				focus-up = ["<Super>Up"];
				focus-down = ["<Super>Down"];
			};

			"/org/gnome/shell/extensions/caffeine" = {
				show-indicator = "always";
			};

			"/org/gnome/shell/extensions/clipboard-indicator" = {
				cache-size = 10;
				disable-down-arrow = true;
				display-mode = 2;
				history-size = 50;
				toggle-menu = ["<Super>v"];
				topbar-preview-size = 30;
			};
			"org/gnome/shell/extensions/blur-my-shell" = {
				hacks-level = 3;
			};
			"org/gnome/shell/extensions/blur-my-shell/panel" = {
				unblur-in-overview = true;
			};
			"org/gnome/shell/extensions/vertical-workspaces" = {
				dash-position = 4; # hide dash in overview
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

			"org/gnome/shell/extensions/user-theme" = {
				# name = gtkTheme;
			};

			"org/gnome/desktop/interface" = {
				color-scheme = "prefer-dark";
				clock-show-weekday = true;
			};

			"org/gnome/desktop/calendar" = {
				show-weekdate = true;
			};

			"org/gnome/desktop/wm/preferences" = {
				resize-with-right-button = true;
			};

			"org/gnome/desktop/peripherals/pointingstick" = {
				accel-profile = "flat";
			};
			"org/gnome/desktop/peripherals/mouse" = {
				accel-profile = "flat";
			};
			"org/gnome/desktop/peripherals/touchpad" = {
				tap-to-click = true;
				accel-profile = "flat";
			};

			"org/gnome/desktop/wm/preferences" = {
				focus-mode = "sloppy";
			}; 

			"org/gnome/desktop/wm/keybindings" = {
				switch-to-workspace-up = ["<Control><Super>Up"];
				switch-to-workspace-down = ["<Control><Super>Down"];
				maximize = []; # Super + up should be used to change focus
				minimize = []; # There should be no minimizing with tiling
				toggle-maximized = ["<Super>M" "<Control><Alt>Tab"]; # logitech mx master thumb button sends this keybind
				close = ["<Super>Q"];
				toggle-fullscreen = ["F11"];
				switch-panels = ["<Shift><Control>Tab"]; # only rebound so ctrl+right-alt+tab can be bound to the overview (because logitech mx master mouse will trigger this keybind with thumb button)
			};

			"org/gnome/desktop/input-sources" = {
			  xkb-options = [ "lv3:ralt_alt" ]; # allows binding right-alt (used by logitech mx master mouse to show overview)
			};

			"org/gnome/shell/keybindings" = {
				# toggle-overview = [ "<Control><Alt>Tab" ]; # logitech mx master thumb button sends this keybind
				show-screenshot-ui = [ "Print" "<Shift><Super>S" ];
			};

			"org/gnome/mutter" = {
				workspaces-only-on-primary = true;
				dynamic-workspaces = true;
				edge-tiling = true;
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
		# DE
		gnome.dconf-editor
		gnome.gnome-tweaks
		# gnomeExtensions.gtile
		# gnomeExtensions.gsconnect
		# gnomeExtensions.top-panel-workspace-scroll # outdated
		gnomeExtensions.user-themes
		gnomeExtensions.blur-my-shell
		gnomeExtensions.panel-workspace-scroll
		gnomeExtensions.vertical-workspaces
		gnomeExtensions.appindicator
		gnomeExtensions.caffeine
		gnomeExtensions.pop-shell
		gnomeExtensions.emoji-copy
		gnomeExtensions.clipboard-indicator
		gnomeExtensions.mpris-label
		gnomeExtensions.compiz-windows-effect
		gnomeExtensions.no-overview
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
		obsidian
		discord
		figma-linux
		libreoffice-fresh
		# spellcheck packages for libreoffice
		hunspell
    hunspellDicts.en_US
    hunspellDicts.da_DK
		citrix_workspace
		caprine-bin
		nextcloud-client
		quickemu # VM for windows 11

		# Terminal
		thefuck
		lsd
		ranger
		tty-clock
		cmatrix
		cava
		unzip
		ripdrag # drag and drop files from terminal

		# Development
		nodejs_20
		nodePackages_latest.pnpm
		bun
		python312
		ngrok
		oauth2-proxy
		bruno
		kubectl
		kubectx
		kubeseal
		kubelogin-oidc
		wails # gui framework for Go
		openssl # makes postman work

		# Assets
    material-symbols
	];
}
