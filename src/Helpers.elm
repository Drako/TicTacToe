module Helpers exposing (..)

import Array exposing (..)


chunked : Int -> Array a -> Array (Array a)
chunked size source =
    initialize (length source // size) (\chunk -> slice (size * chunk) (size * chunk + size) source)


getOr : Int -> Array a -> a -> a
getOr index array fallback =
    get index array |> Maybe.withDefault fallback
