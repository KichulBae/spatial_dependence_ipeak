#### This is a set of functions and others to run "get_pk_streamflow_data.R"


# Function getting instantaneous peak values from NWIS with "dataRetrieval" ------------

getpk <- function(stationID, start_date="", end_date="") {
  tryCatch(
    expr = {
      pk <- dataRetrieval::readNWISpeak(stationID, start_date, end_date)
      pk <- pk$peak_va
      if (is.null(pk) || length(pk) == 0) pk <- NA
      return(pk)
      },

    error = function(e){
      message('Caught an error!')
      print(e)
      return(NA)
      },
    
    warning = function(w){
      message('Caught an warning!')
      print(w)
      return(NA)
    }
  )    
}


# Function getting data from all HCDN stations ----------------------------

getpk_hcdn <- function(huc2, endyear){
  
  setwd("~/spatial_dependence_ipeak/HCDN_LIST/")
  hcdn <- readRDS("list_all.RData")
  
  stlist <- hcdn[[huc2]]
  
  rst <- data.frame(wateryear = c(1856:endyear)) 
  # Earliest available year = 1856, station ID = "20472000", not fully confirmed though
  
  rst$wateryear <- as.character(rst$wateryear)

  for (i in stlist){ 
    pks <- c()
    for (j in 1855:(endyear-1)){
      cy <- as.character(j)
      wys <- paste0(cy, "-10-01")
      wy <- as.character(j+1)
      wye <- paste0(wy, "-09-30")
      pks[length(pks)+1] <- getpk(i, wys, wye)
    }
    rst[,length(rst)+1] <- pks
  }
  colnames(rst)[-1] <- stlist
  return(rst)
}


# Miscellaneous functions  ------------------------------------------------

help01 <- function(x) {
  temp <- as.character(x)
  if (nchar(x) == 1) temp <- paste0("0", temp)
  return(temp)
}

help02 <- function(x1, x2){
  temp <- paste0(x1, x2)
  temp <- parse(text = temp)
  temp <- eval(temp)
  return(temp)
}


