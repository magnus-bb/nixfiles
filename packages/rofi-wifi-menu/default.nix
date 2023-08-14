{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
	name = "rofi-wifi-menu";

	nativeBuildInputs = [
		pkgs.makeWrapper
	];

  src = ./rofi-wifi-menu;

  phases = [ "installPhase" "postFixup" ];

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin
  '';

	# buildPhase = '''';

	# installPhase = ''
	# 	mkdir -p $out/bin
	# 	cp -r rofi-wifi-menu $out/bin
	# '';

	# dontUnpack = true;

	postBuild = ''
		wrapProgram $out/bin/rofi-wifi-menu \
			--set PATH ${pkgs.lib.makeBinPath (with pkgs; [
				networkmanager
			])}
	'';
}