module Main exposing (main)

import Browser
import Browser.Events exposing (onKeyUp)
import Html exposing (..)
import Html.Attributes exposing (..)
import Json.Decode as Decode

type Msg
    = NoOp
    | LetterKey Char
    | Backspace
    | EnterKey

type alias LetterGuess =
    { letter: Char
    , result: LetterResult
    }

type LetterResult
    = Wrong
    | RightLetter
    | RightLetterRightPlace

type alias Guess = List LetterGuess

type AppState
    = Loaded
    | Setup
    | Ready Int
    | CheckingGuess
    | Lost
    | Won

type alias Model =
    { appState: AppState
    , guesses: List Guess
    , currentGuess: String
    }

totalGuesses = 6

initialModel =
    { appState = Ready 6
    , guesses =
        [
            [ LetterGuess 'P' RightLetterRightPlace
            , LetterGuess 'A' Wrong
            , LetterGuess 'I' RightLetter
            , LetterGuess 'N' RightLetter
            , LetterGuess 'T' Wrong
            , LetterGuess 'S' Wrong
            ],
            [ LetterGuess 'P' RightLetterRightPlace
            , LetterGuess 'O' Wrong
            , LetterGuess 'R' RightLetter
            , LetterGuess 'I' RightLetter
            , LetterGuess 'N' RightLetter
            , LetterGuess 'G' Wrong
            ]
        ]
    , currentGuess = ""
    }

remainingGuesses : Model -> Int
remainingGuesses model =
    totalGuesses - List.length model.guesses

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case model.appState of
        Ready wordLength ->
            case msg of
                NoOp ->
                    (model, Cmd.none)

                LetterKey char ->
                    if String.length model.currentGuess < wordLength then
                        ({ model | currentGuess = String.concat [model.currentGuess, String.fromChar char] }, Cmd.none)
                    else
                        (model, Cmd.none)

                Backspace ->
                    if String.length model.currentGuess > 0 then
                        ({ model | currentGuess = String.slice 0 -1 model.currentGuess }, Cmd.none)
                    else
                        (model, Cmd.none)

                EnterKey ->
                    if String.length model.currentGuess == wordLength then
                        ({ model | currentGuess = "" }, Cmd.none)
                    else
                        (model, Cmd.none)
        _ ->
            (model, Cmd.none)


view : Model -> Html Msg
view model =
    case model.appState of
        Ready wordLength ->
            div [ class "container" ]
                [ h1 [] [ text "Sandwichle" ]
                , div
                    [ class "board" ]
                    (
                        List.concat
                            [ (List.map viewGuessRow (model.guesses))
                            , if remainingGuesses model > 0 then [viewInputRow model.currentGuess wordLength] else []
                            , if remainingGuesses model  > 1 then List.repeat (remainingGuesses model  - 1) (viewEmptyRow wordLength) else []
                            ]
                    )
                ]
        _ ->
            div [] [text "Not Yet Implemented"]

viewGuessRow : Guess -> Html Msg
viewGuessRow letterGuesses =
    div [ class "row" ] (List.map viewLetterGuessBox letterGuesses)

viewLetterGuessBox : LetterGuess -> Html Msg
viewLetterGuessBox letterGuess =
    let
        classes = case letterGuess.result of
            Wrong ->
                "box"
            RightLetter ->
                "box letter"
            RightLetterRightPlace ->
                "box letter-spot"
    in
        div [ class classes ] [ text (String.fromChar letterGuess.letter) ]

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

main : Program () Model Msg
main =
    Browser.element
        { init = \flags -> ( initialModel, Cmd.none )
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
