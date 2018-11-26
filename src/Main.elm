module Main exposing (main)

import Browser exposing (Document, document)
import Html exposing (Html, button, div, text)



-- MAIN


main : Program () Model Msg
main =
    document
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    {}


init : a -> ( Model, Cmd Msg )
init _ =
    ( {}, Cmd.none )



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : model -> Sub msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document msg
view model =
    { title = "Nubank - Statistics"
    , body =
        [ div [] [ text "ola mundo" ]
        ]
    }
