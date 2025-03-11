#### packages ####

library(remotes)

install_github("jinyizju/V.PhyloMaker")
library(V.PhyloMaker)
library(rgbif)

sp.names <- read_csv("data/index_species.csv") |> 
  mutate(trait = func_type)

sp.list <- read_csv("data/data_2007.csv") |> left_join(sp.names, by = "taxon_code") |> 
  mutate(name = species)

#### match species by gbif ####

sp.list <- sp.list |> name_backbone_checklist("name")

#Your species list should include columns for `species`, `genus`, and `family`. 
sp.list <-sp.list[!duplicated(sp.list$scientificName), ]

sp.list <- sp.list[, c("species", "genus", "family")]  



#### phylo maker ####
result <- phylo.maker(sp.list, scenarios = "S3")
plot(result$scenario.3)
