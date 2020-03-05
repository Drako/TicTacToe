module TestHelpers exposing (..)

import Expect exposing (Expectation)
import Test exposing (Test, describe, test)


parameterized : String -> List a -> (a -> Expectation) -> Test
parameterized name parameters testFunction =
    describe name <|
        List.map
            (\parameter -> test (Debug.toString parameter) <| \_ -> testFunction parameter)
            parameters
