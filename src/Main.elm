module Main exposing (main)

import Array exposing (Array, filter, get, indexedMap, initialize, length, set, slice, toList)
import Browser
import Css exposing (auto, border3, borderBottom, borderCollapse, borderLeft, borderRight, borderTop, center, collapse, firstChild, fontFamilies, fontSize, fontWeight, height, int, lastChild, margin, px, rgb, solid, textAlign, width)
import Css.Global exposing (descendants, typeSelector)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Random


chunked : Int -> Array a -> Array (Array a)
chunked size source =
    initialize (length source // 3) (\chunk -> slice (size * chunk) (size * chunk + size) source)


type Player
    = Cross
    | Circle


opponentOf : Player -> Player
opponentOf player =
    case player of
        Cross ->
            Circle

        Circle ->
            Cross


markerOf : Player -> CellState
markerOf player =
    case player of
        Cross ->
            Crossed

        Circle ->
            Circled


symbolOf : Player -> String
symbolOf player =
    case player of
        Cross ->
            "X"

        Circle ->
            "O"


type CellState
    = Free
    | Crossed
    | Circled


type GameState
    = Starting
    | Playing Game
    | Tie
    | Winner Player


type alias Game =
    { currentPlayer : Player
    , field : Array CellState
    }


type Message
    = PlayerSelected Player
    | MarkCell Int Player
    | Restart


randomPlayer : Random.Generator Player
randomPlayer =
    Random.uniform Cross [ Circle ]


update : Message -> GameState -> ( GameState, Cmd Message )
update msg model =
    case msg of
        PlayerSelected player ->
            ( Playing (initGame player)
            , Cmd.none
            )

        MarkCell cellNr player ->
            if isWinningMove model (markerOf player) cellNr then
                ( Winner player
                , Cmd.none
                )

            else if isTie model then
                ( Tie
                , Cmd.none
                )

            else
                ( markCell model cellNr player
                , Cmd.none
                )

        Restart ->
            init ()


markCell : GameState -> Int -> Player -> GameState
markCell model cellNr player =
    case model of
        Playing game ->
            Playing { currentPlayer = opponentOf player, field = set cellNr (markerOf player) game.field }

        _ ->
            model


subscriptions : GameState -> Sub Message
subscriptions _ =
    Sub.none


initGame : Player -> Game
initGame startingPlayer =
    { currentPlayer = startingPlayer
    , field = initialize 9 (always Free)
    }


cellValue : Game -> Int -> CellState
cellValue game cellNr =
    case get cellNr game.field of
        Just value ->
            value

        Nothing ->
            Free


isTie : GameState -> Bool
isTie model =
    case model of
        Playing game ->
            length (filter ((==) Free) game.field) == 1

        _ ->
            False


isWinningMove : GameState -> CellState -> Int -> Bool
isWinningMove model cellState cellNr =
    case model of
        Playing game ->
            if cellNr == 0 then
                (cellState == cellValue game 1 && cellState == cellValue game 2)
                    || (cellState == cellValue game 4 && cellState == cellValue game 8)
                    || (cellState == cellValue game 3 && cellState == cellValue game 6)

            else if cellNr == 1 then
                (cellState == cellValue game 0 && cellState == cellValue game 2)
                    || (cellState == cellValue game 4 && cellState == cellValue game 7)

            else if cellNr == 2 then
                (cellState == cellValue game 0 && cellState == cellValue game 1)
                    || (cellState == cellValue game 4 && cellState == cellValue game 6)
                    || (cellState == cellValue game 5 && cellState == cellValue game 8)

            else if cellNr == 3 then
                (cellState == cellValue game 4 && cellState == cellValue game 5)
                    || (cellState == cellValue game 0 && cellState == cellValue game 6)

            else if cellNr == 4 then
                (cellState == cellValue game 0 && cellState == cellValue game 8)
                    || (cellState == cellValue game 1 && cellState == cellValue game 7)
                    || (cellState == cellValue game 2 && cellState == cellValue game 6)
                    || (cellState == cellValue game 3 && cellState == cellValue game 5)

            else if cellNr == 5 then
                (cellState == cellValue game 2 && cellState == cellValue game 8)
                    || (cellState == cellValue game 3 && cellState == cellValue game 4)

            else if cellNr == 6 then
                (cellState == cellValue game 0 && cellState == cellValue game 3)
                    || (cellState == cellValue game 4 && cellState == cellValue game 2)
                    || (cellState == cellValue game 7 && cellState == cellValue game 8)

            else if cellNr == 7 then
                (cellState == cellValue game 6 && cellState == cellValue game 8)
                    || (cellState == cellValue game 1 && cellState == cellValue game 4)

            else if cellNr == 8 then
                (cellState == cellValue game 2 && cellState == cellValue game 5)
                    || (cellState == cellValue game 0 && cellState == cellValue game 4)
                    || (cellState == cellValue game 6 && cellState == cellValue game 7)

            else
                False

        _ ->
            False


renderCell : Game -> Int -> CellState -> Html Message
renderCell game cellNr cellState =
    case cellState of
        Free ->
            td [ onClick (MarkCell cellNr game.currentPlayer) ] [ text "" ]

        Crossed ->
            td [] [ text "X" ]

        Circled ->
            td [] [ text "O" ]


lineLength : Int
lineLength =
    3


renderLine : Game -> Int -> Array CellState -> Html Message
renderLine game lineNr line =
    tr [] (toList (indexedMap (\cellNr cellState -> renderCell game (cellNr + lineNr * lineLength) cellState) line))


gameComponent : List (Attribute Message) -> List (Html Message) -> Html Message
gameComponent =
    styled div
        [ width (px 300)
        , height (px 100)
        , margin auto
        , textAlign center
        , fontFamilies
            [ "HelveticaNeue-Light"
            , "Helvetica Neue Light"
            , "Helvetica Neue"
            , "Helvetica"
            , "Arial"
            , "Lucida Grande"
            , "sans-serif"
            ]
        , fontWeight (int 300)
        , fontSize (px 20)
        ]


boardComponent : List (Attribute Message) -> List (Html Message) -> Html Message
boardComponent =
    styled table
        [ borderCollapse collapse
        , margin auto
        , descendants
            [ typeSelector "td"
                [ border3 (px 2) solid (rgb 0 0 0)
                , width (px 25)
                , height (px 25)
                , textAlign center
                ]
            , typeSelector "tr" [ firstChild [ descendants [ typeSelector "td" [ borderTop (px 0) ] ] ] ]
            , typeSelector "tr" [ lastChild [ descendants [ typeSelector "td" [ borderBottom (px 0) ] ] ] ]
            , typeSelector "tr" [ descendants [ typeSelector "td" [ firstChild [ borderLeft (px 0) ] ] ] ]
            , typeSelector "tr" [ descendants [ typeSelector "td" [ lastChild [ borderRight (px 0) ] ] ] ]
            ]
        ]


view : GameState -> Html Message
view model =
    case model of
        Starting ->
            gameComponent [] [ text "Selecting starting player..." ]

        Playing game ->
            gameComponent []
                [ p [] [ text ("Current player is " ++ symbolOf game.currentPlayer ++ ".") ]
                , boardComponent [] (toList (indexedMap (renderLine game) (chunked lineLength game.field)))
                ]

        Tie ->
            gameComponent []
                [ p [] [ text "The game ended with a tie." ]
                , button [ onClick Restart ] [ text "Play again!" ]
                ]

        Winner player ->
            gameComponent []
                [ p [] [ text ("Player " ++ symbolOf player ++ " won the game.") ]
                , button [ onClick Restart ] [ text "Play again!" ]
                ]


init : () -> ( GameState, Cmd Message )
init _ =
    ( Starting, Random.generate PlayerSelected randomPlayer )


main =
    Browser.element
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view >> toUnstyled
        }
