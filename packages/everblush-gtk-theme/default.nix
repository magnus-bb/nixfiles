{ stdenvNoCC
, lib
, fetchFromGitHub
, gtk-engine-murrine
, ...
}:

stdenvNoCC.mkDerivation rec {
  pname = "everblush-gtk";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "Everblush";
    repo = "gtk";
    rev = "abb404ab409a999c4ef58dd63db6ba938f917dd8";
    sha256 = "sha256-cVEOjkUXTMYp/7adSrYQCZDQRmQAPP3/huKieRO4r0Q=";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

	phases = [ "installPhase" ];

	installPhase = ''
		mkdir -p $out/share/themes/Everblush

		ls -al $src

		cp -r $src/assets $out/share/themes/Everblush
		cp -r $src/gtk-3.0 $out/share/themes/Everblush
		cp -r $src/gtk-2.0 $out/share/themes/Everblush
	'';
}