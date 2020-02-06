function nz() {
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

function np() {
  if [[ -z $1 ]]; then
    echo 'Enter a file name.' >&2
    return 1
  elif [[ -a $1 ]]; then
    echo 'File exists.' >&2
    return 1
  else
    typeset contents=''
    contents+=$'#!/usr/bin/env python3\n'
    contents+=$'\n'
    contents+=$'import sys\n'
    contents+=$'from typing import List\n'
    contents+=$'\n'
    contents+=$'def main(argv: List[str]) -> int:\n'
    contents+=$'    return 0\n'
    contents+=$'\n\n'
    contents+=$'if __name__ == \'__main__\':\n'
    contents+=$'    sys.exit(main(sys.argv))'

    echo $contents > $1
    chmod +x $1
    vim $1
  fi
}
