function reload-wifi() {
  # unload
  sudo systemctl stop connman.service
  sudo systemctl stop wpa_supplicant.service
  sudo modprobe -r wl
  
  # wait for good measure
  sleep 1

  # load
  sudo modprobe wl
  sudo systemctl start connman.service
}
