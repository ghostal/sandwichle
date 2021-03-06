module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyUp)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode exposing (Decoder, map2, field, string, int)
import Json.Encode as Encode

type Msg
    = NoOp
    | GotPuzzle (Result Http.Error Puzzle)
    | GuessResultReceived (Result Http.Error GuessResult)
    | LetterKey Char
    | Backspace
    | EnterKey
    | PlayAgain

type alias Puzzle =
    { id: Int
    , wordLength: Int
    }

type alias LetterGuess =
    { letter: String
    , result: LetterResult
    }

type LetterResult
    = WrongLetter
    | RightLetter
    | RightLetterRightPlace

type alias GuessResult = List LetterGuess

type AppState
    = Loading
    | FailedToLoad Http.Error
    | Ready Puzzle
    | CheckingGuess Puzzle
    | Lost Puzzle
    | Won Puzzle

type alias Model =
    { appState: AppState
    , guesses: List GuessResult
    , currentGuess: String
    }

totalGuesses = 6

initialModel =
    { appState = Loading
    , guesses = []
    , currentGuess = ""
    }

remainingGuesses : Model -> Int
remainingGuesses model =
    totalGuesses - List.length model.guesses

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.appState of
        Loading ->
            case msg of
                GotPuzzle result ->
                    case result of
                        Ok puzzle ->
                            ({ model | appState = Ready puzzle}, Cmd.none)
                        Err errorMessage ->
                            ({ model | appState = FailedToLoad errorMessage}, Cmd.none)
                _ ->
                    (model, Cmd.none)
        FailedToLoad _ ->
            case msg of
                PlayAgain ->
                    ( initialModel
                    , Http.get
                        { url = "http://127.0.0.1:8000/api/puzzle/random"
                        , expect = Http.expectJson GotPuzzle puzzleDecoder
                        }
                    )
                _ ->
                    (model, Cmd.none)
        Ready puzzle ->
            case msg of
                LetterKey char ->
                    if String.length model.currentGuess < puzzle.wordLength then
                        ({ model | currentGuess = String.concat [model.currentGuess, String.fromChar char] }, Cmd.none)
                    else
                        (model, Cmd.none)

                Backspace ->
                    if String.length model.currentGuess > 0 then
                        ({ model | currentGuess = String.slice 0 -1 model.currentGuess }, Cmd.none)
                    else
                        (model, Cmd.none)

                EnterKey ->
                    if String.length model.currentGuess == puzzle.wordLength then
                        ({ model | appState = CheckingGuess puzzle }, submitGuess puzzle model.currentGuess)
                    else
                        (model, Cmd.none)

                _ ->
                    (model, Cmd.none)

        CheckingGuess puzzle ->
            case msg of
                GuessResultReceived result ->
                    case result of
                        Ok guessResult ->
                            ({ model
                            | currentGuess = ""
                            , guesses = List.append model.guesses [guessResult]
                            , appState =
                                if isWinningGuess guessResult then
                                    Won puzzle
                                else
                                    if remainingGuesses model == 1 then
                                        Lost puzzle
                                    else
                                        Ready puzzle
                            }, Cmd.none)
                        Err errorMessage ->
                            ({ model | appState = Ready puzzle }, Cmd.none)
                _ ->
                    (model, Cmd.none)
        Won puzzle ->
            case msg of
                PlayAgain ->
                    init ()
                _ ->
                    (model, Cmd.none)

        Lost puzzle ->
            case msg of
                PlayAgain ->
                    init ()
                _ ->
                    (model, Cmd.none)

isWinningGuess: GuessResult -> Bool
isWinningGuess guessResult =
    List.foldl
    (\letterGuess carry -> carry && letterGuess.result == RightLetterRightPlace)
    True
    guessResult

view : Model -> Html Msg
view model =
    case model.appState of
        Loading ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , div [] [ img [src "loading.gif"] [] ]
                , div [] [text "Loading puzzle..."]
                ]
        FailedToLoad error ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , div [] [text "Sorry, there was an error loading the puzzle."]
                , button [onClick PlayAgain] [text "THE OTHER TEAMS HAVE SABOTAGED OUR PROJECT!!! QUICK, TRY AGAIN!!!"]
                ]
        Ready puzzle ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , showBoard model puzzle
                ]
        CheckingGuess puzzle ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , showBoard model puzzle
                , div [] [ img [src ("guess-" ++ String.fromInt ((List.length model.guesses) + 1) ++ ".gif")] []
                , div [] [text "Your guess is being checked!"]
                ]
                ]

        Won puzzle ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , showBoard model puzzle
                , div [] [ img [src "winner.gif"] []
                , div [] [text "You won! Outstanding! Time to celebrate with a sandwich!"]
                , button [onClick PlayAgain] [text "Try your luck again, champion?"]
                ]
                ]

        Lost puzzle ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , showBoard model puzzle
                , div [] [ img [src "loser.gif"] []
                , div [] [text "Sorry, champ. I'm afraid you didn't win this time. Have a rejuvenating sandwich and try again!"]
                , button [onClick PlayAgain] [text "I have eaten a sandwich and mentally prepared myself for another challenge"]
                ]
                ]

showBoard : Model -> Puzzle -> Html Msg
showBoard model puzzle =
    div
        [ class "board" ]
        (
            List.concat
                [ (List.map viewGuessRow (model.guesses))
                , if remainingGuesses model > 0 && model.appState == Ready puzzle || model.appState == CheckingGuess puzzle then [viewInputRow model.currentGuess puzzle.wordLength] else []
                , if remainingGuesses model > 1 then List.repeat (remainingGuesses model - (if model.appState == Ready puzzle || model.appState == CheckingGuess puzzle then 1 else 0)) (viewEmptyRow puzzle.wordLength) else []
                ]
        )

viewGuessRow : GuessResult -> Html Msg
viewGuessRow letterGuesses =
    div [ class "row" ] (List.map viewLetterGuessBox letterGuesses)

viewLetterGuessBox : LetterGuess -> Html Msg
viewLetterGuessBox letterGuess =
    let
        classes = case letterGuess.result of
            WrongLetter ->
                "box"
            RightLetter ->
                "box letter"
            RightLetterRightPlace ->
                "box letter-spot"
    in
        div [ class classes ] [ text letterGuess.letter ]

viewInputRow : String -> Int -> Html Msg
viewInputRow currentGuess wordLength =
    div [ class "row" ] (List.concat
        [ (List.map viewInputBox (String.toList currentGuess))
        , if String.length currentGuess == wordLength then
                []
            else
                List.repeat
                    (wordLength - String.length currentGuess)
                    (div [ class "box active empty" ] [ text "?" ])
        ])

viewInputBox : Char -> Html Msg
viewInputBox char =
    div [ class "box active" ] [ text (String.fromChar char) ]

viewEmptyRow: Int -> Html Msg
viewEmptyRow wordLength =
    div [ class "row" ] (List.repeat wordLength viewEmptyBox)

viewEmptyBox : Html Msg
viewEmptyBox =
    div [ class "box" ] []


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ onKeyUp keyDecoder
        ]

keyDecoder : Decode.Decoder Msg
keyDecoder =
    Decode.map toKey (Decode.field "key" Decode.string)

toKey : String -> Msg
toKey keyValue =
    case String.uncons keyValue of
        Just ( char, "" ) ->
            if String.contains (String.fromChar (Char.toLower char)) "abcdefghijklmnopqrstuvwxyz" then
                LetterKey (Char.toLower char)
            else
                NoOp

        _ ->
            case keyValue of
                "Enter" ->
                    EnterKey
                "Backspace" ->
                    Backspace
                _ ->
                    NoOp

init : () -> (Model, Cmd Msg)
init _ =
    ( initialModel
    , Http.get
        { url = "http://127.0.0.1:8000/api/puzzle/random"
        , expect = Http.expectJson GotPuzzle puzzleDecoder
        }
    )

puzzleDecoder : Decode.Decoder Puzzle
puzzleDecoder =
    Decode.map2 Puzzle
        (Decode.field "puzzleId" int)
        (field "wordLength" int)

submitGuess : Puzzle -> String -> Cmd Msg
submitGuess puzzle guess =
    Http.post
        { url = String.concat [ "http://127.0.0.1:8000/api/puzzle/", String.fromInt puzzle.id, "/guess" ]
        , body = Http.jsonBody (Encode.object [("guess", Encode.string guess )])
        , expect = Http.expectJson GuessResultReceived guessResultDecoder
        }

guessResultDecoder : Decode.Decoder GuessResult
guessResultDecoder =
    Decode.list (
        Decode.map2 LetterGuess
            (Decode.field "letter" Decode.string)
            (Decode.field "result" Decode.string |> Decode.andThen guessResultLetterResultDecoder)
    )

guessResultLetterResultDecoder : String -> Decode.Decoder LetterResult
guessResultLetterResultDecoder string =
    case string of
        "right-letter-right-spot" ->
            Decode.succeed RightLetterRightPlace
        "right-letter-wrong-spot" ->
            Decode.succeed RightLetter
        "wrong-letter" ->
            Decode.succeed WrongLetter
        _ ->
            Decode.fail <| "Unexpected letter result: " ++ string

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
