# Set the base directory

setwd("/Users/ibdj/Library/CloudStorage/OneDrive-Aarhusuniversitet/MappingPlants/01 Vegetation changes Kobbefjord/modelling/hmsc_nero")
##################################################################################################
# INPUT AND OUTPUT OF THIS SCRIPT (BEGINNING)
##################################################################################################
#	INPUT. Original datafiles of the case study, placed in the data folder.

#	OUTPUT. Unfitted models, i.e., the list of Hmsc model(s) that have been defined but not fitted yet,
# stored in the file "models/unfitted_models.RData".
##################################################################################################
# INPUT AND OUTPUT OF THIS SCRIPT (END)
##################################################################################################


##################################################################################################
# MAKE THE SCRIPT REPRODUCIBLE (BEGINNING)
##################################################################################################
set.seed(1)
##################################################################################################
## MAKE THE SCRIPT REPRODUCIBLE (END)
##################################################################################################


##################################################################################################
# LOAD PACKAGES (BEGINNING)
##################################################################################################
devtools::install_github("hmsc-r/HMSC")
##################################################################################################
# LOAD PACKAGES (END)
##################################################################################################


##################################################################################################
# SET DIRECTORIES (BEGINNING)
##################################################################################################
localDir = "."
dataDir = file.path(localDir, "data")
if(!dir.exists(dataDir)) dir.create(dataDir)
modelDir = file.path(localDir, "models")
if(!dir.exists(modelDir)) dir.create(modelDir)
##################################################################################################
# SET DIRECTORIES (END)
##################################################################################################


##################################################################################################
# READ AND SELECT SPECIES DATA (BEGINNING)
##################################################################################################
#data = read.csv(file.path(dataDir, "data_2007.csv"))
#dim(data)
#View(data)
#Y = as.matrix(data[,3:658])
View(Y)
hist(Y)
##################################################################################################
# READ AND SELECT SPECIES DATA (END)
##################################################################################################


##################################################################################################
# READ AND MODIFY ENVIRONMENTAL DATA (BEGINNING)
##################################################################################################
#XData = read.csv(file.path(dataDir, "environment.csv"), as.is = FALSE)
head(XData)
str(XData)
#XData$id = as.factor(XData$id)
plot(XData)
hist(XData$ele)
hist(XData$ndvi)
hist(XData$solarradiation)
hist(XData$twi)
#XData$volume = log(XData$volume)
#hist(XData$volume)
#hist(XData$decay)
#XData$decay[XData$decay==4]=3
#hist(XData$decay)
##################################################################################################
# READ AND MODIFY ENVIRONMENTAL DATA (BEGINNING)
##################################################################################################


##################################################################################################
# SELECT COMMON SPECIES (BEGINNING)
##################################################################################################
head(Y)
prev = colSums(Y)
hist(prev)
sum(prev>=15)
sum(prev>=20)
sel.sp = (prev>=15)
Y = Y[,sel.sp] #presence-absence data for selected species
hist(colSums(Y))
##################################################################################################
# SELECT COMMON SPECIES (END)
##################################################################################################


##################################################################################################
# SET UP THE MODEL (BEGINNING)
##################################################################################################
# REGRESSION MODEL FOR ENVIRONMENTAL COVARIATES.
XFormula = ~ ele + poly(twi, degree = 2, raw = TRUE) + poly(ndvi, degree = 2, raw = TRUE) + poly(solarradiation, degree = 2, raw = TRUE)

studyDesign = data.frame(plot = as.factor(rownames(XData)))
# REGRESSION MODEL FOR TRAITS

# setting the random levels. This way up setting up the random levelse is from the bird case study. 
rL = HmscRandomLevel(sData=xy)

# PRESENCE-ABSENCE MODEL FOR INDIVIDUAL SPECIES (COMMON ONLY)
m = Hmsc(Y=Y, 
         XData = XData,  
         XFormula = XFormula, 
         studyDesign = studyDesign,
         ranLevels = rL,
         #phyloTree = plant.tree,
         distr="probit")
##################################################################################################
# SET UP THE MODEL (END)
##################################################################################################


##################################################################################################
# COMBINING AND SAVING MODELS (START)
##################################################################################################
models = list(m)
names(models) = c("presence-absence model")
save(models, file = file.path(modelDir, "unfitted_models.RData"))

head(m$X)
##################################################################################################
# COMBINING AND SAVING MODELS (END)
##################################################################################################


##################################################################################################
# TESTING THAT MODELS FIT WITHOUT ERRORS (START)
##################################################################################################
for(i in 1:length(models)){
  print(i)
  sampleMcmc(models[[i]],samples=2)
}
##################################################################################################
# TESTING THAT MODELS FIT WITHOUT ERRORS (END)
##################################################################################################
