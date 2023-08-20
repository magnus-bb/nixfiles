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
    sha256 = "";
  };

  propagatedUserEnvPkgs = [
    gtk-engine-murrine
  ];

	buildInputs = [
		sass
	];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
}