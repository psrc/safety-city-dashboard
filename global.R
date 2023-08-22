library(shiny)
library(shinydashboard)
library(bs4Dash)
library(tidyverse)
library(sf)
library(leaflet)

wgs84 <- 4326
spn <- 2285

module_files <- list.files('modules', full.names = TRUE)
sapply(module_files, source)

# Load Data ---------------------------------------------------------------

safety_disclaimer_text <- c("Under 23 U.S. Code § 148 and 23 U.S. Code § 407, safety data, reports, surveys, schedules, lists compiled or collected for the purpose of identifying, evaluating, or planning the safety enhancement of potential crash sites, hazardous roadway conditions, or railway-highway crossings are not subject to discovery or admitted into evidence in a Federal or State court proceeding or considered for other purposes in any action for damages arising from any occurrence at a location mentioned or addressed in such reports, surveys, schedules, lists, or data.")
safety_data_source_text <- c("Source: Washington State Department of Transportation, Crash Data Division, Multi-Row data files (MRFF)")
possible_injury_text <- c("Any injury reported to the officer or claimed by the individual such as momentary unconsciousness, claim of injuries not evident, limping, complaint of pain, nausea, hysteria, etc")
evident_injury_text <- c("Any injury other than fatal or disabling at the scene. Includes: broken fingers or toes, abrasions, etc. Excludes: limping, complaint of pain, nausea, momentary unconsciousness, etc")
serious_injury_text <- c("Any injury which prevents the injured person from walking, driving, or continuing normal activities at the time of the collision. Includes: severe lacerations, broken or distorted limbs, skull or chest injuries, abdominal injuries, etc. Excludes: momentary unconsciousness, etc.")
fatal_injury_text <- c("Pronounced dead at the collision scene, upon arrival at hospital or medical facility or died in hospital after arrival.")

city_shape <- st_read("https://services6.arcgis.com/GWxg6t7KXELn1thE/arcgis/rest/services/City_Boundaries/FeatureServer/0/query?where=0=0&outFields=*&f=pgeojson") |>
  select(name="city_name") |>
  st_transform(wgs84)

cities <- unique(city_shape$name)

