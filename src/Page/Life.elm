module Page.Life exposing (GameState(..), Model, Msg, createGrid, init, subscriptions, toggleLife, update, view)

import Array as Array exposing (Array)
import Browser.Events
import Element exposing (..)
import Element.Background as Background
import Element.Border as Border
import Element.Events as Events
import Element.Font as Font
import Element.Input as Input
import Json.Decode as Decode
import Time as Time



-- INIT


init : GridSize -> ( Model, Cmd Msg )
init size =
    ( Model (createGrid size) Paused, Cmd.none )



-- MODEL


type alias Model =
    { grid : Grid
    , gameState : GameState
    }


type GameState
    = Running
    | Paused


type alias Position =
    { x : Int, y : Int }


type CellState
    = Alive
    | Dead


type alias Cell =
    { state : CellState
    , position : Position
    }


type alias Grid =
    Array (Array Cell)


type alias GridSize =
    ( Int, Int )


toggleLife : Msg
toggleLife =
    ToggleGameState


createGrid : GridSize -> Grid
createGrid ( rowCount, columnCount ) =
    Array.initialize columnCount <|
        \column ->
            Array.initialize rowCount <|
                \row ->
                    { state = Dead
                    , position = { x = row, y = column }
                    }


getCell : Position -> Grid -> Maybe Cell
getCell position grid =
    let
        maybeRow =
            Array.get position.y grid
    in
    case maybeRow of
        Just row ->
            Array.get position.x row

        Nothing ->
            Nothing



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DidTapCell cell ->
            let
                row =
                    Array.get cell.position.y model.grid

                newArray =
                    case row of
                        Just aRow ->
                            Array.set cell.position.x (toggleCellState cell) aRow

                        Nothing ->
                            Array.empty

                updatedGrid =
                    Array.set cell.position.y newArray model.grid
            in
            ( { model | grid = updatedGrid }, Cmd.none )

        Tick time ->
            case model.gameState of
                Running ->
                    ( { model | grid = generateNext model }, Cmd.none )

                Paused ->
                    ( model, Cmd.none )

        ToggleGameState ->
            let
                newGameState =
                    case model.gameState of
                        Running ->
                            Paused

                        Paused ->
                            Running
            in
            ( { model | gameState = newGameState }, Cmd.none )


type Msg
    = DidTapCell Cell
    | Tick Time.Posix
    | ToggleGameState


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every 250 Tick
        ]


toggleCellState : Cell -> Cell
toggleCellState cell =
    let
        newState =
            case cell.state of
                Alive ->
                    Dead

                Dead ->
                    Alive
    in
    { state = newState, position = cell.position }


getNeighbourCount : Cell -> Grid -> Int
getNeighbourCount cell grid =
    let
        inGrid pos =
            getCell pos grid

        left =
            inGrid { x = cell.position.x - 1, y = cell.position.y }

        topLeft =
            inGrid { x = cell.position.x - 1, y = cell.position.y - 1 }

        top =
            inGrid { x = cell.position.x, y = cell.position.y - 1 }

        topRight =
            inGrid { x = cell.position.x + 1, y = cell.position.y + 1 }

        right =
            inGrid { x = cell.position.x + 1, y = cell.position.y }

        bottomRight =
            inGrid { x = cell.position.x + 1, y = cell.position.y - 1 }

        bottom =
            inGrid { x = cell.position.x, y = cell.position.y + 1 }

        bottomLeft =
            inGrid { x = cell.position.x - 1, y = cell.position.y + 1 }

        neighbours =
            List.filter (\c -> c.state == Alive) <|
                List.filterMap identity [ left, topLeft, top, topRight, right, bottomRight, bottom, bottomLeft ]
    in
    List.length neighbours


updateCellState : Cell -> Int -> CellState
updateCellState cell neighbourCount =
    case ( cell.state, neighbourCount ) of
        ( Alive, 2 ) ->
            Alive

        ( Alive, 3 ) ->
            Alive

        ( Dead, 3 ) ->
            Alive

        _ ->
            Dead


generateNext : Model -> Grid
generateNext model =
    let
        newGrid =
            Array.map
                (\row ->
                    Array.map
                        (\cell ->
                            { state = updateCellState cell (getNeighbourCount cell model.grid), position = cell.position }
                        )
                        row
                )
                model.grid
    in
    newGrid



-- VIEW


view : Model -> Element Msg
view model =
    column [ centerX, spacing 10 ]
        [ playButton model.gameState
        , el [ centerX ] <|
            column
                [ width fill
                , height fill
                , spacing verticalSpacing
                ]
            <|
                Array.toList <|
                    Array.map gridRow model.grid
        ]


playButton : GameState -> Element Msg
playButton gameState =
    let
        ( buttonColor, buttonText ) =
            case gameState of
                Running ->
                    ( rgb255 255 69 58, "Pause" )

                Paused ->
                    ( rgb255 48 209 88, "Resume" )
    in
    Input.button
        [ centerX
        , Background.color buttonColor
        , padding 15
        , Border.rounded 6
        , Font.color (rgb 1 1 1)
        , Font.bold
        ]
        { onPress = Just ToggleGameState, label = text buttonText }


cellSize =
    15


getCellColors : Cell -> List Element.Color
getCellColors cell =
    case cell.state of
        Alive ->
            [ rgb255 48 209 88
            , rgb255 52 199 89
            ]

        Dead ->
            [ rgba255 24 24 29 0.2 ]


cellView : Cell -> Element Msg
cellView cell =
    el
        [ width (px cellSize)
        , height (px cellSize)
        , pointer
        , Border.rounded 4
        , Background.gradient { angle = 1, steps = getCellColors cell }
        , Events.onClick <| DidTapCell cell
        ]
        none


horizontalSpacing =
    5


verticalSpacing =
    5


gridRow : Array Cell -> Element Msg
gridRow array =
    row [ spacing horizontalSpacing ] (Array.toList <| Array.map cellView array)
