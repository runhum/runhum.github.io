module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Life as Life
import Time
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
    , hoveringTab : Maybe NavBarTab
    , life : Life.Model
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        ( life, cmd ) =
            Life.init ( 50, 30 )
    in
    ( Model key url Nothing life, Cmd.none )



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavBarTabHovered NavBarTab
    | LifeMsg Life.Msg
    | Tick Time.Posix


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

        NavBarTabHovered tab ->
            ( { model | hoveringTab = Just tab }, Cmd.none )

        LifeMsg subMsg ->
            let
                ( life, cmd ) =
                    Life.update subMsg model.life
            in
            ( { model | life = life }, Cmd.map LifeMsg cmd )

        Tick posix ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map LifeMsg (Life.subscriptions model.life)
        ]



-- VIEW


view : Model -> Browser.Document Msg
view model =
    { title = "Runar Hummelsund"
    , body =
        [ Element.layout []
            (column [ width fill, height fill ]
                [ navbar model
                , content model
                , footer
                ]
            )
        ]
    }


backgroundColor =
    rgb255 255 255 255


navbarColor =
    rgb255 255 255 255


type NavBarTab
    = GitHub
    | Link1
    | Link2


navbar : Model -> Element Msg
navbar model =
    row
        [ width fill
        , height (px 60)
        , Background.color navbarColor
        , spacing 20
        , paddingXY 20 0
        ]
        [ el [ alignLeft, Font.extraBold ] (text "Runar Hummelsund")

        {-

           , link
               [ alignRight
               , Events.onMouseEnter <| NavBarTabHovered GitHub
               ]
               { url = "https://github.com/runhum"
               , label =
                   text "GitHub"
               }
        -}
        ]


content : Model -> Element Msg
content model =
    let
        ( buttonColor, buttonText ) =
            case model.life.gameState of
                Life.Running ->
                    ( rgb255 255 69 58, "Pause" )

                Life.Paused ->
                    ( rgb255 48 209 88, "Resume" )
    in
    column [ centerX, spacing 10 ]
        [ Input.button
            [ centerX
            , Background.color buttonColor
            , padding 15
            , Border.rounded 6
            , Font.color (rgb 1 1 1)
            , Font.bold
            ]
            { onPress = Just (LifeMsg Life.toggleLife), label = text buttonText }
        , el [ centerX ] <|
            Element.map LifeMsg <|
                Life.view model.life
        ]


footer : Element Msg
footer =
    row [ width fill, height (px 60), alignBottom ]
        []


title =
    32
