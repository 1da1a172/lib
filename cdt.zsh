function cdt() {
  [[ -n "$1" ]] && typeset grp=".$1"
  builtin cd "$(mktemp --directory --tmpdir "$USER$grp.XXXXXXXX")"
}
