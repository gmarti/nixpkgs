{ coreutils, dpkg, fetchurl, gnugrep, gnused, makeWrapper,
mfcl8650cdwlpr, perl, lib, stdenv}:

stdenv.mkDerivation rec {
  pname = "mfcl8650cdwcupswrapper";
  version = "1.1.3-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf101089/${pname}-${version}.i386.deb";
    sha256 = "12p41lw0vck3540ql84spx8n2zwy6a14zmaaqxaz2gjr74lvrgn4";
  };

  nativeBuildInputs = [ dpkg makeWrapper ];

  dontUnpack = true;

  installPhase = ''
    dpkg-deb -x $src $out

    basedir=${mfcl8650cdwlpr}/opt/brother/Printers/mfcl8650cdw
    dir=$out/opt/brother/Printers/mfcl8650cdw

    substituteInPlace $dir/cupswrapper/cupswrappermfcl8650cdw \
      --replace /usr/bin/perl ${perl}/bin/perl \
      --replace "basedir =~" "basedir = \"$basedir/\"; #" \
      --replace "PRINTER =~" "PRINTER = \"mfcl8650cdw\"; #"

    wrapProgram $dir/cupswrapper/brother_lpdwrapper_mfcl8650cdw \
      --prefix PATH : ${lib.makeBinPath [ coreutils gnugrep gnused ]}

    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model

    ln $dir/cupswrapper/brother_lpdwrapper_mfcl8650cdw $out/lib/cups/filter
    ln $dir/cupswrapper/brother_mfcl8650cdw_printer_en.ppd $out/share/cups/model
    '';

  meta = {
    description = "Brother MFC-L8650CDW CUPS wrapper driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
    maintainers = [ lib.maintainers.fuzzy-id ];
  };
}
