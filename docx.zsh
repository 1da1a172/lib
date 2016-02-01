#!/usr/bin/zsh

function docx() {
  if [[ "$(file -b $1 &> /dev/null)" == 'Microsoft Word 2007+' ]]; then
    pandoc -s -f docx -t man $1 | man -l -
  else
    echo "$1 does not appear to be a docx file."
    return 1
  fi
}
