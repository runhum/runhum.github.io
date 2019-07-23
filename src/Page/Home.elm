module Page.Home exposing (Model, Msg, init, initModel, update)

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


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )
