{ pkgs ? import <nixpkgs> {} }:
pkgs.stdenv.mkDerivation {
	name = "rofi-wifi-menu";

	nativeBuildInputs = [
		pkgs.makeWrapper
	];

  src = ./rofi-wifi-menu.sh;

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

	postFixup = ''
		wrapProgram $out/bin/rofi-wifi-menu.sh \
			--set PATH ${pkgs.lib.makeBinPath (with pkgs; [
				networkmanager
			])}
	'';
}