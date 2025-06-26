# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, lib, config, pkgs, host, user, stable, ... }:
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
  boot.loader.timeout = 0; # don't show generation selection on boot unless SPACE is pressed while booting
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
      displayManager = {
        gdm = {
          enable = true;
          wayland = true;
        };
      };
      # Enable the X11 windowing system.
      enable = true;
      # Enable the GNOME Desktop Environment.
      desktopManager.gnome.enable = true;
      # Keyboard
      xkb = {
        variant = "";
        layout = "dk";
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
    # Enable CUPS to print documents.
    printing.enable = true;
    # Enable autodiscovery of network printers
    avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };

    flatpak.enable = true;

    # Allows GNOME systray icons extension to work (https://nixos.wiki/wiki/GNOME)
    udev.packages = with pkgs; [ gnome.gnome-settings-daemon ];
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
    nerd-fonts.fira-code; # TODO: use after 25.05
  ];

  # Configure console keymap
  console.keyMap = "dk-latin1";

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
      shell = pkgs.zsh;
      extraGroups = [ "networkmanager" "wheel" "video" "audio" "input" "camera" "docker"];
    };
  };

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

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    systemPackages = with pkgs; [
      openconnect # VPN from terminal (e.g. "sudo -A openconnect sslvpn.rm.dk/IT-RM --protocol=anyconnect --useragent AnyConnect")
    ];

    # GNOME apps I don't need
    gnome.excludePackages = with pkgs.gnome; [
      epiphany
      pkgs.gedit
      yelp
      geary
      seahorse
      gnome-music
      gnome-terminal
      tali
      iagno
      hitori
      atomix
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
  networking.firewall.allowedTCPPorts = [ 3000 ];
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
