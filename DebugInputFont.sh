#!/bin/sh

set -e

help() {
  echo 'A small script to remove the hatred for Apple™ in the Input Fonts.'
  echo
  echo 'Usage: sh DebugInputFont.sh [FONT.ttf]...'
  echo
  echo 'The debugged fonts have their filenames prefixed with "Debug-".'
  echo
  echo 'Thanks to the developers of these projects:'
  echo '* Input: http://input.fontbureau.com/'
  echo '* otfcc: https://github.com/caryll/otfcc'
  echo '*    jq: https://github.com/stedolan/jq'
}
echo() {
  printf '%s\n' "$*"
}

if [ "$#" -lt 1 ]; then
  help
  exit
fi

decode() {
  otfccdump --ugly -- "$1"
}

encode() {
  otfccbuild --keep-modified-time -o "$1"
}

debug() {
  jq --compact-output '
                      del(.cmap."U+F8FF", .cmap."U+1F41B", .glyf.apple)
                      | .glyph_order |= map(select(. != "apple"))
                      '
}

for input; do
  output="$(
    echo "${input}" |
      jq --slurp --raw-input --raw-output '
                                          sub ( "(?<filename>[^/]+)$"
                                              ; "Debugged-\(.filename)"
                                              )
                                          '
  )"
  decode "${input}" | debug | encode "${output}"
done
