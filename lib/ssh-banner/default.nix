{ pkgs }:

# font taken from here: https://github.com/xero/figlet-fonts/blob/417429ef36ab039cbf192a4424c60aa23fc32de8/ANSI%20Regular.flf

term:
let
  bannerDrv =
    pkgs.runCommand "ssh-banner"
      {
        nativeBuildInputs = [ pkgs.figlet ];
      }
      ''
        mkdir -p $out
        banner=$(figlet -f ${./ANSI_Regular.flf} -w 1000 '${term}')
        printf "\n\n$banner\n" > $out/banner.txt
      '';
in
"${bannerDrv}/banner.txt"
