{ stdenv }:

stdenv.mkDerivation (finalAttrs: {
  pname = "x86-64-level";
  version = "1.0.0";

  src = ./.;

  buildPhase = ''
    $CC main.c -o ${finalAttrs.pname} -s -flto -O2
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp ${finalAttrs.pname} $out/bin/${finalAttrs.pname}

    mkdir -p $out/share/man/man1
    cp ./manpage.1 $out/share/man/man1/${finalAttrs.pname}.1
  '';
})
