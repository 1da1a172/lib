function diceware() {
  typeset -r WORDFILE="${HOME}/lib/diceware.wordlist.asc"

  if ! gpg --verify "${WORDFILE}" 2>/dev/null; then
    echo "${WORDFILE} did not pass the integrity check!"
    return 1
  fi

  while [[ -n $1 ]]; do
    echo -n "$(grep "^$1	" "${WORDFILE}" | cut -f 2)"
    [[ -n $2 ]] && echo -n ' ' || echo ''
    shift
  done
}
