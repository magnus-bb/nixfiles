{ stdenv
, lib
, fetchTarball
}:

# stdenvNoCC.mkDerivation rec {
stdenv.mkDerivation rec {
  pname = "libpcap-dev";
  version = "1.5.3";

  # src = fetchFromGitHub {
  #   owner = "vinceliuice";
  #   repo = "Vimix-cursors";
  #   rev = version;
  #   sha256 = "sha256-TfcDer85+UOtDMJVZJQr81dDy4ekjYgEvH1RE1IHMi4=";
  # };

  src = fetchTarball {
    url = http://www.tcpdump.org/release/libpcap-1.5.3.tar.gz;
    sha256 = "0wqd8sjmxfskrflaxywc7gqw7sfawrfvdxd9skxawzfgyy0pzdz6";
  };

  # buildPhase = ''
  
  # '';

	# installPhase = ''
  # 	mkdir -p $out/usr/nembuild

		

  #   cd /usr
  #   mkdir nembuild
  #   cd nembuild    
  #   wget http://www.tcpdump.org/release/libpcap-1.5.3.tar.gz
  #   tar -xf libpcap-1.5.3.tar.gz
  #   cd libpcap-1.5.3
  #   ./configure
  #   make && make install
	# '';
}