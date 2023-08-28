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
    sha256 = "";
  };

	installPhase = ''
		mkdir -p $out/share/icons

		cp -r $src/dist $out/share/icons/Vimix-cursors
		cp -r $src/dist-white $out/share/icons/Vimix-cursors-white
	'';
}