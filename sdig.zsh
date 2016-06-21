# Requires ip.zsh library

function sdig {
  if ip::valid_addr $1; then
    dig +short -x $1
  else
    dig +short $1 A $1 AAAA
  fi
}
