ui <- dashboardPage(

  dashboardHeader(
    title = "Wat zit er in mijn verzorgingsgebied?"
  ),
  
  dashboardSidebar(
    width = 500,
    sidebarMenu(
      menuItem("inleiding"),
      textInput("pc6", "postcode", value = "1183AA"),
      numericInput("tijd", "maximale reistijd (min)", value = 15, min = 1, max = 60),
      selectInput("profile", "vervoertype", choices = c("driving-car", "cycling-regular") ),
      actionButton("goButton", "Go!")
    )
  ),
  
  dashboardBody(
    column(6,
      leafletOutput("kaartje", height = "700px", width = "700px")
    ),
    column(6,
       valueBoxOutput("rate"),
       valueBoxOutput("count"),
       valueBoxOutput("users")
    )
  )
  
    
)


