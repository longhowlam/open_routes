key = readRDS("key.RDs")
link = "https://api.openrouteservice.org/isochrones"
PC = readRDS("data/PC.RDs")

server = function(input, output, session){
  
  output$kaartje = renderLeaflet({
    
    locatie = paste( PC[input$pc6][1,2], PC[input$pc6][1,3], sep = ",")
    tijd = input$tijd*60
    ors_out = GET(
      url = link,
      add_headers("Accept" = "application/json" , "charset"="utf-8"),
      query = list(
        api_key  = key,
        profile  = input$profile,
        locations = locatie,
        range_type = "time",
        range = tijd,
        interval = tijd
      )
    ) %>%
      content("text") %>%
      as.geojson()
    
    #### plot de regio op een leaflet
    leaflet() %>%
      addTiles() %>%
      addGeoJSON(ors_out) %>% 
      fitBounds(bbox_get(ors_out)[1], bbox_get(ors_out)[2], bbox_get(ors_out)[3], bbox_get(ors_out)[4])
    
    
  })
}