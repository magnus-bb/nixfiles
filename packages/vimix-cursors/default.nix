{ stdenvNoCC
, lib
, fetchFromGitHub
}:

stdenvNoCC.mkDerivation rec {
  pname = "vimix-cursor-theme";
  version = "2020-02-24";

  src = fetchFromGitHub {
    owner = "vinceliuice";
    repo = "Vimix-cursors";
    rev = version;
    sha256 = "sha256-TfcDer85+UOtDMJVZJQr81dDy4ekjYgEvH1RE1IHMi4=";
  };

	installPhase = ''
		mkdir -p $out/share/icons
		mkdir -p $out/.icons

		cp -r $src/dist $out/share/icons/Vimix\ Cursors
		cp -r $src/dist-white $out/share/icons/Vimix\ Cursors\ -\ White

		cp -r $src/dist $out/.icons/Vimix\ Cursors
		cp -r $src/dist-white $out/.icons/Vimix\ Cursors\ -\ White
	'';
}