ntlm_hash () {
  echo -n "$1" \
    | iconv -f ASCII -t UTF-16LE \
    | openssl dgst -provider legacy -md4 \
    | cut -d ' ' -f 2
}
