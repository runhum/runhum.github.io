module Page.Projects exposing (Model, Msg, init, subscriptions, update, view)

import Element exposing (..)



-- INIT


init : ( Model, Cmd Msg )
init =
    ( "", Cmd.none )


type alias Model =
    String



-- UPDATE


type Msg
    = NoOp


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )



-- VIEW


view : Model -> Element Msg
view model =
    el [ centerX ] (text "Todo")
