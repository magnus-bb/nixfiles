# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, host, user, ... }:
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
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = host; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

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

    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);

      #? # enable nix user repository as nur.
      #? packageOverrides = pkgs: {
      #?  nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      #?    inherit pkgs;
      #?  };
      #? };
    };
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
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Containers
  virtualisation = {
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

  programs.hyprland = {
    enable = true;
    package = inputs.hyprland.packages.${pkgs.system}.hyprland; # from flake
    portalPackage = pkgs.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      videoDrivers = ["displaylink"]; # this SHOULD enable displaylink and set necessary options (I think)

      displayManager = {
        sddm = {
          enable = true;
          enableHidpi = true;
          theme =  "sugar-dark";
        };
        # gdm = {
        #   enable = true;
        #   wayland = true; # necessary for hyprland?
        # };
        # Enable automatic login for the user.
        # autoLogin.enable = true;
        # autoLogin.user = user;
      };
    };
    # Enable CUPS to print documents.
    printing.enable = true;

    # Enable powerprofilesctl to change between performance, balanced, and power-saver modes
    power-profiles-daemon.enable = true;
  };

  # Fonts
  fonts.packages = with pkgs; [
    source-code-pro
    font-awesome          # Icons
    corefonts             # MS
    (nerdfonts.override { # Nerdfont Icons override
      fonts = [
        "FiraCode"
      ];
    })
  ];

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    audio.enable = true;
    pulse.enable = true;
    alsa = {
      enable = true;
      support32Bit = true;
    };
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    ${user} = {
      isNormalUser = true;
      description = "Magnus Bendix Borregaard";
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" "camera" "docker"];
      shell = pkgs.zsh;
    };
  };

  # Allows users in the group "video" to change brightness by changing udev rules for /sys/class/backlight/%k/brightness
  programs.light.enable = true;

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
    etc = {
      # This file is needed for swaylock (and swaylock-effects) to work
      "pam.d/swaylock".text = "auth include login";
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      openconnect # VPN from terminal (e.g. "sudo openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect")
      polkit_gnome
      pulseaudio # this just installs command line tools like pactl, but the config uses pipewire
      # wlr-randr
      (callPackage ../../packages/sddm-sugar-dark-theme { }) # sddm theme
      libsForQt5.qt5.qtgraphicaleffects # required for sddm theme
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
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
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
