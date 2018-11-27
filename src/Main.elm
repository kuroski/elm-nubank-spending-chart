module Main exposing (main)

import Browser exposing (Document, document)
import Dict exposing (Dict)
import Html exposing (Html, br, button, div, form, input, text)
import Html.Attributes exposing (placeholder, type_, value)
import Html.Events exposing (onInput, onSubmit)
import Http
import Json.Decode as Decoder
import Json.Encode as Encode



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
    { token : String
    , cpf : String
    , password : String
    , preferredName : String
    , loginUrl : String
    }


init : a -> ( Model, Cmd Msg )
init _ =
    ( { token = ""
      , cpf = ""
      , password = ""
      , preferredName = ""
      , loginUrl = ""
      }
    , discoverUrls
    )



-- API


discoverUrlsDecoder : Decoder.Decoder String
discoverUrlsDecoder =
    Decoder.field "login" Decoder.string


authenticationDecoder : Decoder.Decoder { token : String, customerUrl : String }
authenticationDecoder =
    Decoder.map2 (\token customerUrl -> { token = token, customerUrl = customerUrl })
        (Decoder.field "access_token" Decoder.string)
        (Decoder.at [ "_links", "customer", "href" ] Decoder.string)


customerDecoder : Decoder.Decoder String
customerDecoder =
    Decoder.field "preferred_name" Decoder.string


requestEncoder : String -> String -> Encode.Value
requestEncoder cpf password =
    Encode.object
        [ ( "grant_type", Encode.string "password" )
        , ( "login", Encode.string cpf )
        , ( "password", Encode.string password )
        , ( "client_id", Encode.string "other.conta" )
        , ( "client_secret", Encode.string "yQPeLzoHuJzlMMSAjC-LgNUJdUecx8XO" )
        ]


discoverUrls : Cmd Msg
discoverUrls =
    Http.get
        { url = "https://prod-s0-webapp-proxy.nubank.com.br/api/discovery"
        , expect = Http.expectJson GotLoginUrl discoverUrlsDecoder
        }


userLogin : String -> String -> String -> Cmd Msg
userLogin url cpf password =
    let
        body =
            Http.jsonBody <| requestEncoder cpf password
    in
    Http.post
        { url = url
        , body = body
        , expect = Http.expectJson GotAuthenticationDetails authenticationDecoder
        }


customerInformation : String -> String -> Cmd Msg
customerInformation url token =
    Http.request
        { url = url
        , method = "GET"
        , headers =
            [ Http.header "X-Correlation-Id" "WEB-APP.pewW9"
            , Http.header "User-Agent" "GUI Metrics Test"
            , Http.header "Authorization" ("Bearer " ++ token)
            ]
        , body = Http.emptyBody
        , expect = Http.expectJson GotCustomerDetails customerDecoder
        , timeout = Nothing
        , tracker = Nothing
        }



-- UPDATE


type Msg
    = CpfInputChanged String
    | PasswordInputChanged String
    | DispatchLogin
    | GotLoginUrl (Result Http.Error String)
    | GotAuthenticationDetails (Result Http.Error { token : String, customerUrl : String })
    | GotCustomerDetails (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CpfInputChanged cpf ->
            ( { model | cpf = cpf }, Cmd.none )

        PasswordInputChanged password ->
            ( { model | password = password }, Cmd.none )

        DispatchLogin ->
            ( model, userLogin model.loginUrl model.cpf model.password )

        GotLoginUrl (Ok url) ->
            ( { model | loginUrl = url }, Cmd.none )

        GotLoginUrl (Err _) ->
            ( model, Cmd.none )

        GotAuthenticationDetails (Ok data) ->
            ( { model | token = data.token }, customerInformation data.customerUrl data.token )

        GotAuthenticationDetails (Err _) ->
            ( model, Cmd.none )

        GotCustomerDetails (Ok preferredName) ->
            ( { model | preferredName = preferredName }, Cmd.none )

        GotCustomerDetails (Err _) ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : model -> Sub msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Document Msg
view model =
    { title = "Nubank - Statistics"
    , body =
        [ loginForm model
        , br [] []
        , br [] []
        , br [] []
        , br [] []
        , div [] [ text model.loginUrl ]
        , br [] []
        , br [] []
        , br [] []
        , br [] []
        , div [] [ text model.token ]
        , br [] []
        , br [] []
        , br [] []
        , br [] []
        , div [] [ text <| "You PreferredName is: " ++ model.preferredName ]
        ]
    }


loginForm : Model -> Html Msg
loginForm model =
    form [ onSubmit DispatchLogin ]
        [ input
            [ placeholder "CPF"
            , value model.cpf
            , onInput CpfInputChanged
            ]
            []
        , input
            [ placeholder "Password"
            , type_ "password"
            , value model.password
            , onInput PasswordInputChanged
            ]
            []
        , button [ type_ "submit" ] [ text "Login" ]
        ]
