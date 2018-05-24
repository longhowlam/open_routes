library(httr)
library(leaflet)
library(geojson)

key = readRDS("key.RDs")
link = "https://api.openrouteservice.org/isochrones"

ors_out = GET(
  url = link,
  add_headers("Accept" = "application/json" , "charset"="utf-8"),
  query = list(
    api_key  = key,
    profile  = "driving-car",
    locations = "4.8510,52.3090",
    range_type = "time",
    range = "2000",
    interval = "2000"
  )
) %>% content("text") %>% 
  as.geojson()

leaflet() %>%
  addTiles() %>%
  addGeoJSON(ors_out) %>% 
  fitBounds(bbox_get(ors_out)[1], bbox_get(ors_out)[2], bbox_get(ors_out)[3], bbox_get(ors_out)[4])
  
