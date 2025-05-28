function xzdump {
  if (( ${#argv} != 2 )); then
    echo "Usage: $0 <foo.img.xz> <disk>" >&2
    return 1
  fi
  typeset src="$1"
  typeset dst="$2"
  read -q "r?Overwrite '$2' with decompressed '$1'?" || return 2
  echo ''
  xz --decompress --stdout "$src" \
    | pv --size $(xz --list --robot "$src" | tail -1 | awk '{print $5;}') \
    | sudo tee "$dst" > /dev/null
}
