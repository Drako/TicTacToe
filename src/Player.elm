module Player exposing (Player, opponentOf, random, symbolOf)

import Random


type Player
    = Cross
    | Circle


symbolOf : Player -> String
symbolOf player =
    case player of
        Cross ->
            "X"

        Circle ->
            "O"


opponentOf : Player -> Player
opponentOf player =
    case player of
        Cross ->
            Circle

        Circle ->
            Cross


random : Random.Generator Player
random =
    Random.uniform Cross [ Circle ]
