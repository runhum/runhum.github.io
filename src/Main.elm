module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Browser.Navigation as Nav
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Page.Home
import Page.Life
import Page.Page as Page
import Route as Route
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
    , hoveringTab : Maybe NavBarTab
    , page : Page.Page
    , route : Route.Route
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        model =
            { key = key
            , hoveringTab = Nothing
            , page = Page.Home Page.Home.initModel
            , route = Route.fromURL url
            }
    in
    ( model, Cmd.none ) |> loadCurrentPage



-- UPDATE


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | NavBarTabHovered NavBarTab
    | HomeMsg Page.Home.Msg
    | LifeMsg Page.Life.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            ( { model | route = Route.fromURL url }
            , Cmd.none
            )

        ( NavBarTabHovered tab, _ ) ->
            ( { model | hoveringTab = Just tab }, Cmd.none )

        ( HomeMsg subMsg, Page.Home pageModel ) ->
            let
                ( newPageModel, newCmd ) =
                    Page.Home.update subMsg pageModel
            in
            ( { model | page = Page.Home newPageModel }, Cmd.map HomeMsg newCmd )

        ( _, _ ) ->
            ( model, Cmd.none )


loadCurrentPage : ( Model, Cmd Msg ) -> ( Model, Cmd Msg )
loadCurrentPage ( model, cmd ) =
    let
        ( page, newCmd ) =
            case model.route of
                Route.Home ->
                    let
                        ( pageModel, pageCmd ) =
                            Page.Home.init
                    in
                    ( Page.Home pageModel, Cmd.map HomeMsg pageCmd )

                Route.GameOfLife ->
                    let
                        ( pageModel, pageCmd ) =
                            Page.Life.init ( 40, 40 )
                    in
                    ( Page.Life pageModel, Cmd.map LifeMsg pageCmd )

                Route.NotFound ->
                    ( Page.NotFound, cmd )
    in
    ( { model | page = page }, Cmd.batch [ cmd, newCmd ] )



-- SUBSCRIPTIONS
-- TODO!!


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []



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
        [ link
            [ alignLeft
            , Font.extraBold
            ]
            { label = text "Runar Hummelsund", url = Route.routeToString Route.Home }
        , link
            [ alignRight
            , Events.onMouseEnter <| NavBarTabHovered GitHub
            ]
            { url = "https://github.com/runhum"
            , label =
                text "GitHub"
            }
        , link
            [ alignRight
            ]
            { label = text "Life", url = Route.routeToString Route.GameOfLife }
        ]


content : Model -> Element Msg
content model =
    el [] (text "Hello")


footer : Element Msg
footer =
    row [ width fill, height (px 60), alignBottom ]
        []


title =
    32
