ui <- dashboardPage(

  dashboardHeader(
    title = "Geo data"
  ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("inleiding"),
      textInput("pc6", "postcode", value = "1183AA"),
      numericInput("tijd", "maximale reistijd (min)", value = 15, min = 1, max = 60),
      selectInput("profile", "vervoertype", choices = c("driving-car", "cycling-regular") )
    )
  ),
  
  dashboardBody(
    leafletOutput("kaartje")
    
  )
  
    
)


