### shiny dashboard app 

library(shiny)
library(shinydashboard)
library(leaflet)
library(httr)
library(geojson)
library(data.table)
library(geojson)
library(geojsonio)
library(sp)
library(dplyr)
library(shinycustomloader)
library(DT)
library(RColorBrewer)
library(colorRamps)


source("ui_part.R")
source("server_part.R")

shinyApp(ui,server)

