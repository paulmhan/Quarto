module Tests exposing (suite)

import Expect
import Fuzz exposing (Fuzzer)
import Pages.Quarto as Q exposing (Colour(..), Gamepiece, Pattern(..), Shape(..), Size(..))
import Test exposing (Test, describe, fuzz)



-- TESTS ON CALCULATING GAME WIN LOGIC


shapeFuzzer : Float -> Float -> Fuzzer Shape
shapeFuzzer freq1 freq2 =
    Fuzz.frequency
        [ ( freq1, Fuzz.constant Square )
        , ( freq2, Fuzz.constant Circle )
        ]


colourFuzzer : Float -> Float -> Fuzzer Colour
colourFuzzer freq1 freq2 =
    Fuzz.frequency
        [ ( freq1, Fuzz.constant Colour1 )
        , ( freq2, Fuzz.constant Colour2 )
        ]


sizeFuzzer : Float -> Float -> Fuzzer Size
sizeFuzzer freq1 freq2 =
    Fuzz.frequency
        [ ( freq1, Fuzz.constant Small )
        , ( freq2, Fuzz.constant Large )
        ]


patternFuzzer : Float -> Float -> Fuzzer Pattern
patternFuzzer freq1 freq2 =
    Fuzz.frequency
        [ ( freq1, Fuzz.constant Solid )
        , ( freq2, Fuzz.constant Hollow )
        ]


gamepieceFuzzer : Fuzzer Shape -> Fuzzer Colour -> Fuzzer Pattern -> Fuzzer Size -> Fuzzer Gamepiece
gamepieceFuzzer =
    Fuzz.map4 Gamepiece


winningGamepiecesFuzzer : Fuzzer (List Gamepiece)
winningGamepiecesFuzzer =
    let
        constantShape =
            gamepieceFuzzer (shapeFuzzer 1 0) (colourFuzzer 1 1) (patternFuzzer 1 1) (sizeFuzzer 1 1)

        constantColour =
            gamepieceFuzzer (shapeFuzzer 1 1) (colourFuzzer 1 0) (patternFuzzer 1 1) (sizeFuzzer 1 1)

        constantPattern =
            gamepieceFuzzer (shapeFuzzer 1 1) (colourFuzzer 1 1) (patternFuzzer 1 0) (sizeFuzzer 1 1)

        constantSize =
            gamepieceFuzzer (shapeFuzzer 1 1) (colourFuzzer 1 1) (patternFuzzer 1 0) (sizeFuzzer 1 1)
    in
    Fuzz.oneOf [ constantShape, constantColour, constantPattern, constantSize ]
        |> Fuzz.map (\gamepiece -> [ gamepiece, gamepiece, gamepiece, gamepiece ])


losingGamepiecesFuzzer : Fuzzer (List Gamepiece)
losingGamepiecesFuzzer =
    let
        firstGamepiece =
            gamepieceFuzzer (shapeFuzzer 1 0) (colourFuzzer 1 0) (patternFuzzer 1 0) (sizeFuzzer 1 0)

        secondGamepiece =
            gamepieceFuzzer (shapeFuzzer 0 1) (colourFuzzer 0 1) (patternFuzzer 0 1) (sizeFuzzer 0 1)
    in
    Fuzz.tuple ( firstGamepiece, secondGamepiece )
        |> Fuzz.map (\( first, second ) -> [ first, second, first, second ])


suite : Test
suite =
    describe "Game Logic"
        [ fuzz winningGamepiecesFuzzer "testing four cells that all share a matching dimension" <|
            \gamepieceList ->
                Q.matchingDimensions gamepieceList
                    |> Expect.true "the matching dimension function should return true"
        , fuzz losingGamepiecesFuzzer "testing four cells that do not share matching dimensions" <|
            \gamepieceList ->
                Q.matchingDimensions gamepieceList
                    |> Expect.false "the matching dimensions function should return false"
        ]
