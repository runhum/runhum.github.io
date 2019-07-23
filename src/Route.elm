module Route exposing (Route(..), routeParser, routeToString)

import Url exposing (Url)
import Url.Parser as Parser exposing (..)


type Route
    = Home
    | GameOfLife


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Home Parser.top
        , map GameOfLife (s "life")
        ]


routeToString : Route -> String
routeToString route =
    case route of
        Home ->
            "/"

        GameOfLife ->
            "/life"
