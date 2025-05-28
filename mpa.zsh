function mpa () {
  /usr/bin/mpv \
    --video=no \
    --msg-level=display-tags=no,cplayer=no \
    --term-status-msg='${media-title} ${playback-time} / ${duration} (${percent-pos}%)' "$@"
}
