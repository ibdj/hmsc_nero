install.packages("pacman","tidyverse",dependencies = TRUE)
devtools::install_github("hmsc-r/HMSC")
pacman::p_load(tidyverse, Hmsc, googlesheets4,sf)

# scripts for preprossing the data with a test run on NERO data

#### Setting the working directory ####
setwd("/Users/ibdj/Library/CloudStorage/OneDrive-Aarhusuniversitet/MappingPlants/01 Vegetation changes Kobbefjord/modelling/hmsc_nero")
localDir = "."
data.directory = file.path(localDir, "data")

#### Reading the data and viewing the first line ####

# reading the environmental data straight from a geopackage
#env_data <- read_csv("data/env_data.csv")

env_import <- st_read("/Users/ibdj/Library/CloudStorage/OneDrive-Aarhusuniversitet/MappingPlants/gis/nero_final_enviromental_variables.gpkg", layer = "nero_final_enviromental_variables") 


data = read.csv(file=file.path(data.directory,"data_2007.csv"),
                stringsAsFactors=TRUE) |>
                merge(env_import, by = "plot_id", all.x = TRUE) |> #merging the environmental data to process it in the same way as they did in the script 
                mutate(
                  site = plot_id,
                  species = taxon_code,
                  value = raunkiaer_value,
                  env = elevation_arctic_dem
                ) |> 
  left_join(sp.names, by = "taxon_code")



data$site = factor(data$site)
data$trait = factor(data$trait)
head(data)

#### Reformating the data so that it works as input for hmsc #####

# the matrix `Y` of species abundances = same for NERO

# the dataframe `XData` of the environmental variable TMG = for NERO that would be elevation, slope, aspect, solar radiation, for now (Maybe TWI too, have asked Andreas about it today 2024-11-13) 

# and the dataframe `TrData` of the trait C:N ratio = for NERO that would be functional groups

#### Original script to make dataframes ####
sites = levels(data$site) # for nero: site is the plot_id
species = levels(data$species.x)
n = length(sites)
ns = length(species)

Y = matrix(0, nrow = n, ncol = ns)

env = rep(NA, n)
twi = rep(NA, n)
ndvi = rep(NA, n)
solarradiation = rep(NA, n)
trait = rep(NA, ns)  # Initialize trait as NA (will store strings)

for (i in 1:n) {
  for (j in 1:ns) {
    row <- data$site == sites[i] & data$species.x == species[j]
    if (any(row)) {
      Y[i, j] <- if (length(data[row, ]$value) > 0) data[row, ]$value[1] else 0
      
      # Only update env[i] if it's still NA
      if (is.na(env[i])) {
        env[i] <- if (length(data[row, ]$env) > 0) data[row, ]$env[1] else NA
      }
      
      # Only update twi[i] if it's still NA
      if (is.na(twi[i])) {
        twi[i] <- if (length(data[row, ]$twi_arcticdem) > 0) data[row, ]$twi_arcticdem[1] else NA
      }
      
      # Only update twi[i] if it's still NA
      if (is.na(ndvi[i])) {
        ndvi[i] <- if (length(data[row, ]$ndvi) > 0) data[row, ]$ndvi[1] else NA
      }
      
      # Only update twi[i] if it's still NA
      if (is.na(solarradiation[i])) {
        solarradiation[i] <- if (length(data[row, ]$solarradiation) > 0) data[row, ]$solarradiation[1] else NA
      }
      
      # Only update trait[j] if it's still NA
      if (is.na(trait[j])) {
        trait_value <- data[row, ]$trait[1]
        trait[j] <- if (!is.na(trait_value)) as.character(trait_value) else NA
      }
    }
  }
}

colnames(Y) = species
rownames(Y) = sites

# Create XData with numeric columns
XData = data.frame(ele = env, twi = twi, ndvi = ndvi, solarradiation = solarradiation)
rownames(XData) = sites

# Create TrData with string-based traits and ensure stringsAsFactors is FALSE
TrData = data.frame(trait = trait, stringsAsFactors = FALSE)
rownames(TrData) = species
rownames(TrData) = colnames(Y)

head(TrData)

head(Y)

Y <- Y_pa <- (Y > 0) * 1
head(Y_pa)

#### organising the sData #####
# by example of the birds case study of 

data_plots <- unique(data[, c("plot_id", "lon_vir", "lat_vir")])
xy =  as.matrix(cbind(data_plots$lon_vir,data_plots$lat_vir))
rownames(xy)=data_plots$plot_id
colnames(xy)=c("x-coordinate","y-coordinate")
head(xy)

sData <- xy

#### ########################################################################################################
save(Y, XData, TrData, sData, file=file.path(data.directory,"allData.RData"))
