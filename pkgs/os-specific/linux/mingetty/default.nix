{ stdenv, fetchurl }:

stdenv.mkDerivation {
  name = "mingetty-1.08";

  src = fetchurl {
    url = mirror://sourceforge/mingetty/mingetty-1.08.tar.gz;
    sha256 = "05yxrp44ky2kg6qknk1ih0kvwkgbn9fbz77r3vci7agslh5wjm8g";
  };

  preInstall = ''
    mkdir -p $out/sbin $out/share/man/man8
    makeFlagsArray=(SBINDIR=$out/sbin MANDIR=$out/share/man/man8)
  '';

  meta = {
    homepage = https://sourceforge.net/projects/mingetty;
    platforms = stdenv.lib.platforms.linux;
  };
}
