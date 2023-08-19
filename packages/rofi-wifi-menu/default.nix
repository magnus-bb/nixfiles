{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "rofi-wifi-menu";

  runtimeInputs = with pkgs; [ rofi-wayland gnused networkmanager ];

	text = builtins.readFile ./rofi-wifi-menu;
}