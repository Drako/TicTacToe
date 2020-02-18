#!/bin/bash

set -e

JS="public/TicTacToe.js"
MINJS="public/TicTacToe.min.js"

npx elm make --optimize src/Main.elm --output=$JS
npx uglifyjs $JS --compress 'pure_funcs="F2,F3,F4,F5,F6,F7,F8,F9,A2,A3,A4,A5,A6,A7,A8,A9",pure_getters,keep_fargs=false,unsafe_comps,unsafe' |\
  npx uglifyjs --mangle --output=$MINJS

echo "Compiled size:$(cat $JS | wc -c) bytes  ($JS)"
echo "Minified size:$(cat $MINJS | wc -c) bytes  ($MINJS)"
