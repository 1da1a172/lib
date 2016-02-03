#!/usr/bin/zsh

function ssh () {
  typeset arg=1 
  typeset logtmp
  typeset logfile
  typeset -r logdir="${HOME}/.ssh/logs" 
  typeset -a args
  args=("$@") 
  readonly -a args

  while [[ -z "${logfile}" ]] && [[ "${arg}" -le "${#args}" ]]; do
    case ${args[arg]} in
      (-[1246AaCfGgKkMNnqsTtVvXxYy]*)
        (( arg++ ))
        ;;
      (-*)
        (( arg+=2 ))
        ;;
      (*)
        typeset -r logfile="${logdir}/$(date +%Y%b%d-%T) ${args[arg]}.log.asc"
        ;;
    esac
  done

  if [[ -n "${logfile}" ]]; then
    typeset -r logtmp="/tmp/${logfile:t:r}" 

    =ssh ${args} | tee >(col -b > "${logtmp}")

    [[ -s "${logtmp}" ]] && gpg -o "${logfile}" -r "${USER}" -esa "${logtmp}"
    rm "${logtmp}"
  else
    =ssh ${args}
  fi
}
