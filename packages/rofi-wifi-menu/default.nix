{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
	name = "rofi-wifi-menu";

	src = "../configs/rofi/scripts/rofi-wifi-menu";

	nativeBuildInputs = [
		pkgs.makeWrapper
	];

	installPhase = ''
		mkdir -p $out/bin
		cp -r $src $out/bin
	'';

	postFixup = ''
		wrapProgram $out/bin/rofi-wifi-menu \
			--set PATH ${pkgs.lib.makeBinPath (with pkgs; [
				networkmanager
			])}
	'';
}