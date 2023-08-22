# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
  
  footer_server('psrcfooter')
  

# Map and Text -------------------------------------------

  output$safetydisclaimer <- renderText({safety_disclaimer_text})
  
  output$safetysource <- renderText({safety_data_source_text})
  
  output$possibleinjury <- renderText({possible_injury_text})
  
  output$evidentinjury <- renderText({evident_injury_text})
  
  output$seriousinjury <- renderText({serious_injury_text})
  
  output$fatalinjury <- renderText({fatal_injury_text})
  
  city_filter <- reactive({
    city_shape |> filter(name == input$City) 
  })
  
  collision_data <- reactive({
    readRDS(paste0("data/collisions/", input$City, ".rds"))|> 
      mutate(highest_severity = factor(highest_severity, levels = c("Possible Injury", "Evident Injury", "Serious Injury", "Traffic Related Death")))
  })
  
  output$safety_map <- renderLeaflet({
    
    injury_pal <- colorFactor(
      palette = c('#00A7A0', '#8CC63E', '#91268F', '#F05A28'),
      domain = collision_data()$highest_severity
    )
    
    labels <- paste0("<b>",paste0("Year: ", "</b>", collision_data()$collision_year, "<br>",
                                  "<b>","Injury Severity: ", "</b>", collision_data()$highest_severity, "<br>",
                                  "<b>", "Total Injuries: ", "</b>", collision_data()$total_injuries)) %>% lapply(htmltools::HTML)
    
    leaflet() |> 
      
      addProviderTiles(providers$CartoDB.Positron) |>
      
      addLayersControl(baseGroups = c("Base Map"),
                       overlayGroups = c("Injury Collisions", "City Boundary"),
                       options = layersControlOptions(collapsed = TRUE)) |>
      
      addCircles(data=collision_data(), 
                 group="Injury Collisions",
                 color = ~injury_pal(highest_severity),
                 opacity = 1.0,
                 fillOpacity = 1.0,
                 label = labels,
                 labelOptions = labelOptions(
                   style = list("font-weight" = "normal", padding = "3px 8px"),
                   textsize = "15px",
                   direction = "auto")) |>
      
      addPolygons(data = city_filter(),
                  fillColor = "76787A",
                  weight = 4,
                  opacity = 1.0,
                  color = "#91268F",
                  dashArray = "4",
                  fillOpacity = 0,
                  group = "City Boundary") |>
      
      #setView(lat=47.647, lng=-121.908, zoom=13) 
      
      addLegend(pal = injury_pal,
                values = collision_data()$highest_severity,
                group = "Injury Collisions",
                position = "bottomright",
                title = "Injury Severity")
  })
  
})    



