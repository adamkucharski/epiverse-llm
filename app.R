# - - - - - - - - - - - - - - - - - - - - - - - 
# Concept for LLM interface to Epiverse tools
# Author: Adam Kucharski
# - - - - - - - - - - - - - - - - - - - - - - -

# Load paths ------------------------------------------------------------------

library(shinyjs) 
library(dplyr)
library(stringr)
library(shinyWidgets)
library(openai)
library(readr)
library(waiter)
library(shinythemes)

# deployApp(account = "kucharski")
# library(shiny); library(rsconnect); setwd("~/Documents/GitHub/epiverse-llm/")

wait_screen <- tagList(
  spin_orbiter(),
  h4("Generating code...")
)

# Plotting and helper functions ------------------------------------------------------------------

# Load credentials
credential_load <- read.csv("data/credentials.csv")

# Load package list
package_list <- read.csv("data/package_list.csv")

# App UI ------------------------------------------------------------------

ui <- fluidPage(
  title = "Package explorer",
  collapsible = TRUE,
  windowTitle = "Package explorer",
  theme = shinytheme("flatly"),
  
  # Load libraries
  useShinyjs(),
  useWaiter(), # ADDED
  

  # Define CSS tags if required.
  
  # AI interface ----------------------------------------------------------

  div(
    id = "package-explorer", 
    style = "width: 600px; max-width: 100%; margin: 0 auto;",
    
    # Package select
    div(
      class = "well",
      div(class = "text-center",
          selectInput("package_choose",label = "Select a package:",
                      choices=c("",sort(package_list$value)),selected="",multiple=F)
      )
    ),
    
    # Text input
    div(
      class = "well",
      div(class = "text-center",
        textAreaInput( 
        inputId     = "question_text",
        label       = "What would you like to do?",
        placeholder = "Enter text",
        height = "250px"
      ),
      actionButton("question_button","Generate code",class="btn-primary")
      )
    ),

    # Output response
    div(
      class = "well",
      div(
        verbatimTextOutput("api_response"),
      )
    )
  )
  
  
) # END UI

# App server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # Select package
  
  
  # Output LLM completion
  
  observeEvent(input$question_button,{
    
    waiter_show(html = wait_screen,color="#b7c9e2")
    
    llm_completion <- openai::create_completion(
      model = "text-davinci-003",
      prompt = paste0(input$question_text),
      temperature = 0.1,
      openai_api_key = credential_load$value,
      max_tokens = 150
    )
    
    output$api_response <- renderText({
      llm_completion$choices$text
    })
    
    waiter_hide()
    
  })

  
} # END SERVER



# Compile app -------------------------------------------------------------

shinyApp(ui = ui, server = server)


