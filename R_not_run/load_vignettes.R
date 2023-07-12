# - - - - - - - - - - - - - - - - - - - - - - - 
# Load vignettes
# Watch length of tokens that can be included in prompt
# Have swapped some for manually edited prompt vignettes
# - - - - - - - - - - - - - - - - - - - - - - -

# Load epiparameter vignettes
epiparameter_1 <- read_file("https://raw.githubusercontent.com/epiverse-trace/epiparameter/main/vignettes/epiparameter.Rmd")
epiparameter_2 <- read_file("https://raw.githubusercontent.com/epiverse-trace/epiparameter/main/vignettes/extract_convert.Rmd")
epiparameter_out <- paste0(epiparameter_1,epiparameter_2)

#epiparameter_out <- readr::read_file("data/vignettes/epiparameter_prompt.md")

# Load superspreading vignettes
superspreading_1 <- read_file("https://raw.githubusercontent.com/epiverse-trace/superspreading/main/vignettes/superspreading.Rmd")
superspreading_2 <- read_file("https://raw.githubusercontent.com/epiverse-trace/superspreading/main/vignettes/estimate_individual_level_transmission.Rmd")
superspreading_out <- paste0(superspreading_1,superspreading_2)

#superspreading_out <- readr::read_file("data/vignettes/superspreading_prompt.md")

# Load serofoi vignettes
serofoi_1 <- readr::read_file("https://raw.githubusercontent.com/epiverse-trace/serofoi/main/vignettes/serofoi.Rmd")
serofoi_2 <- read_file("https://raw.githubusercontent.com/epiverse-trace/serofoi/main/vignettes/use_cases.Rmd") 
serofoi_3 <- read_file("https://raw.githubusercontent.com/epiverse-trace/serofoi/main/vignettes/foi_models.Rmd") 
serofoi_out <- paste0(serofoi_1,serofoi_2,serofoi_3)

# Load finalsize vignettes
finalsize_1 <- read_file("https://raw.githubusercontent.com/epiverse-trace/finalsize/main/vignettes/finalsize.Rmd")
finalsize_2 <- read_file("https://raw.githubusercontent.com/epiverse-trace/finalsize/main/vignettes/varying_susceptibility.Rmd")
finalsize_3 <- read_file("https://raw.githubusercontent.com/epiverse-trace/finalsize/main/vignettes/varying_contacts.Rmd")
finalsize_4 <- read_file("https://raw.githubusercontent.com/epiverse-trace/finalsize/main/vignettes/compare_sir_model.Rmd")
finalsize_5 <- read_file("https://raw.githubusercontent.com/epiverse-trace/finalsize/main/vignettes/uncertainty_params.Rmd")
finalsize_out <- paste0(finalsize_1,finalsize_2,finalsize_3,finalsize_4,finalsize_5)

#finalsize_out <- readr::read_file("data/vignettes/finalsize_prompt.md")


# Load linelist vignettes
linelist_1 <- readr::read_file("https://raw.githubusercontent.com/epiverse-trace/linelist/main/vignettes/linelist.Rmd")
linelist_out <- linelist_1


