install.packages("pacman","tidyverse","Hmsc", dependencies = TRUE)
pacman::p_load(tidyverse, Hmsc, google,sf)

library(tidyverse)
# scripts for preprossing the data with a test run on NERO data

#### Setting the working directory ####
setwd("/Users/ibdj/Library/CloudStorage/OneDrive-Aarhusuniversitet/MappingPlants/01 Vegetation changes Kobbefjord/modelling/hmsc_nero")
localDir = "."
data.directory = file.path(localDir, "data")

#### Reading the data and viewing the first line ####
# reading the environmental data straight from a geopackage
env_data <- read_csv("data/env_data.csv")

env_import <- st_read("/Users/ibdj/Library/CloudStorage/OneDrive-Aarhusuniversitet/MappingPlants/gis/nero_final_enviromental_variables.gpkg", layer = "nero_final_enviromental_variables") 
# filter is not really ness

data = read.csv(file=file.path(data.directory,"data_2007.csv"),
                stringsAsFactors=TRUE) |>
                merge(env_import, by = "plot_id", all.x = TRUE) |> #merging the environmental data to process it in the same way as they did in the script 
                mutate(
                  site = plot_id,
                  species = taxon_code,
                  value = raunkiaer_value,
                  env = elevation_arctic_dem
                )



data$site = factor(data$site)
head(data)

#### Reformating the data so that it works as input for hmsc #####

# the matrix `Y` of species abundances = same for NERO

# the dataframe `XData` of the environmental variable TMG = for NERO that would be elevation, slope, aspect, solar radiation, for now (Maybe TWI too, have asked Andreas about it today 2024-11-13) 

# and the dataframe `TrData` of the trait C:N ratio = for NERO that would be functional groups

#### Original script to make dataframes ####
sites = levels(data$site)
species = levels(data$species)
n = length(sites)
ns = length(species)

Y = matrix(0, nrow = n, ncol = ns)

env = rep(NA,n)

trait = rep(NA,ns)

for (i in 1:n) {
  for (j in 1:ns) {
    row <- data$site == sites[i] & data$species == species[j]
    if (any(row)) {
      Y[i, j] <- if (length(data[row, ]$value) > 0) data[row, ]$value[1] else 0
      
      # Only update env[i] if it's still NA
      if (is.na(env[i])) {
        env[i] <- if (length(data[row, ]$env) > 0) data[row, ]$env[1] else NA
      }
      
      # Only update trait[j] if it's still NA
      if (is.na(trait[j])) {
        trait[j] <- if (length(data[row, ]$trait) > 0) data[row, ]$trait[1] else NA
      }
    }
  }
}

colnames(Y) = species
rownames(Y) = sites
XData = data.frame(ELE = env)
rownames(XData) = sites
TrData = data.frame(FUNC = trait)
rownames(TrData) = species
rownames(TrData) = colnames(Y)

head(Y)

Y <- Y_pa <- (Y > 0) * 1
head(Y_pa)

save(Y, XData, TrData, file=file.path(data.directory,"allData.RData"))
