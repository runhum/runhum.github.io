module Page.Home exposing (Model, Msg, init, initModel, subscriptions, update, view)

import Element exposing (..)



-- INIT


type alias Model =
    String


init : ( Model, Cmd Msg )
init =
    ( "", Cmd.none )


initModel : Model
initModel =
    ""



-- UPDATE


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Element Msg
view model =
    el [ centerX, centerY ] (text "Hello")
