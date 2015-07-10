#!/usr/bin/zsh
#
# A library for scripting with network stuff

function ip::valid_addr() {
  ipv4::valid_addr "$@" || ipv6::valid_addr "$@" || return 1
}

function ipv4::valid_addr() {
  typeset addr="$1"
  typeset octet

  [[ "${addr[1]}" != '.' ]] || return 1
  [[ "${addr[-1]}" != '.' ]] || return 1
  [[ ${(ws|.|)#addr} == 4 ]] || return 1
  [[ -z "${addr[(r)..]}" ]] || return 1

  for octet in ${(ws|.|)addr}; do
    [ ${octet} -le 255 ] &> /dev/null || return 1
    [[ ${octet} -ge 0 ]] || return 1
  done
}

function ipv6::valid_addr() {
  typeset addr="$1"
  typeset hextet

  [[ "${addr}" =~ '^::' ]] && addr="0${addr}"
  [[ "${addr[1]}" != ':' ]] || return 1
  [[ "${addr}" =~ '::$' ]] && addr+='0'
  [[ "${addr[-1]}" != ':' ]] || return 1
  [[ -z "${addr[(r):::]}" ]] || return 1
  case "${(ws|::|)#addr}" in
    (1) [[ ${(ws|:|)#addr} -eq 8 ]] || return 1 ;;
    (2) [[ ${(ws|:|)#addr} -le 7 ]] || return 1 ;;
    (*) return 1 ;;
  esac

  for hextet in ${(ws|:|)addr}; do
    [[ "${hextet}" =~ "^[[:xdigit:]]{1,4}$" ]] || return 1
  done
}

function ip::valid_cidr() {
  ipv4::valid_cidr "$@" || ipv6::valid_cidr "$@" || return 1
}

function ipv4::valid_cidr() {
  [ ${1#*/} -le 32 ] &> /dev/null || return 1
  [[ ${1#*/} -ge 0 ]] || return 1
  ipv4::valid_addr ${1%/*} || return 1
}

function ipv6::valid_cidr() {
  [ ${1#*/} -le 128 ] &> /dev/null || return 1
  [[ ${1#*/} -ge 0 ]] || return 1
  ipv6::valid_addr ${1%/*} || return 1
}

function ip::fmt_binary() {
  ipv4::fmt_binary "$@" || ipv6::fmt_binary "$@" || return 1
}

function ipv4::fmt_binary() {
  typeset decimal="$1"
  typeset binary
  typeset octet

  ipv4::valid_addr "${decimal}" || return 1
  for octet in ${(ws|.|)decimal}; do
    binary+="${(l|8||0|)$(([#2]${octet}))#'2#'}"
  done

  echo "${binary}"
}

function ipv6::fmt_binary() {
  typeset hex
  typeset binary
  typeset hextet

  hex="$(ipv6::fmt_long "$1")" || return 1
  for hextet in ${(ws|:|)hex}; do
    binary+="${(l|16||0|)$(([#2]16#${hextet}))#'2#'}"
  done

  echo "${binary}"
}

function ip::fmt_human() {
  ipv4::fmt_decimal "$@" || ipv6::fmt_hex "$@" || return 1
}

function ipv4::fmt_decimal() {
  typeset binary="$1"
  typeset octet
  typeset -a octets

  [[ "${binary}" =~ "^[01]{32}$" ]] || return 1
  for octet in {1..4}; do
    octets[octet]="$(( 2#${binary:(${octet}-1)*8:8} ))"
  done
  echo ${(j|.|)octets}
}
alias ipv4::fmt_human=ipv4::fmt_decimal

function ipv6::fmt_hex() {
  typeset binary="$1"
  typeset hextet
  typeset -a hextets

  [[ "${binary}" =~ "^[01]{128}$" ]] || return 1
  for hextet in {1..8}; do
    hextets[hextet]="${$(( [#16] 2#${binary:(${hextet}-1)*16:16} ))}"
  done
  ipv6::fmt_short ${(Lj|:|)hextets#'16#'}
}
alias ipv6::fmt_human=ipv6::fmt_hex

function ipv6::fmt_short() {
  typeset long_addr
  typeset short_addr
  typeset zeros='0000:0000:0000:0000:0000:0000:0000'
  typeset hextet
  long_addr=$(ipv6::fmt_long $1) || return 1
  short_addr="${long_addr}"

  while [[ ${#short_addr} -eq 39 ]] && [[ ${#zeros} -gt 4 ]]; do
    short_addr=${long_addr/$zeros/}
    zeros=${zeros:0:${#zeros}-5}
  done
  [[ "$short_addr[1]" == ':' ]] && short_addr=":${short_addr}"
  [[ "$short_addr[-1]" == ':' ]] && short_addr+=':'

  for index in {1..${(ws|:|)#short_addr}}; do
    hextet="${short_addr[(ws|:|)index]}"
    while [[ ${#hextet} -gt 1 ]] && [[ ${hextet[1]} == '0' ]]; do
      hextet=${hextet:1}
    done
    short_addr[(ws|:|)${index}]="${hextet}"
  done

  echo "${short_addr}"
}

function ipv6::fmt_long() {
  typeset pos
  typeset short_addr="$1"
  typeset -a long_addr
  ipv6::valid_addr "${short_addr}" || return 1

  long_addr=(0 0 0 0 0 0 0 0)
  if [[ -n "${short_addr%::*}" ]]; then
    for pos in {1.."${(ws|:|)#short_addr%::*}"}; do
      long_addr[pos]="${short_addr[(ws|:|)pos]}"
    done
  fi
  if [[ -n "${short_addr#*::}" ]]; then
    for pos in {-1..-"${(ws|:|)#short_addr#*::}"}; do
      long_addr[9+${pos}]="${short_addr[(ws|:|)pos]}"
    done
  fi

  echo ${(j|:|)${(l|4||0|)long_addr}}
}

function ip::network_addr() {
  typeset addr="$1"
  typeset binary

  ip::valid_cidr "${addr}" || return 1

  binary="$(ip::fmt_binary "${addr%/*}")"
  ip::fmt_human "${(r|${#binary}||0|)binary:0:${addr#*/}}"
}
alias ipv4::network_addr=ip::network_addr
alias ipv6::network_addr=ip::network_addr

function ip::bcast_addr() {
  typeset addr="$1"
  typeset binary

  ip::valid_cidr "${addr}" || return 1

  binary="$(ip::fmt_binary "${addr%/*}")"
  ip::fmt_human "${(r|${#binary}||1|)binary:0:${addr#*/}}"
}
alias ipv4::bcast_addr=ip::bcast_addr
alias ipv6::bcast_addr=ip::bcast_addr

function ipv4::subnet() {
  case "$1" in
    ('255.255.255.255') echo 32 ;;
    ('255.255.255.254') echo 31 ;;
    ('255.255.255.252') echo 30 ;;
    ('255.255.255.248') echo 29 ;;
    ('255.255.255.240') echo 28 ;;
    ('255.255.255.224') echo 27 ;;
    ('255.255.255.192') echo 26 ;;
    ('255.255.255.128') echo 25 ;;
    ('255.255.255.0') echo 24 ;;
    ('255.255.254.0') echo 23 ;;
    ('255.255.252.0') echo 22 ;;
    ('255.255.248.0') echo 21 ;;
    ('255.255.240.0') echo 20 ;;
    ('255.255.224.0') echo 19 ;;
    ('255.255.192.0') echo 18 ;;
    ('255.255.128.0') echo 17 ;;
    ('255.255.0.0') echo 16 ;;
    ('255.254.0.0') echo 15 ;;
    ('255.252.0.0') echo 14 ;;
    ('255.248.0.0') echo 13 ;;
    ('255.240.0.0') echo 12 ;;
    ('255.224.0.0') echo 11 ;;
    ('255.192.0.0') echo 10 ;;
    ('255.128.0.0') echo 9 ;;
    ('255.0.0.0') echo 8 ;;
    ('254.0.0.0') echo 7 ;;
    ('252.0.0.0') echo 6 ;;
    ('248.0.0.0') echo 5 ;;
    ('240.0.0.0') echo 4 ;;
    ('224.0.0.0') echo 3 ;;
    ('192.0.0.0') echo 2 ;;
    ('128.0.0.0') echo 1 ;;
    ('0.0.0.0') echo 0 ;;
    (32) echo '255.255.255.255' ;;
    (31) echo '255.255.255.254' ;;
    (30) echo '255.255.255.252' ;;
    (29) echo '255.255.255.248' ;;
    (28) echo '255.255.255.240' ;;
    (27) echo '255.255.255.224' ;;
    (26) echo '255.255.255.192' ;;
    (25) echo '255.255.255.128' ;;
    (24) echo '255.255.255.0' ;;
    (23) echo '255.255.254.0' ;;
    (22) echo '255.255.252.0' ;;
    (21) echo '255.255.248.0' ;;
    (20) echo '255.255.240.0' ;;
    (19) echo '255.255.224.0' ;;
    (18) echo '255.255.192.0' ;;
    (17) echo '255.255.128.0' ;;
    (16) echo '255.255.0.0' ;;
    (15) echo '255.254.0.0' ;;
    (14) echo '255.252.0.0' ;;
    (13) echo '255.248.0.0' ;;
    (12) echo '255.240.0.0' ;;
    (11) echo '255.224.0.0' ;;
    (10) echo '255.192.0.0' ;;
    (9) echo '255.128.0.0' ;;
    (8) echo '255.0.0.0' ;;
    (7) echo '254.0.0.0' ;;
    (6) echo '252.0.0.0' ;;
    (5) echo '248.0.0.0' ;;
    (4) echo '240.0.0.0' ;;
    (3) echo '224.0.0.0' ;;
    (2) echo '192.0.0.0' ;;
    (1) echo '128.0.0.0' ;;
    (0) echo '0.0.0.0' ;;
    (*) return 1 ;;
  esac
}

function ip::nth_addr() {
  ipv4::nth_addr "$@" || ipv6::nth_addr "$@" || return 1
}

function ipv4::nth_addr() {
  typeset network="${1%/*}"
  typeset network_bits
  typeset network_size="${1#*/}"
  typeset host_bits
  typeset host_size
  typeset host_max
  typeset n="$2"

  ipv4::valid_cidr "$1" || return 1
  [[ "${network_size}" -le 30 ]] || return 1
  [[ -n "$n" ]] && [ $n -eq "$n" ] &> /dev/null || return 1

  network_bits="${$(ipv4::fmt_binary ${network}):0:${network_size}}" || return 1
  host_size=$(( 32 - ${network_size} ))
  host_max="${(r|${host_size}||1|)}"
  if [[ $n > 0 ]];then
    [[ $n -lt $(( 2#${host_max} )) ]] || return 1
    host_bits=${(l|${host_size}||0|)$(( [#2] $n ))#'2#'}
  elif [[ $n < 0 ]]; then
    [[ ${n:1} -lt $(( 2#${host_max} )) ]] || return 1
    host_bits=${$(( [#2] 2#${host_max} + $n ))#'2#'}
  else
    return 1
  fi

  ipv4::fmt_decimal "${network_bits}${host_bits}"
}

function ipv6::nth_addr() {
  typeset -x +g BC_LINE_LENGTH=00
  typeset network="${1%/*}"
  typeset network_bits
  typeset network_size="${1#*/}"
  typeset host_bits
  typeset host_size
  typeset host_max
  typeset n="$2"

  ipv6::valid_cidr "$1" || return 1
  [[ "${network_size}" -le 126 ]] || return 1
  [[ $n =~ "^-?[[:digit:]]+$" ]] || return 1

  network_bits="${$(ipv6::fmt_binary ${network}):0:${network_size}}" || return 1
  host_size=$(( 128 - ${network_size} ))
  host_max=$(bc <<< "ibase=2;${(r|${host_size}||1|)}")
  if [[ $n > 0 ]]; then
    (( $(bc <<< "$n < ${host_max}") )) || return 1
    host_bits=${(l|${host_size}||0|)$(bc <<< "obase=2;$n")}
  elif [[ $n < 0 ]]; then
    (( $(bc <<< "${n:1} < ${host_max}") )) || return 1
    host_bits=${(l|${host_size}||0|)$(bc <<< "obase=2;${host_max} + $n")}
  else
    return 0
  fi

  ipv6::fmt_hex "${network_bits}${host_bits}"
}

function ip::addr_index() {
  ipv4::addr_index "$@" || ipv6:addr_index "$@" || return 1
}

function ipv4::addr_index() {
  typeset addr
  typeset network
  typeset bcast
  typeset start_delta
  typeset end_delta

  ipv4::valid_cidr "$1" || return 1

  addr=$(ipv4::fmt_binary "${1%/*}")
  network="${(r|32||0|)${addr:0:${1#*/}}}"
  bcast="${(r|32||1|)${addr:0:${1#*/}}}"

  start_delta=$(( 2#${addr} - 2#${network} ))
  end_delta=$(( 2#${addr} - 2#${bcast} ))

  if [[ ${start_delta} -le ${end_delta:1} ]]; then
    [[ "${start_delta}" -gt 0 ]] && echo "${start_delta}" || return 1
  else
    [[ "${end_delta}" -lt 0 ]] && echo "${end_delta}" || return 1
  fi
}

function ipv6::addr_index() {
  typeset addr
  typeset network
  typeset bcast
  typeset start_delta
  typeset end_delta

  ipv6::valid_cidr "$1" || return 1

  addr=$(ipv6::fmt_binary "${1%/*}")
  network="${(r|128||0|)${addr:0:${1#*/}}}"
  bcast="${(r|128||1|)${addr:0:${1#*/}}}"

  start_delta=$(bc <<< "ibase=2;${addr} - ${network}")
  end_delta=$(bc <<< "ibase=2;${addr} - ${bcast}")

  if (( $(bc <<< "${start_delta} <= ${end_delta:1}") )); then
    (( $(bc <<< "${start_delta} > 0") )) && echo "${start_delta}" || return 1
  else
    (( $(bc <<< "${end_delta} < 0") )) && echo "${end_delta}" || return 1
  fi
}

# $1=v4 addr; $2=octet index (1-4); $3=increment size (defaults to 1)
function ipv4::increment_octet() {
  typeset addr="$1"
  typeset inc="${3:-1}"

  ipv4::valid_addr ${addr} || return 1
  [ "$inc" -eq "$inc" ] &> /dev/null || return 1
  [ $2 -ge 0 ] &> /dev/null || return 1
  [[ $2 -le 4 ]] || return 1

  (( addr[(ws|.|)$2]+=${inc} ))
  [[ ${addr[(ws|.|)$2]} -le 255 ]] || return 1
  [[ ${addr[(ws|.|)$2]} -ge 0 ]] || return 1

  echo "${addr}"
}

# $1=v6 addr; $2=octet index (1-8); $3=increment size (defaults to 1)
function ipv6::increment_hextet() {
  typeset -x +g BC_LINE_LENGTH='00'
  typeset addr="$1"
  typeset inc="${$(( [#16] ${3:-1} ))#'16#'}"
  typeset hextet

  addr="$(ipv6::fmt_long ${addr})" || return 1
  [[ "$inc" =~ "^-?[[:digit:]]+$" ]] || return 1
  [ $2 -ge 0 ] &> /dev/null || return 1
  [[ $2 -le 8 ]] || return 1

  hextet=${addr[(ws|:|)$2]}
  hextet=$(bc <<< "obase=16;ibase=16;${(U)hextet} + ${inc}")
  (( $(bc <<< "ibase=16;${hextet} <= FFFF") )) || return 1
  (( $(bc <<< "ibase=16;${hextet} >= 0") )) || return 1
  addr[(ws|:|)$2]="${(L)hextet}"

  ipv6::fmt_short "${addr}"
}
