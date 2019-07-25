module Page.Page exposing (Page(..))

import Page.Home as Home
import Page.Life as Life
import Page.Projects as Projects


type Page
    = Home Home.Model
    | Life Life.Model
    | Projects Projects.Model
    | NotFound
