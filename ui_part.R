ui <- dashboardPage(

  dashboardHeader(
    title = "verzorgingsgebied"
  ),
  
  dashboardSidebar(
    width = 300,
    sidebarMenu(
      menuItem("inleiding", tabName = "inleiding", icon = icon("apple")),
      menuItem("postcode", tabName = "postcode", icon = icon("link")),
      
      textInput("pc6", "postcode", value = "1183AA"),
      numericInput("tijd", "maximale reistijd (min)", value = 15, min = 1, max = 60),
      selectInput("profile", "vervoertype", choices = c("driving-car", "cycling-regular") ),
      checkboxInput("plotpc4shapes", "plot PC4 shapes"),
      actionButton("goButton", "Go!")
    )
  ),
  
  dashboardBody(
    tabItems(
      tabItem(
        tabName = "postcode",
        mainPanel(
          fluidRow(
            column(8,
              fluidRow(
                column(4, valueBoxOutput("mensen", width = 12)),
                column(4,  valueBoxOutput("kinderen", width = 12)),
                column(4,  valueBoxOutput("uitkering", width = 12))
              ),
              fluidRow(
                withLoader(leafletOutput("kaartje", height = "800px"))
              )
            ),
            column(4,
              dataTableOutput("pc4tabel", width = "900px")
            )
          )
        )
      ),
      
      tabItem(
        tabName = "inleiding",
        mainPanel(
          htmlOutput("intro")
        )
        
      )
    )
  )
  
)


