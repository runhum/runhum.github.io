module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Font as Font
import Url



-- MAIN


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }



-- MODEL


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Test"
    , body =
        [ Element.layout [ width fill, height fill ]
            (column [ width fill, height fill ]
                [ navbar
                , content
                , footer
                ]
            )
        ]
    }


backgroundColor =
    rgb255 255 255 255


navbarColor =
    rgb255 255 255 255


navbar : Element Msg
navbar =
    row
        [ width fill
        , height (px 60)
        , Background.color navbarColor
        , spacing 20
        , paddingXY 20 0
        ]
        [ el [ alignLeft, Font.extraBold ] (text "Runar Hummelsund")
        , link [ alignRight ] { url = "", label = text "Github" }
        ]


content : Element Msg
content =
    row [ width fill, height fill, centerX, Background.color backgroundColor, padding 20 ]
        [ el [ centerX ] (text "Hello") ]


footer : Element Msg
footer =
    row [ width fill, height (px 60), alignBottom ]
        []


title =
    32
