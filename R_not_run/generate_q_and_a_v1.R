# - - - - - - - - - - - - - - - - - - - - - - - 
# Run loop to generate embeddings for packages
# - - - - - - - - - - - - - - - - - - - - - - -

# Load credentials and libraries
library(openai)
library(stringr)
library(readr)

setwd("~/Documents/GitHub/epiverse-llm/")

credential_load <- read.csv("data/credentials.csv")

# Load helper functions
source("R_not_run/helper_functions.R")

# Load prompt for question generation
intro_prompt <- read_file("data/intro_prompt_gen_questions.txt")
intro_prompt_2 <- read_file("data/intro_prompt_gen_questions_2.txt")

# Load question text - source: https://github.com/avallecam/questions/blob/main/01-questions.qmd
questions_01_md <- read_file("https://raw.githubusercontent.com/avallecam/questions/main/01-questions.qmd") #read_file("data/vignettes/01-questions-A.qmd") # edited slightly for length

# Split string into list of strings of length 2000 characters
questions_01_md_out <- split_string(questions_01_md,2000)


# Number of questions and answers to generate:
n_questions <- 10

llm_completion_med <- create_chat_completion(
  model = "gpt-3.5-turbo", # "text-davinci-003",
  messages = list(list("role"="system","content" = paste0(intro_prompt,n_questions,intro_prompt_2)),
                  list("role"="user","content" = questions_01_md)
  ),
  temperature = 0,
  openai_api_key = credential_load$value
  #max_tokens = 1000
)

# Render response
generated_q <- str_split(llm_completion_med$choices$message.content,"\n")[[1]]


write_rds(store_embeddings,paste0("data/embeddings/package_description_embeddings.rds"))

# Define Open AI embedding vector size
embed_size <- 1536
store_embeddings <- matrix(NA,nrow=total_packages,embed_size)




