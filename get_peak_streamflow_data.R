#### Retrieve instantaneous peak values from NWIS for HCDN stations


# Load libraries ----------------------------------------------------------
library(dataRetrieval)
library(tidyverse)
library(parallel)
library(doParallel)

# Source files ------------------------------------------------------------
setwd("~/spatial_dependence_ipeak")

source("get_peak_streamflow_data.help.R")

setwd("~/spatial_dependence_ipeak")



# Retrieve data -----------------------------------------------------------

cl <- makeCluster(18) 
registerDoParallel(cl)

results <- c(parLapply(cl, c(1:18), 1852, fun=getpk_hcdn))
