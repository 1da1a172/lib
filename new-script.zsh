function new-script() {
  if [[ -z $1 ]]; then
    echo 'Enter a file name.' >&2
    return 1
  elif [[ -a $1 ]]; then
    echo 'File exists.' >&2
    return 1
  else
    echo '#!/usr/bin/zsh'$'\n' > $1
    chmod +x $1
    vim $1
  fi
}
