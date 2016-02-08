function spew-colors() {
  x=$(tput op)
  y=$(printf %76s)
  for i in {0..256}; do
    echo -e ${(l:3::0:)i} $(tput setaf $i; tput setab $i)${y// /=}$x
  done
}
