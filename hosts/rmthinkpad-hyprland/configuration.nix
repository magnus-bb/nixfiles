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

  # Logitech options with Solaar
  hardware = {
    logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };
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

      # Cache hyprland so we don't rebuild from source every time
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
    package = inputs.hyprland.packages.${pkgs.system}.hyprland;
    xwayland.enable = true;
  };

  services = {
    xserver = {
      # Enable the X11 windowing system.
      enable = true;

      displayManager = {
        gdm = {
          enable = true;
          wayland = true; # necessary for hyprland?
        };
        # Enable automatic login for the user.
        autoLogin.enable = true;
        autoLogin.user = user;
      };
      # Enable the GNOME Desktop Environment.
      desktopManager.gnome.enable = true;
      # Keyboard
      layout = "dk";
      xkbVariant = "";
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
    };
    # Enable CUPS to print documents.
    printing.enable = true;

    flatpak.enable = true;

    # Allows GNOME systray icons extension to work (https://nixos.wiki/wiki/GNOME)
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
  };

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

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
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users = {
    ${user} = {
      isNormalUser = true;
      description = "Magnus Bendix Borregaard";
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" "camera" "docker" "admin"];
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;

  environment = {
    shells = with pkgs; [ zsh ]; # GDM only shows users that have their default shell set to a shell listed in /etc/shells. This adds the zsh package to /etc/shells
    variables = {
      EDITOR = "code";
      VISUAL = "code";
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      openconnect # VPN from terminal (e.g. "sudo openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect")
      xdg-desktop-portal-hyprland # helps windows communicate in hyprland
    ];

    # GNOME apps I don't need
    gnome.excludePackages = with pkgs.gnome; [
      epiphany
      gedit
      yelp
      geary
      seahorse
    ];
  };



  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

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
