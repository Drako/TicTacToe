module TicTacToe exposing (documentView, init, subscriptions, update)

import Array exposing (..)
import Browser exposing (Document)
import Helpers exposing (chunked, getOr)
import Html.Styled exposing (..)
import Html.Styled.Events exposing (onClick)
import Random
import Ui


type alias Player =
    { symbol : String
    , marker : CellState
    }


cross : Player
cross =
    { symbol = "X"
    , marker = Cross
    }


circle : Player
circle =
    { symbol = "O"
    , marker = Circle
    }


opponentOf : Player -> Player
opponentOf player =
    if player == cross then
        circle

    else
        cross


type CellState
    = Free
    | Cross
    | Circle


type GameState
    = Starting
    | Playing Game
    | Tie
    | Winner Player


withGame : GameState -> (Game -> a) -> Maybe a
withGame model handler =
    case model of
        Playing game ->
            Just (handler game)

        _ ->
            Nothing


type alias Game =
    { currentPlayer : Player
    , field : Array CellState
    }


type Message
    = PlayerSelected Player
    | MarkCell Int
    | Restart


randomPlayer : Random.Generator Player
randomPlayer =
    Random.uniform cross [ circle ]


update : Message -> GameState -> ( GameState, Cmd Message )
update msg model =
    case msg of
        PlayerSelected player ->
            ( Playing (initGame player)
            , Cmd.none
            )

        MarkCell cellNr ->
            withGame model
                (\game ->
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
                )
                |> Maybe.withDefault ( model, Cmd.none )

        Restart ->
            init ()


switchPlayer : Game -> Game
switchPlayer game =
    { game | currentPlayer = opponentOf game.currentPlayer }


markCell : Int -> Game -> Game
markCell cellNr game =
    { game | field = set cellNr game.currentPlayer.marker game.field }


initGame : Player -> Game
initGame startingPlayer =
    { currentPlayer = startingPlayer
    , field = initialize boardSize (always Free)
    }


isTie : Game -> Bool
isTie game =
    length (filter ((==) Free) game.field) == 1


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
        match : CellState -> List Int -> Bool
        match cellState listOfCells =
            listOfCells |> List.map (\line -> getOr line game.field Free) |> List.all ((==) cellState)

        checkCells : List (List Int) -> Bool
        checkCells linesToCheck =
            linesToCheck |> List.any (match game.currentPlayer.marker)
    in
    get cellNr lines |> Maybe.map checkCells |> Maybe.withDefault False


renderCell : Int -> CellState -> Html Message
renderCell cellNr cellState =
    case cellState of
        Free ->
            td [ onClick (MarkCell cellNr) ] [ text "" ]

        Cross ->
            td [] [ text "X" ]

        Circle ->
            td [] [ text "O" ]


lineLength : Int
lineLength =
    3


boardSize : Int
boardSize =
    9


renderLine : Int -> Array CellState -> Html Message
renderLine lineNr line =
    tr [] (toList (indexedMap (\cellNr cellState -> renderCell (cellNr + lineNr * lineLength) cellState) line))


view : GameState -> Html Message
view model =
    case model of
        Starting ->
            Ui.game [ Ui.caption "Selecting starting player..." |> Html.Styled.map never ]

        Playing game ->
            Ui.game
                [ Ui.caption ("Current player is " ++ game.currentPlayer.symbol ++ ".") |> Html.Styled.map never
                , Ui.board (toList (indexedMap renderLine (chunked lineLength game.field)))
                ]

        Tie ->
            Ui.game
                [ Ui.caption "The game ended with a tie." |> Html.Styled.map never
                , Ui.textButton [ onClick Restart ] "Play again!"
                ]

        Winner player ->
            Ui.game
                [ Ui.caption ("Player " ++ player.symbol ++ " won the game.") |> Html.Styled.map never
                , Ui.textButton [ onClick Restart ] "Play again!"
                ]


init : () -> ( GameState, Cmd Message )
init _ =
    ( Starting, Random.generate PlayerSelected randomPlayer )


subscriptions : GameState -> Sub Message
subscriptions _ =
    Sub.none


documentView : GameState -> Document Message
documentView model =
    { title = "TicTacToe"
    , body = [ (view >> toUnstyled) model ]
    }
