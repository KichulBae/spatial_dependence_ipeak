#### Using source files from USGS, create HCDN stations list with basic info
# Load libraries ----------------------------------------------------------
library(openxlsx)
library(data.table)
library(dataRetrieval)


# Load state code file (source: USGS) and preprocess it  ------------------

load_stcode <- function(
    source = c("local", "online"), 
    filepath = "~/spatial_dependence_ipeak/USGS_SOURCE/"
    ) {
  
  if (source == "online") {
    url = "https://www2.census.gov/geo/docs/reference/state.txt"
    st_code <- read.table(url(url), sep = "|", header = T)
  } else {
    setwd(filepath)
    st_code <- read.csv("state_cd_usgs.csv")
  }

  st_code$STATE <- as.character(st_code$STATE)
  cd <- st_code$STATE

  n <- length(cd)

  for (i in 1:n) {
    st <- cd[i]
    char_n <- nchar(st)
    while (char_n < 2){
      st <- paste0("0", st)
      char_n <- nchar(st)
    }
    cd[i] <- st
  }
  
  st_code$STATE <- cd
  
  return(st_code)
}


# Load HCDN2009 station list (source: USGS) and preprocess it. ------------

load_hcdn <- function(
    source = c("local", "online"),
    filepath = "~/spatial_dependence_ipeak/USGS_SOURCE/"
    ) {
  
  if (source == "online") {
    URL <- "https://water.usgs.gov/osw/hcdn-2009/HCDN-2009_Station_Info.xlsx"
    tables <- openxlsx::read.xlsx(URL)
    hcdn <- tables$STATION.ID
  } else {
    setwd(filepath)
    hcdn <- read.csv("hcdn2009_list.txt")
    hcdn <- hcdn$station.ID
  }
  
  n <- length(hcdn)

  for (i in 1:n) {
    st <- hcdn[i]
    st <- as.character(st)
    n <- nchar(st)
    while (n < 8) {
      st <- paste0("0", st)
      n <- nchar(st)
    }
    hcdn[i] <- st
  }
  return(hcdn)
}


# Define function to make a list of HCDN stations with basic info ---------
# Written by   : Kichul Bae
# Written on   : Jul 31, 2023
# Description  : From the USGS website (or local files), retrieve a list of HCDN2009 stations, and make a table that contains station id, huc2, huc4, station name, state name, latitude, longitude, drainage area, and whether it belongs to the continental United States (CONUS) or not (1 if it does)

hcdn_list <- function(hcdn, st_code){
  
  rst <- data.table::data.table(station_id = character(),
                                huc2 = character(),
                                huc4 = character(),
                                station_nm = character(),
                                state_cd = character(),
                                lat_dec = numeric(),
                                log_dec = numeric(),
                                drain_area = numeric(),
                                drain_area_contr = numeric(),
                                conus = numeric()
                                )
  
  error_stations <-c()
  
  for (station in hcdn){
    
    site_info <- dataRetrieval::readNWISsite(station)
    station_id <- site_info$site_no
    if (is.null(station_id)) {
      error_stations[length(error_stations)+1] <- station
      next
    }
    
    huc2 <- substring(site_info$huc_cd, 1, 2)
    huc4 <- substring(site_info$huc_cd, 3, 4)
    station_nm = site_info$station_nm
    
    state_code <- site_info$state_cd
    state_cd <- st_code[st_code$STATE == state_code,]$STUSAB
    
    lat_dec <- site_info$dec_lat_va
    log_dec <- site_info$dec_long_va
    drain_area <- site_info$drain_area_va
    drain_area_contr <- site_info$contrib_drain_area_va
    
    if (as.numeric(huc2) <= 18) {
      conus <- 1
    } else {
      conus <- 0
    }

    rst <- rbindlist(list(rst, list(station_id, 
                                    huc2,
                                    huc4,
                                    station_nm,
                                    state_cd,
                                    lat_dec,
                                    log_dec,
                                    drain_area,
                                    drain_area_contr,
                                    conus)))
  }
  
  print(sprintf("Failed to retrieve info of %i station(s) with dataRetrieval", length(error_stations)))
  print(error_stations)
  return(rst)
}

st_code <- load_stcode("online"); hcdn <- load_hcdn("online")

result <- hcdn_list(hcdn, st_code)

setwd("~/spatial_dependence_ipeak/hcdn_list")
saveRDS(result,"hcdn_list.RData")





