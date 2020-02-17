# TicTacToe

[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://github.com/Drako/TicTacToe/blob/master/LICENSE)

This is a little TicTacToe game written in Elm as I am currently experimenting around with it.

## Building

Development Build:
```bash
elm make src/Main.elm
```

Release Build:
```bash
elm make --optimize src/Main.elm
```

Both generate an HTML file which can be opened with a web browser.

Alternatively one can compile into a JS file with the `--output<output-file>` parameter.
This way the element can be embedded into a bigger project.

## Demo

A live running version can be found [here](https://playground.drako.guru/TicTacToe/).

