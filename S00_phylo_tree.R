#### packages ####

if (!requireNamespace("pacman", quietly = TRUE) || !requireNamespace("devtools", quietly = TRUE)) {
  install.packages(c("pacman", "devtools","ape"))
}
devtools::install_github("inbo/inborutils")
devtools::install_github("jinyizju/V.PhyloMaker")
pacman::p_load(remotes,ape,tidyverse,googlesheets4,rgbif,ids,lubridate,devtools,V.PhyloMaker) 

####### reading data #############################################################################################

#importing the ALL names used in the NERO data
sp.names <- read_csv("data/index_species.csv") |> 
  mutate(trait = func_type)

#making a list of the species in the specific dataset and joining to get the full mames
sp.list <- read_csv("data/data_2007.csv") |> left_join(sp.names, by = "taxon_code") |> 
  mutate(name = species)

#### match species by gbif ########################################################################################

#matching the data to GBIF to get species, family and genus (Your species list should include columns for `species`, `genus`, and `family`)
sp.list <- sp.list |> name_backbone_checklist("name")
full_list <- sp.list |> name_backbone_checklist("name")

# removingany duplicates
sp.list <-sp.list[!duplicated(sp.list$scientificName), ]

# making sure that the list only contains the three needed variables
sp.list <- sp.list[, c("species", "genus", "family")]

# format from the plant case study: 
#species,family,genus,epithet
#Abies concolor,Pinaceae,Abies,concolor

#### phylo maker #################################################################################################
result <- phylo.maker(sp.list, scenarios = "S3")
plot(result$scenario.3, ces = 0.5)

tree <- result$scenario.3

write.tree(tree, file = "data/nero_phylo_tree.tree")





#### with ape only (like the plant case study) #######################
sp.list <- sapply(sp.list, is.character)
sp.list <- lapply(sp.list, as.factor)

plant.tree = as.phylo(~family/genus/species, data=sp.list, collapse = FALSE)
plant.tree$edge.length = rep(1,length(plant.tree$edge))
