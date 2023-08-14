{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "rofi-wifi-menu";

  runtimeInputs = [ pkgs.networkmanager ];

	text = builtins.readFile ./rofi-wifi-menu;
}