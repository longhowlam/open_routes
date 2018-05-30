key  = readRDS("key.RDs")
link = "https://api.openrouteservice.org/isochrones"
PC   = readRDS("data/PC.RDs")
CBS  = readRDS("data/CBS.RDs")



server = function(input, output, session){
  
  getPuntLocation <- reactive({
    pc6 = getinputs()$pc6
    PC[pc6]
  })
  
  getinputs <- eventReactive(input$goButton, {
    list(
      pc6 = input$pc6,
      profile = input$profile,
      tijd = input$tijd
    )
  })
  
  apicall = reactive({
   
    pc6 = getinputs()$pc6
    inprofile = getinputs()$profile
    tijd = getinputs()$tijd * 60
    
    tmp = PC[pc6]
    locatie = paste( tmp[1,2], tmp[1,3], sep = ",")
    
    GET(
      url = link,
      add_headers("Accept" = "application/json" , "charset"="utf-8"),
      query = list(
        api_key  = key,
        profile  = inprofile,
        locations = locatie,
        range_type = "time",
        range = tijd,
        interval = tijd
      )
    ) 
    
  })
  
  
  
  output$kaartje = renderLeaflet({
    
    puntlocatie = getPuntLocation()
    ors_out = apicall() %>%
      content("text") %>%
      as.geojson()
    
    #### plot de regio op een leaflet
    leaflet() %>%
      addTiles() %>%
      addGeoJSON(ors_out) %>% 
      addMarkers(
        lng = puntlocatie$Long_Postcode6P,
        lat = puntlocatie$Lat_Postcode6P
      ) %>% 
      fitBounds(bbox_get(ors_out)[1], bbox_get(ors_out)[2], bbox_get(ors_out)[3], bbox_get(ors_out)[4])
  })
  
  output$kinderen <- renderValueBox({
    spobject = apicall() %>% 
      content("text") %>%
      as.geojson() %>% 
      geojson_sp()
    
    covered_pc4 = over(
      CBS, 
      spobject
    ) %>%
      bind_cols(CBS@data) %>% 
      filter(!is.na(group_index))
    
    TotaalMensen = sum(covered_pc4$INWONER[covered_pc4$INWONER > 0])
    Kinderen = sum(covered_pc4$INW_014[covered_pc4$INW_014 > 0])
    
    valueBox(
      value = paste(formatC(100*Kinderen/TotaalMensen, digits = 2, format = "f", decimal.mark = ","),"%"),
      subtitle = "% tot 14 jaar van totaal",
      icon = icon("area-chart"),
      color = "yellow"
    )
  })

  output$mensen <- renderValueBox({
    
    spobject = apicall() %>% 
      content("text") %>%
      as.geojson() %>% 
      geojson_sp()
    
    covered_pc4 = over(
      CBS, 
      spobject
    ) %>%
      bind_cols(CBS@data) %>% 
      filter(!is.na(group_index))
    
    TotaalMensen = sum(covered_pc4$INWONER)
    
    valueBox(
      value = formatC(TotaalMensen, digits = 0, format = "f", big.mark = "."),
      subtitle = "Aantal mensen in gebied",
      icon = icon("area-chart"),
      color = "yellow"
    )
  })

  output$uitkering <- renderValueBox({
    spobject = apicall() %>% 
      content("text") %>%
      as.geojson() %>% 
      geojson_sp()
    
    covered_pc4 = over(
      CBS, 
      spobject
    ) %>%
      bind_cols(CBS@data) %>% 
      filter(!is.na(group_index))
    
    TotaalMensen = sum(covered_pc4$INWONER[covered_pc4$INWONER > 0])
    uitkering = sum(covered_pc4$UITKMINAOW[covered_pc4$UITKMINAOW > 0], na.rm = TRUE)
    
    valueBox(
      value = paste(formatC(100*uitkering/TotaalMensen, digits = 2, format = "f", decimal.mark = ","), "%"),
      subtitle = "% mensen met uitkering",
      icon = icon("area-chart"),
      color = "yellow"
    )
  })
  
  
}