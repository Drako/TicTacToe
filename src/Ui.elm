module Ui exposing (..)

import Css exposing (..)
import Css.Global exposing (descendants, typeSelector)
import Html.Styled exposing (Attribute, Html, styled, text)


caption : String -> Html Never
caption content =
    Html.Styled.p [] [ text content ]


textButton : List (Attribute msg) -> String -> Html msg
textButton attributes content =
    Html.Styled.button attributes [ text content ]


game : List (Html msg) -> Html msg
game =
    styled Html.Styled.div
        [ width (px 300)
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
        []


board : List (Html msg) -> Html msg
board =
    styled Html.Styled.table
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
        []
