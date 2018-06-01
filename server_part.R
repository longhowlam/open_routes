################### import data ####################################
key  = readRDS("key.RDs")
link = "https://api.openrouteservice.org/isochrones"
PC   = readRDS("data/PC.RDs")
CBS  = readRDS("data/CBS.RDs")

####### SERVER FUNCTIE ############################################

server = function(input, output, session){
  
  #### reactive stuff #################################
  getPuntLocation <- reactive({
    pc6 = getinputs()$pc6
    PC[pc6]
  })
  
  getinputs <- eventReactive(input$goButton, {
    list(
      pc6 = str_to_upper(str_remove(input$pc6, "\\s")),
      profile = input$profile,
      tijd = input$tijd,
      plotpc4shapes = input$plotpc4shapes
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
  
  ########## intro text  ###############################
  output$intro = renderUI({
    list(
      h4("Shiny app om te zien wat er op bepaalde reisafstand van een postocde zit"),
      h5("Type een postocde in, bijv 1183AA en een maximale reistijd en click go.
         Er verschijnt een plaatje met de omtrek en alle postcode4 gebieden. De tabel geeft
         kenmerken per postoce 4 gebied die in de maximale reisafstand zitten.")
    )
  })
  
  ######## leaflet with regions ########################
  output$kaartje = renderLeaflet({
    
    puntlocatie = getPuntLocation()
    ors_out = apicall() %>%
      content("text") %>%
      as.geojson()
    
    m = leaflet() %>%
      addTiles() %>%
      addGeoJSON(ors_out) %>% 
      addMarkers(
        lng = puntlocatie$Long_Postcode6P,
        lat = puntlocatie$Lat_Postcode6P
      ) %>% 
      fitBounds(
        bbox_get(ors_out)[1], bbox_get(ors_out)[2],
        bbox_get(ors_out)[3], bbox_get(ors_out)[4]
      )
    
    if(getinputs()$plotpc4shapes){
      
      spobject =  ors_out %>% 
        geojson_sp()
      covered_pc4 = over(
        CBS, 
        spobject
      )
      indx = (1:dim(covered_pc4)[1])[!is.na(covered_pc4$group_index)]
      pp = CBS[indx,]
      
      labels <- sprintf(
        "<strong>postcode</strong> %g <br/> aantal inwoners %g",
        pp$PC4, pp$INWONER
      ) %>% lapply(htmltools::HTML)
      
      colpal <- colorQuantile(
        palette = green2red(7), n=7,
        domain = pp$INWONER
      )
      
      m = m %>% 
      addPolygons(
        data = pp,
        fillColor = colpal(pp$INWONER),
        stroke = TRUE, weight = 1, fillOpacity = 0.15, smoothFactor = 0.15,
        highlightOptions = highlightOptions(
          color = "white", weight = 6,
          bringToFront = TRUE
        ),
        label = labels,
        labelOptions = labelOptions(
          style = list("font-weight" = "normal", padding = "3px 8px"),
          textsize = "15px",
          direction = "auto")
        )
    }
    m
  })
  
  ###### value boxes #########################
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
  
  ##### data table et PC4's #####################
  output$pc4tabel <- renderDataTable({
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
    
    datatable( 
      rownames = FALSE,
      covered_pc4 %>% select(
        PC4, INWONER, MAN, VROUW, 
        INW_014, INW_1524, INW_2544,INW_4564,INW_65PL,
        WONING, AANTAL_HH, UITKMINAOW
      ),
      filter = 'top', options = list(
        pageLength = 18, autoWidth = TRUE, scrollX = TRUE
        )
    )
    
  })
}