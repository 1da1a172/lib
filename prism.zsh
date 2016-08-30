# aliases for putting a broadcom card in/out of monitor mode
alias wl-mon='echo 1 | sudo tee /proc/brcm_monitor0 > /dev/null'
alias wl-normal='echo 0 | sudo tee /proc/brcm_monitor0 > /dev/null'
