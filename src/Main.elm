module Main exposing (main)

import Browser exposing (Document)
import TicTacToe exposing (documentView, init, subscriptions, update)


main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = documentView
        }
