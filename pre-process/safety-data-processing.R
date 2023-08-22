library(tidyverse)
library(data.table)
library(sf)

# Inputs ------------------------------------------------------------------
wgs84 <- 4326

first_year <- 2015
latest_year <- 2022
final_injury_cols <- c("report_number", "lat", "lon", "county", "city", 
                       "collision_year", "junction", "severity", "gender", 
                       "age_group", "person_mode", "time_of_day", "day_of_week",
                       "weather", "lighting")

file_path <- "C:/coding/safety-data/data/post2015/"

# Processing Raw Data -----------------------------------------------------
print("Reading data files. This process can take up to 20 minutes depending on network speed so please be patient.")
processed <- NULL
for (file in list.files(path = file_path, pattern = ".*.csv")) {
  print(str_glue("Reading {file}"))
  
  t <- as_tibble(fread(paste0(file_path, file), skip = 1)) |>
    transmute(report_number = `Collision Report Number`,
              injury_type = `Injury Type`,
              most_severe_injury = `Most Severe Injury Type`,
              lat = Latitude,
              lon = Longitude,
              county = `County Name`,
              city = ifelse(`City Name` == "", "Unincorporated", `City Name`),
              inc_date = mdy(gsub(" 0:00", "", Date)),
              inc_time = `Full Time 24`,
              fatalities = `Number of Fatalities`,
              serious_injuries = `Total Serious Injuries`,
              evident_injuries = `Total Evident Injuries`,
              possible_injuries = `Total Possible Injuries`,
              total_injuries = `Total Number of Injuries`,
              num_bike = `Number of Pedal Cyclists Involved`,
              num_ped = `Number of Pedestrians Involved`,
              num_veh = `Number of Vehicles Involved`,
              roadway = `Collision Report Type`,
              junction = `Junction Relationship`,
              weather = Weather,
              surface = `Roadway Surface Condition`,
              lighting = `Lighting Condition`,
              unit_type = `Unit Type Description`,
              person_type = `Involved Person Type`,
              vehicle_type = `Vehicle Type`,
              age = Age,
              gender = Gender,
              state_fc = `State Route Federal Functional Class Name`,
              county_fc = `County_Federal Functional Class Name`,
              distracted = `Distracted Involved Person Flag`
    )
  
  # Combine summarized tables
  ifelse(is.null(processed),
         processed <- t,
         processed <- bind_rows(processed, t))
  
  rm(t)
  
} # end of file loop

# Individual Injuries -----------------------------------------------------
print("Creating Injury layer - each row is for a person and includes demographic details")
injuries <- processed |>
  
  # Clean up Injury Type
  mutate(severity = case_when(
    injury_type %in% c("Non-Traffic Fatality", "Dead at Scene", "Died at Hospital", "Dead on Arrival") ~ "Traffic Related Death",
    injury_type %in% c("Suspected Serious Injury") ~ "Serious Injury",
    injury_type %in% c("Suspected Minor Injury", "Non-Traffic Injury") ~ "Evident Injury",
    injury_type %in% c("Possible Injury") ~ "Possible Injury",
    injury_type %in% c("Unknown" ,"", "No Apparent Injury") ~ "No Injury")) |>
  filter(severity != "No Injury") |>
  
  # Clean up Age Group
  mutate(age_group = case_when(
    age <18 ~ "0 to 18",
    age <30 ~ "18 to 29",
    age <40 ~ "30 to 39",
    age <50 ~ "40 to 49",
    age <65 ~ "50 to 64",
    age <=120 ~ "65+",
    is.na(age) ~ "Unknown")) |>
  
  # Clean up Person Type (Bike, Walk or Vehicle)
  mutate(person_mode = case_when(
    unit_type =="Motor Vehicle" ~ "Motor Vehicle",
    unit_type =="Pedestrian" ~ "Walking",
    unit_type == "Pedalcyclist" ~ "Biking")) |>
  
  # Clean up Time of Day
  separate(inc_time, into=c("hour", "minutes"), sep=":", remove=FALSE) |>
  mutate(time_of_day = case_when(
    as.integer(hour) %in% c(22,23,0,1,2,3,4,5) ~ "Overnight",
    as.integer(hour) %in% c(6,7,8) ~ "AM Peak",
    as.integer(hour) %in% c(9,10,11,12,13,14) ~ "Midday",
    as.integer(hour) %in% c(15,16,17) ~ "PM Peak",
    as.integer(hour) %in% c(18,19,20,21) ~ "Evening")) |>
  
  # Clean up date and filter to last 5 years
  mutate(collision_year = year(ymd(inc_date))) |>
  filter(collision_year >= first_year) |>
  
  # Add Day of Week
  mutate(day_of_week = lubridate::wday(ymd(inc_date), label = TRUE)) |>
  
  # Remove any Collisions that are not coded with latitude/longitude
  drop_na(lat) |>
  drop_na(lon) |>
  
  # Final Cleanup
  mutate(number_of_injuries = 1) |>
  select(all_of(final_injury_cols)) 

# Create injury layer for mapping
injury_layer <- injuries |>
  st_as_sf(coords = c("lon", "lat"), crs = wgs84) |>
  st_transform(wgs84)

saveRDS(injury_layer, "data/injury_layer.rds")

# Collisions --------------------------------------------------
print("Creating Collision layer - each row is for a collision and does not include demographiv layers")
collisions <- processed |>
  
  # Clean up Injury Type
  mutate(highest_severity = case_when(
    most_severe_injury %in% c("Non-Traffic Fatality", "Dead at Scene", "Died at Hospital", "Dead on Arrival") ~ "Traffic Related Death",
    most_severe_injury %in% c("Suspected Serious Injury") ~ "Serious Injury",
    most_severe_injury %in% c("Suspected Minor Injury", "Non-Traffic Injury") ~ "Evident Injury",
    most_severe_injury %in% c("Possible Injury") ~ "Possible Injury",
    most_severe_injury %in% c("Unknown" ,"", "No Apparent Injury") ~ "No Injury")) |>
  filter(highest_severity != "No Injury") |>
  mutate(number_of_injuries = 1) |>
  
  # Clean up Time of Day
  separate(inc_time, into=c("hour", "minutes"), sep=":", remove=FALSE) |>
  mutate(time_of_day = case_when(
    as.integer(hour) %in% c(22,23,0,1,2,3,4,5) ~ "Overnight",
    as.integer(hour) %in% c(6,7,8) ~ "AM Peak",
    as.integer(hour) %in% c(9,10,11,12,13,14) ~ "Midday",
    as.integer(hour) %in% c(15,16,17) ~ "PM Peak",
    as.integer(hour) %in% c(18,19,20,21) ~ "Evening")) |>
  
  # Clean up date and filter to last 5 years
  mutate(collision_year = year(ymd(inc_date))) |>
  filter(collision_year >= first_year) |>
  
  # Add Day of Week
  mutate(day_of_week = lubridate::wday(ymd(inc_date), label = TRUE)) |>
  
  # Remove any Collisions that are not coded with latitude/longitude
  drop_na(lat) |>
  drop_na(lon) |>
  
  # Combine into Collisions
  group_by(report_number, highest_severity, time_of_day, day_of_week, collision_year, lat, lon) |>
  summarise(deaths = mean(fatalities), serious_injuries = mean(serious_injuries), evident_injuries = mean(evident_injuries), possible_injuries = mean(possible_injuries), total_injuries = mean(total_injuries)) |>
  as_tibble() 

# Create collision layer for mapping
collision_layer <- collisions |>
  st_as_sf(coords = c("lon", "lat"), crs = wgs84) |>
  st_transform(wgs84)

saveRDS(collision_layer, "data/collision_layer.rds")

