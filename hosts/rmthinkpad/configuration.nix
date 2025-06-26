# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, host, user, unstable, ... }:
{
  # You can import other NixOS modules here
  imports = [ 
    # If you want to use modules from other flakes (such as nixos-hardware):
    # inputs.hardware.nixosModules.common-cpu-amd
    # inputs.hardware.nixosModules.common-ssd

    # You can also split up your configuration and import pieces of it here:
    # ./users.nix (etc)

    ../../modules/rofi/system.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0; # don't show generation selection on boot unless SPACE is pressed while booting
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = host; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
	# networking.enableIPv6 = false; # Fixes bug with bun not being able to resolve packages.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  hardware = {
    # Logitech options with Solaar
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # control brightness with brillo
    brillo.enable = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Copenhagen";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_DK.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "da_DK.UTF-8";
    LC_IDENTIFICATION = "da_DK.UTF-8";
    LC_MEASUREMENT = "da_DK.UTF-8";
    LC_MONETARY = "da_DK.UTF-8";
    LC_NAME = "da_DK.UTF-8";
    LC_NUMERIC = "da_DK.UTF-8";
    LC_PAPER = "da_DK.UTF-8";
    LC_TELEPHONE = "da_DK.UTF-8";
    LC_TIME = "da_DK.UTF-8";
  };

  nixpkgs = {
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      permittedInsecurePackages = [ "electron-25.9.0" ];

      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);

      #? # enable nix user repository as nur.
      #? packageOverrides = pkgs: {
      #?  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      #?    inherit pkgs;
      #?  };
      #? };
    };
    # You can add overlays here
    # overlays = [
      # If you want to use overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    # ];
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      # Enable flakes and new 'nix' command
      experimental-features = "nix-command flakes";
      # Deduplicate and optimize nix store
      auto-optimise-store = true;

      # Use hyprland cache so we don't rebuild from source every time
      substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];

			download-buffer-size = 524288000; # https://github.com/NixOS/nix/issues/11728
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Containers
  virtualisation = {
    vmVariant = {
      # following configuration is added only when building VM with build-vm
      virtualisation = {
        memorySize =  4096;
        cores = 4;         
      };
    };

    libvirtd.enable = true;

    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };

    # podman = {
    #   enable = true;

    #   # Create a `docker` alias for podman, to use it as a drop-in replacement
    #   dockerCompat = true;

    #   dockerSocket.enable = true; 

    #   # Required for containers under podman-compose to be able to talk to each other.
    #   # For Nixos version > 22.11
    #   defaultNetwork.settings = {
    #    dns_enabled = true;
    #   };
    # };
  };

  stylix = {
    enable = true; # TODO: re-enable when this is fixed: https://github.com/nix-community/stylix/issues/1538
    polarity = "dark";
    # base16Scheme = "${pkgs.base16-schemes}/share/themes/penumbra-dark.yaml";
    base16Scheme = ../../configs/stylix/penumbra-dark.yaml;
    # image = ../../assets/wallpapers/abstract_ultrawide.png;

    cursor = {
      name = "Vimix Cursors";
			package = (pkgs.callPackage ../../packages/vimix-cursors { }); # custom package for theme;
      size = 24;
    };

    fonts = {
      monospace = {
        name = "FiraCode Nerd Font Mono";
        # package = (pkgs.nerdfonts.override { # Nerdfont Icons override
        #   fonts = [
        #     "FiraCode"
        #   ];
        # });
        package = pkgs.nerd-fonts.fira-code; # TODO: use after 25.05
      };

      sansSerif = {
        name = "Arimo Nerd Font";
        # package = (pkgs.nerdfonts.override { # Nerdfont Icons override
        #   fonts = [
        #     "Arimo"
        #   ];
        # });
				package = pkgs.nerd-fonts.arimo; # TODO: use after 25.05
      };

      sizes = {
        terminal = 11;
      };

    };

    opacity = {
      popups = 0.5;
      terminal = 0.8;
    };
  };

	programs.nix-ld.enable = true; # fixes nuxthub cloudflare workerd running locally


  programs.virt-manager.enable = true;

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland; # from flake
    portalPackage = inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # https://nixos.wiki/wiki/Thunar
  programs.thunar = {
    enable = true;
    plugins = with pkgs.xfce; [
      thunar-archive-plugin # zip, tar, etc in context menu
      thunar-volman # auto mount volumes (e.g. USB drives)
    ];
  };
  programs.xfconf.enable = true; # persist thunar preferences
  programs.file-roller.enable = true; # Neccessary for thunar-archive-plugin
  services.tumbler.enable = false; # thumbnails for thunar
  services.gvfs.enable = true; # Neccessary for thunar https://docs.xfce.org/xfce/thunar/unix-filesystem#gnome_virtual_file_system_gvfs


  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ]; # adds fileChooser to chrome etc (e.g. upload-file dialog)
    config = {
      common = {
        default = [
          "hyprland" # use xdg-desktop-portal-hyprland
          "gtk" # fall back to xdg-desktop-portal-gtk for interfaces hyprland portal does not support
        ];
      };
    };
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  services = {
    displayManager = {
      # Enable automatic login for the user.
      autoLogin.enable = true;
      autoLogin.user = user;
    };

    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      videoDrivers = ["displaylink"]; # this SHOULD enable displaylink and set necessary options (I think)

      displayManager = {
        gdm = {
          enable = true;
          wayland = true; # necessary for hyprland?
        };
      };
    };
    libinput = {
      # touchpad
      enable = true;
      # disabling mouse acceleration
      mouse = {
        accelProfile = "flat";
      };
      # disabling touchpad acceleration
      touchpad = {
        accelProfile = "flat";
      };
    };
    # Enable autodiscovery of network printers
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    # Enable powerprofilesctl to change between performance, balanced, and power-saver modes
    power-profiles-daemon.enable = true;

    upower = {
      enable = true;
      percentageLow = 25;
      percentageCritical = 15;
      percentageAction = 5;      
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      drivers = with pkgs; [ gutenprint cups-filters ];
    };
  };

  hardware.printers = {
    ensurePrinters = [
      {
        name = "Dias";
        location = "Bordfodboldrummet";
        deviceUri = "ipp://10.32.194.26/ipp";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "A4";
        };
      }
    ];
    ensureDefaultPrinter = "Dias";
  };

  # Fonts
  fonts.packages = with pkgs; [
    source-code-pro
    font-awesome          # Icons
    corefonts             # MS
    # (nerdfonts.override { # Nerdfont Icons override
    #   fonts = [
    #     "FiraCode"
    #   ];
    # })
		nerd-fonts.fira-code # TODO: use after 25.05
  ];

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable sound with pipewire.
  # hardware.pulseaudio.enable = false;
  services.pulseaudio.enable = false; # TODO: use this after 25.05
  hardware.enableAllFirmware = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber = {
      enable = true;
    };
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    # jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    ${user} = {
      isNormalUser = true;
      description = "Magnus Bendix Borregaard";
      shell = pkgs.zsh;
      extraGroups = [ 
        "networkmanager"
        "wheel"
        "video"
        "audio"
        "input"
        "camera"
        "docker" # makes docker rootless work
        "libvirtd" # makes virtmanager work without sudo
      ];
    };
  };

  # Allows users in the group "video" to change brightness by changing udev rules for /sys/class/backlight/%k/brightness
  programs.light.enable = true;

  # Disables dialog that asks for credentials when using git with HTTPS because it froze the whole system, even when credentials were saved in store
  programs.ssh.enableAskPassword = false;

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ zsh ]; # GDM only shows users that have their default shell set to a shell listed in /etc/shells. This adds the zsh package to /etc/shells
    
    variables = {
      EDITOR = "code";
      VISUAL = "code";
    };
    sessionVariables = {
      NIXOS_OZONE_WL = "1"; # tell electron apps to use wayland
    };

    # Adds .local/bin to PATH in case any programs end up there
    localBinInPath = true;

    # Files in /etc to create
    #!etc = {
    #!  # This file is needed for swaylock (and swaylock-effects) to work
    #!  "pam.d/swaylock".text = "auth include login";
    #!};

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      openconnect # VPN from terminal (e.g. "sudo -A openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect --useragent AnyConnect")
      polkit_gnome
      pulseaudio # this just installs command line tools like pactl, but the config uses pipewire
    ];
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
		3000
		57621 # https://nixos.wiki/wiki/Spotify
	];
  networking.firewall.allowedUDPPorts = [
		5353 # https://nixos.wiki/wiki/Spotify
	];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system = {
    stateVersion = "23.05"; # Did you read the comment?
    autoUpgrade = {
      enable = true;
      channel = "https://nixos.org/channels/nixos-unstable"; 
    };
  };
}
