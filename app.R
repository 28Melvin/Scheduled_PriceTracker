# r-shiny project
library(shiny) 
library(RMySQL)
library(ggplot2)

source("./global.R")


# Define UI / Layout 
# fluidpage -> function
ui <- fluidPage(
  
  titlePanel("Prices"),
  

  
  sidebarLayout(
    
    sidebarPanel("Choose the product you wish to get the price for: ", 
                 
                 br(),
                 br(),
                 selectInput("productID","Choose product: ", c("Apple IPhone 12 Pro 256 GB", "AirPods mit Ladecase")),
                 br(),
                 br(),
                 actionButton("plotData", "Plot Data"),
                 br(), 
                 h1(textOutput("currentPrice"), align = "center")), 
                 
               
    
    mainPanel("Prices over Time", tabsetPanel(type = "tabs", 
                          tabPanel("IPhone 12 Pro - 256 GB", plotOutput("plotIPhone")),
                          tabPanel("AirPods mit Ladecase", plotOutput("plotAirPods"))),
              
              position = "left" #sidebar position
              
         
        
  ))
  
)


# Define server logic required 
server <- function(input, output) {
  
  
  # if the user pushes the "Get newest Price" Button - newest price is extracted 
  # and written to remote database + shown below the button 
  observeEvent(input$plotData, {
    
    
    tableInput <- loadData()
    
    if(input$productID == "Apple IPhone 12 Pro 256 GB"){
      
      output$plotIPhone <- renderPlot(plotIPhone(tableInput))
      
    }
    else
    {
    
     output$plotAirPods <- renderPlot(plotAirPods(tableInput))
    }
    
   # output$datas <- renderTable(tableInput)
    
    
  })
  
  
}


# run the app 
shinyApp(ui = ui, server = server)

