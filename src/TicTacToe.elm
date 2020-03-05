module TicTacToe exposing (..)

import Array exposing (..)
import Browser exposing (Document)
import CellState exposing (CellState(..))
import Helpers exposing (chunked, getOr)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Player exposing (Player, opponentOf)
import Random
import Ui


type GameState
    = Starting
    | Playing Game
    | Tie
    | Winner Player


type alias WithPlayer record =
    { record | currentPlayer : Player }


type alias WithField record =
    { record | field : Array CellState }


type alias Game =
    { currentPlayer : Player
    , field : Array CellState
    }


type Message
    = PlayerSelected Player
    | MarkCell Int
    | Restart


update : Message -> GameState -> ( GameState, Cmd Message )
update msg model =
    case ( msg, model ) of
        ( PlayerSelected player, Starting ) ->
            ( Playing (initGame player)
            , Cmd.none
            )

        ( MarkCell cellNr, Playing game ) ->
            if isWinningMove game cellNr then
                ( Winner game.currentPlayer
                , Cmd.none
                )

            else if isTie game then
                ( Tie
                , Cmd.none
                )

            else
                ( Playing (game |> markCell cellNr |> switchPlayer)
                , Cmd.none
                )

        ( Restart, _ ) ->
            init ()

        _ ->
            ( model, Cmd.none )


switchPlayer : WithPlayer record -> WithPlayer record
switchPlayer game =
    { game | currentPlayer = opponentOf game.currentPlayer }


markCell : Int -> Game -> Game
markCell cellNr game =
    { game | field = set cellNr (Taken game.currentPlayer) game.field }


initGame : Player -> Game
initGame startingPlayer =
    { currentPlayer = startingPlayer
    , field = repeat boardSize Free
    }


isTie : WithField record -> Bool
isTie { field } =
    field |> filter ((==) Free) |> length |> (==) 1


lines : Array (List (List Int))
lines =
    fromList
        [ [ [ 1, 2 ], [ 4, 8 ], [ 3, 6 ] ]
        , [ [ 0, 2 ], [ 4, 7 ] ]
        , [ [ 0, 1 ], [ 4, 6 ], [ 5, 8 ] ]
        , [ [ 4, 5 ], [ 0, 6 ] ]
        , [ [ 0, 8 ], [ 1, 7 ], [ 2, 6 ], [ 3, 5 ] ]
        , [ [ 2, 8 ], [ 3, 4 ] ]
        , [ [ 0, 3 ], [ 2, 4 ], [ 7, 8 ] ]
        , [ [ 6, 8 ], [ 1, 4 ] ]
        , [ [ 2, 5 ], [ 0, 4 ], [ 6, 7 ] ]
        ]


isWinningMove : Game -> Int -> Bool
isWinningMove game cellNr =
    let
        takenBy : Player -> CellState -> Bool
        takenBy player state =
            case state of
                Taken owner ->
                    player == owner

                _ ->
                    False

        match : Player -> List Int -> Bool
        match player listOfCells =
            listOfCells |> List.map (\line -> getOr line game.field Free) |> List.all (takenBy player)

        checkCells : List (List Int) -> Bool
        checkCells linesToCheck =
            linesToCheck |> List.any (match game.currentPlayer)
    in
    get cellNr lines |> Maybe.map checkCells |> Maybe.withDefault False


renderCell : Int -> CellState -> Html Message
renderCell cellNr cellState =
    td
        (if cellState == Free then
            [ onClick (MarkCell cellNr) ]

         else
            []
        )
        [ text <| CellState.symbolOf cellState ]


lineLength : Int
lineLength =
    3


boardSize : Int
boardSize =
    9


renderLine : Int -> Array CellState -> Html Message
renderLine lineNr line =
    let
        render : Int -> CellState -> Html Message
        render cellNr cellState =
            renderCell (cellNr + lineNr * lineLength) cellState
    in
    indexedMap render line |> toList |> tr []


view : GameState -> Html Message
view model =
    case model of
        Starting ->
            Ui.game [ Ui.caption "Selecting starting player..." |> Html.Styled.map never ]

        Playing game ->
            Ui.game
                [ Ui.caption ("Current player is " ++ Player.symbolOf game.currentPlayer ++ ".")
                    |> Html.Styled.map never
                , chunked lineLength game.field |> indexedMap renderLine |> toList |> Ui.board
                ]

        Tie ->
            Ui.game
                [ Ui.caption "The game ended with a tie." |> Html.Styled.map never
                , Ui.textButton [ onClick Restart ] "Play again!"
                ]

        Winner player ->
            Ui.game
                [ Ui.caption ("Player " ++ Player.symbolOf player ++ " won the game.") |> Html.Styled.map never
                , Ui.textButton [ onClick Restart ] "Play again!"
                ]


init : () -> ( GameState, Cmd Message )
init _ =
    ( Starting, Random.generate PlayerSelected Player.random )


subscriptions : GameState -> Sub Message
subscriptions _ =
    Sub.none


documentView : GameState -> Document Message
documentView model =
    { title = "TicTacToe"
    , body = [ (view >> toUnstyled) model ]
    }
