function nz() {
  if [[ -z $1 ]]; then
    echo 'Enter a file name.' >&2
    return 1
  fi
  if [[ -a $1 ]]; then
    echo 'File exists.' >&2
    return 1
  fi
  echo $'#!/usr/bin/zsh\n' > $1
  chmod +x $1
  vim $1
}

function nb() {
  if [[ -z $1 ]]; then
    echo 'Enter a file name.' >&2
    return 1
  fi
  if [[ -a $1 ]]; then
    echo 'File exists.' >&2
    return 1
  fi

  echo $'#!/usr/bin/bash\n' > $1
  chmod +x $1
  vim $1
}

function np() {
  if [[ -z $1 ]]; then
    echo 'Enter a file name.' >&2
    return 1
  fi
  if [[ -a $1 ]]; then
    echo 'File exists.' >&2
    return 1
  fi
  typeset contents=''
  if [[ -v VIRTUAL_ENV ]]; then
    contents+="#!$(which python3)\n"
  else
    contents+=$'#!/usr/bin/env python3\n'
  fi
  contents+=$'""" !!! SCRAP !!! """\n'
  contents+=$'\n'
  contents+=$'import sys\n'
  contents+=$'from typing import List\n'
  contents+=$'\n'
  contents+=$'\n'
  contents+=$'def _main(argv: List[str]) -> int:\n'
  contents+=$'    del argv\n'
  contents+=$'    return 0\n'
  contents+=$'\n\n'
  contents+=$'if __name__ == "__main__":\n'
  contents+=$'    sys.exit(_main(sys.argv))'

  echo $contents > $1
  chmod +x $1
  vim $1
}
