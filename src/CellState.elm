module CellState exposing (CellState(..), symbolOf)

import Player exposing (Player)


type CellState
    = Free
    | Taken Player


symbolOf : CellState -> String
symbolOf state =
    case state of
        Free ->
            " "

        Taken player ->
            Player.symbolOf player
