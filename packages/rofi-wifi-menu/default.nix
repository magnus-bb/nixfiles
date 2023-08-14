{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
	name = "rofi-wifi-menu";

	src = "./.";

	nativeBuildInputs = [
		pkgs.makeWrapper
	];

	buildPhase = '''';

	installPhase = ''
		mkdir -p $out/bin
		cp -r rofi-wifi-menu $out/bin
	'';

	dontUnpack = true;

	postFixup = ''
		wrapProgram $out/bin/rofi-wifi-menu \
			--set PATH ${pkgs.lib.makeBinPath (with pkgs; [
				networkmanager
			])}
	'';
}