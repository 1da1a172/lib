function mpa () {
  /usr/bin/mpv \
    --video=no \
    --msg-level=display-tags=no,cplayer=no \
    --term-status-msg='${playback-time} / ${duration} (${percent-pos}%)\t| ${media-title}' "$@"
}
