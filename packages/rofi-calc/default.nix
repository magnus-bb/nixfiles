{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "rofi-calc";

  runtimeInputs = with pkgs; [ rofi-wayland ];

	text = builtins.readFile ./rofi-calc;
}