ntlm_hash () {
  cat "$1" | iconv -f ASCII -t UTF-16LE | openssl md4 | cut -d ' ' -f 2
}
