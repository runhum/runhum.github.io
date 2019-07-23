module Page.Page exposing (Page(..))

import Page.Home as Home
import Page.Life as Life


type Page
    = Home Home.Model
    | Life Life.Model
    | NotFound
