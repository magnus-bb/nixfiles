{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "power-menu";

  runtimeInputs = with pkgs; [ rofi-wayland rofi-power-menu ];

	text = builtins.readFile ./power-menu;
}