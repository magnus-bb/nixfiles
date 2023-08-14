{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
	name = "rofi-wifi-menu";

	src = "./.";

	nativeBuildInputs = [
		pkgs.makeWrapper
	];

	installPhase = ''
		mkdir -p $out/bin
		cp -r $src/rofi-wifi-menu $out/bin
	'';

	postFixup = ''
		wrapProgram $out/bin/rofi-wifi-menu \
			--set PATH ${pkgs.lib.makeBinPath (with pkgs; [
				networkmanager
			])}
	'';
}