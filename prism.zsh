# aliases for putting a broadcom card in/out of monitor mode
wl-mon='echo 1 | sudo tee /proc/brcm_monitor0 > /dev/null'
wl-normal='echo 0 | sudo tee /proc/brcm_monitor0 > /dev/null'
