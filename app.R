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

# Local testing - - -
# deployApp(account = "kucharski")
# library(shiny); library(rsconnect); setwd("~/Documents/GitHub/epiverse-llm/")

wait_screen <- tagList(
  spin_orbiter(),
  h4("Generating code...")
)

# Plotting and helper functions ------------------------------------------------------------------

# Load credentials
credential_load <- read.csv("data/credentials.csv")

# Load package list and descriptions
package_list <- read.csv("data/package_list.csv")
package_descriptions <- read.csv("data/package_descriptions.csv")

# Load prompt intro
intro_prompt <- read_file("data/intro_prompt.txt")

# Load vignettes
source("R/load_vignettes.R")

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
          h4("Explore Epiverse packages with LLMs"),
          br(),
          p(strong("Note: this dashboard is under development, so generated code is likely to have errors"))
      )
    ),
    
    # Package select
    div(
      class = "well",
      div(class = "text-center",
          selectInput("package_choose",label = "Select a package:",
                      choices=c("",sort(package_list$value)),selected="",multiple=F),
          textOutput("package_info"),
          br(),
          p(tags$a(href="https://github.com/epiverse-trace/","View code on GitHub",target="_blank"))
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
        height = "150px"
      ),
      disabled(actionButton("question_button","Generate code",class="btn-primary"))
      )
    ),

    # Output response
    div(
      class = "well",
      div(
        verbatimTextOutput("api_response"),
      )
    ),
    div(class = "text-center",
        p(em("Code generated using the OpenAI API."))
    )
  )
  
  
) # END UI

# App server ------------------------------------------------------------------

server <- function(input, output, session) {
  
  # Store vignette text
  vignette_text <- reactiveVal("")
  
  # Render package info text and link
  observe({
    
    package_name <- input$package_choose
    
    # Default info
    info_out <- "Epiverse is a global collaborative working to develop a trustworthy data analysis ecosystem dedicated to getting ahead of the next public health crisis."
    #link_out <- "https://github.com/epiverse-trace/" # Not currently used
    
    if(package_name!=""){
      info_out <- package_descriptions |> dplyr::filter(value==package_name) |> dplyr::select(description)
      info_out <- info_out$description
      #link_out <- paste0("https://github.com/epiverse-trace/",package_name) # Not currently used
      shinyjs::enable("question_button") # Enable question button
    }
    
    # Define vignette text
    if(package_name=="epiparameter"){vignette_text(epiparameter_out)}
    if(package_name=="superspreading"){vignette_text(superspreading_out)}
    if(package_name=="serofoi"){vignette_text(serofoi_out)}
    if(package_name=="finalsize"){vignette_text(finalsize_out)}
    if(package_name=="linelist"){vignette_text(linelist_out)}
    
    output$package_info <- renderText(info_out)
    #output$package_link <- renderText(link_out) # Not currently used
  })
    
  

  # Output LLM completion
  
  observeEvent(input$question_button,{

    waiter_show(html = wait_screen,color="#b7c9e2")
    
    prompt_text <- paste0(intro_prompt,vignette_text())
    
    # Run completion on user text - - -
    # Instruct model
    # llm_completion <- openai::create_completion(
    #  model = "text-davinci-003",
    #  prompt = paste0(prompt_text,input$question_text),
    #  temperature = 0.1,
    #  openai_api_key = credential_load$value,
    #  max_tokens = 500
    # )
    # 
    # # Render resposne
    # output$api_response <- renderText({
    #  llm_completion$choices$text
    # })
    # 
    # Chat model
    llm_completion <- create_chat_completion(
      model = "gpt-3.5-turbo-16k", # "text-davinci-003",
      messages = list(list("role"="system","content" = prompt_text),
                      list("role"="user","content" = input$question_text)
                      ),
      temperature = 0.1,
      openai_api_key = credential_load$value,
      max_tokens = 5000
    )

    # Render resposne
    output$api_response <- renderText({
      llm_completion$choices$message.content
    })
    
    waiter_hide()
    
  })

  
} # END SERVER



# Compile app -------------------------------------------------------------

shinyApp(ui = ui, server = server)


