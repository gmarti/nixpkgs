{ coreutils, dpkg, fetchurl, file, ghostscript, gnugrep, gnused,
makeWrapper, perl, pkgs, lib, stdenv, which }:

stdenv.mkDerivation rec {
  pname = "mfcl8650cdwlpr";
  version = "1.1.2-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf101088/${pname}-${version}.i386.deb";
    sha256 = "043f0v51bbr9l952smzxlr52k8933s64z5qvwp4z2ry08jqng4rw";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    dpkg-deb -x $src $out

    dir=$out/opt/brother/Printers/mfcl8650cdw
    filter=$dir/lpd/filtermfcl8650cdw

    substituteInPlace $filter \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "BR_PRT_PATH =~" "BR_PRT_PATH = \"$dir/\"; #" \
      --replace "PRINTER =~" "PRINTER = \"mfcl8650cdw\"; #"

    wrapProgram $filter \
      --prefix PATH : ${lib.makeBinPath [
      coreutils file ghostscript gnugrep gnused which
      ]}

    # need to use i686 glibc here, these are 32bit proprietary binaries
    interpreter=${pkgs.pkgsi686Linux.glibc}/lib/ld-linux.so.2
    patchelf --set-interpreter "$interpreter" $dir/lpd/brmfcl8650cdwfilter
  '';

  meta = {
    description = "Brother MFC-L8650CDW LPR printer driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.fuzzy-id ];
    platforms = [ "i686-linux" ];
  };
}
