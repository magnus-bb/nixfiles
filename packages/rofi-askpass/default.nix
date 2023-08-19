{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "rofi-askpass";

  runtimeInputs = [ pkgs.gnused ];

	text = builtins.readFile ./rofi-askpass;
}