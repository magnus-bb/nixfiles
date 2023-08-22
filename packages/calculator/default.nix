{ pkgs ? import <nixpkgs> {} }:
pkgs.writeShellApplication {
  name = "calculator";

  # runtimeInputs = with pkgs; [ rofi-wayland rofi-calc ];

	text = builtins.readFile ./calculator;
}