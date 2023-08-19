{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "rofi-askpass";

  runtimeInputs = with pkgs; [ rofi-wayland gnused ];

	text = builtins.readFile ./rofi-askpass;
}