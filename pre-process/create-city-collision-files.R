library(tidyverse)
library(sf)

# Inputs ------------------------------------------------------------------
wgs84 <- 4326
spn <- 2285

buffer_distance <- 1

collision_layer <- readRDS("data/collision_layer.rds") |>
  st_transform(spn)

city_shape <- st_read("https://services6.arcgis.com/GWxg6t7KXELn1thE/arcgis/rest/services/City_Boundaries/FeatureServer/0/query?where=0=0&outFields=*&f=pgeojson") |>
  select(name="city_name") |>
  st_transform(spn)

cities <- unique(city_shape$name)
  
# Create Buffered City Collision Data -------------------------------------

for (c in cities) {
  
  buffered <- city_shape |>
    filter(name == c) |>
    st_buffer(buffer_distance*5280)
  
  collisions <- st_intersection(collision_layer, buffered) |> st_transform(wgs84)
  
  saveRDS(collisions, paste0("data/collisions/",c,".rds"))
  
}

