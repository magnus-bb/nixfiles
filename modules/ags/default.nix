{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.ags.homeManagerModules.default
  ];

  home.packages = with pkgs; [
    pkgs.unstable.bun
    dart-sass
    fd
    brightnessctl
    pkgs.unstable.swww
    inputs.matugen.packages.${system}.default
    slurp
    wf-recorder
    wl-clipboard
    wayshot
    swappy
    hyprpicker
    pavucontrol
    networkmanager
    gtk3
  ];

  programs.ags = {
    enable = true;
    # configDir = ../../packages/ags;
    configDir = null;
    extraPackages = with pkgs; [
      accountsservice
      gtksourceview
			webkitgtk
    ];
  };
}