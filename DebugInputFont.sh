#!/usr/bin/env bash

function help {
    echo 'A small script to remove the hatred for Apple™ in the Input Fonts.'
    echo
    echo "Usage: $(printf %q "$(basename -- "$0")") [FONT.ttf]..."
    echo
    echo 'The debugged fonts have their name prefixed with "Debug-".'
    echo
    echo 'Thanks for the developers of these projects:'
    echo '* Input: http://input.fontbureau.com/'
    echo '* otfcc: https://github.com/caryll/otfcc'
    echo '*    jq: https://github.com/stedolan/jq'
}

FONTS=("$@")

if [[ ${#FONTS[@]} -eq 0 ]]; then
    help
    exit -1
fi

function decode {
    otfccdump --ugly "$1"
}

function encode {
    otfccbuild --keep-modified-time -o "$1"
}

function debug {
    local filter='
        del(.cmap."U+F8FF", .cmap."U+1F41B", .glyf.apple)
        | .glyph_order |= map(select(. != "apple"))
    '
    jq --compact-output "${filter}"
}

for input in "${FONTS[@]}"; do
    output="Debugged-$(basename -- "${input}")"
    decode "${input}" | debug | encode "${output}"
done
