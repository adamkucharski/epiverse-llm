# - - - - - - - - - - - - - - - - - - - - - - - 
# Run loop to generate embeddings for packages
# - - - - - - - - - - - - - - - - - - - - - - -

package_descriptions <- read.csv("data/package_descriptions.csv")

total_packages <- nrow(package_descriptions)
embed_size <- 1536

store_embeddings <- matrix(NA,nrow=total_packages,embed_size)

for(ii in 1:total_packages){
  
  input_text <- package_descriptions$description[ii]
  
  output_embedding <- create_embedding(
    model = "text-embedding-ada-002",
    input = input_text,
    openai_api_key = credential_load$value,
  )
  
  output_vec <- output_embedding$data$embedding[[1]]
  
  store_embeddings[ii,] <- output_vec

}

write_rds(store_embeddings,paste0("data/embeddings/package_description_embeddings.rds"))



