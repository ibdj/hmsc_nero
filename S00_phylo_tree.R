#### packages ####

if (!requireNamespace("pacman", quietly = TRUE) || !requireNamespace("devtools", quietly = TRUE)) {
  install.packages(c("pacman", "devtools"))
}
devtools::install_github("inbo/inborutils")
install_github("jinyizju/V.PhyloMaker", dependencies = TRUE)
pacman::p_load(remotes, ape,tidyverse,googlesheets4, rgbif, ids, lubridate, devtools,V.PhyloMaker) 

####### reading data #############################################################################################

sp.names <- read_csv("data/index_species.csv") |> 
  mutate(trait = func_type)

sp.list <- read_csv("data/data_2007.csv") |> left_join(sp.names, by = "taxon_code") |> 
  mutate(name = species)

#### match species by gbif ########################################################################################

sp.list <- sp.list |> name_backbone_checklist("name")

#Your species list should include columns for `species`, `genus`, and `family`. 
sp.list <-sp.list[!duplicated(sp.list$scientificName), ]

sp.list <- sp.list[, c("species", "genus", "family")]  



#### phylo maker ####
result <- phylo.maker(sp.list, scenarios = "S3")
plot(result$scenario.3)

result
