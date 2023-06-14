#!/usr/bin/zsh

function urlencode() {
  local l=${#1}
  for (( i = 0; i < l; i++)); do
    local c=${1:$i:1}
    case "$c" in
      [a-zA-Z0-9.~_-]) printf "%c" "$c";;
      ' ') printf + ;;
      *) printf '%%%.2X' "'$c"
    esac
  done
}

function urldecode() {
  local url_encoded="${1//+/ }"
  printf '%b' "${url_encoded//%/\\x}"
}
