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
library(lsa) 




# Local testing - - -
# deployApp(account = "kucharski")
# library(shiny); library(rsconnect); setwd("~/Documents/GitHub/epiverse-llm/")

wait_screen <- tagList(
  spin_orbiter(),
  h4("Finding package...")
)

# Plotting and helper functions ------------------------------------------------------------------

# Load credentials
credential_load <- read.csv("data/credentials.csv")

# Load package list and descriptions
package_list <- read.csv("data/package_list.csv")
package_descriptions <- read.csv("data/package_descriptions.csv")

# Load prompt intro
intro_prompt <- read_file("data/intro_prompt.txt")

# Load pre-prepped embeddings
package_embeddings <- read_rds("data/embeddings/package_description_embeddings.rds")

# Load vignettes - not currently used
#source("R/load_vignettes.R")

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
  
    # Header
    div(
      class = "well",
      div(class = "text-center",
          h4("Identify relevant packages using LLMs"),
          br(),
          p(strong("Note: this dashboard is under development, so generated outputs are likely to have errors"))
      )
    ),

    # Text input
    div(
      class = "well",
      div(class = "text-center",
        textAreaInput( 
        inputId     = "question_text",
        label       = "What task would you like to do?",
        placeholder = "Enter text",
        height = "150px"
      ),
      actionButton("question_button","Recommend package",class="btn-primary")
      )
    )
  ),

    # Output response
    hidden(
      div(id = "output-response1",
        class = "well",
        div(
          strong(textOutput("api_response_name")),
          textOutput("api_response_description"),
          tags$a(href=textOutput("api_response_link"), "Go to package",target="_blank")
        )
      ),

    div(class = "text-center",
        p(em("Output generated using the OpenAI API."))
    )
    )

  
  
) # END UI

# App server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # Store vignette text
  vignette_text <- reactiveVal("")
  

  # Output LLM completion
  observeEvent(input$question_button,{

    waiter_show(html = wait_screen,color="#b7c9e2")
    
    # Test with query
    query_text <-  input$question_text
    
    query_embedding <- create_embedding(
      model = "text-embedding-ada-002",
      input = query_text,
      openai_api_key = credential_load$value,
    )
    
    # Define embedding vector for query
    query_vec <- query_embedding$data$embedding[[1]]
    
    # Find most similar package description
    cosine_sim <- apply(package_embeddings,1,function(x){lsa::cosine(x,query_vec)})
    best_match <- package_descriptions[which.max(cosine_sim),]

    # Render responses
    output$api_response_name <- renderText({ best_match$value })
    
    output$api_response_description <- renderText({ best_match$description })
    
    output$api_response_link <- renderText({ best_match$link })
    
    shinyjs::show("output-response1")
    
    waiter_hide()
    
  })

  
} # END SERVER



# Compile app -------------------------------------------------------------

shinyApp(ui = ui, server = server)


