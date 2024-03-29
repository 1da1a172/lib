function ssh () {
  typeset -r SSH='/usr/bin/ssh'
  typeset arg=1
  typeset logtmp
  typeset logfile
  typeset -r logdir="${HOME}/.ssh/logs"
  typeset -ra args=("$@")

  while [[ -z "${logfile}" ]] && [[ "${arg}" -le "${#args}" ]]; do
    case ${args[arg]} in
      (-[1246AaCfGgKkMNnqsTtVvXxYy]*)
        (( arg++ ))
        ;;
      (-*)
        (( arg+=2 ))
        ;;
      (*)
        typeset -r hostname="${args[arg]}"
        typeset -r logfile="${logdir}/$(date -Iseconds)_${hostname}.log.asc"
        ;;
    esac
  done

  if [[ -n "${logfile}" ]]; then
    typeset -r logtmp="/tmp/${logfile:t:r}"

    [[ "${TERM}" == tmux* ]] && tmux set set-titles-string "#h|#I:#W|${hostname}"
    TERM=screen-256color $SSH ${args} | tee >(iconv -t UTF-8 -c | col -b > "${logtmp}")
    [[ "${TERM}" == tmux* ]] && tmux set set-titles-string "#h|#I:#W"

    [[ -s "${logtmp}" ]] && gpg -o "${logfile}" -ea "${logtmp}"
    rm "${logtmp}"
  else
    $SSH ${args}
  fi
}
