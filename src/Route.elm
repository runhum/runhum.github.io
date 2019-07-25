module Route exposing (Route(..), fromURL, routeParser, routeToString)

import Url exposing (Url)
import Url.Parser as Parser exposing (..)


type Route
    = Home
    | GameOfLife
    | Projects
    | NotFound


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home Parser.top
        , map GameOfLife (s "life")
        , map Projects (s "projects")
        ]


fromURL : Url -> Route
fromURL url =
    Maybe.withDefault NotFound (Parser.parse routeParser url)


routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            "/"

        GameOfLife ->
            "/life"

        Projects ->
            "/projects"

        NotFound ->
            "/"
