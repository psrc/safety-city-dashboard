shinyUI(
  
  navbarPage(
    
    id = "Safety Collision Data",
    tags$style("@import url(https://use.fontawesome.com/releases/v6.3.0/css/all.css);"),
    title = tags$a(div(tags$img(src='psrc-logo.png',
                             style="margin-top: -30px; padding-left: 40px;",
                             height = "80")
                             ), href="https://www.psrc.org", target="_blank"),
             tags$head(
               tags$style(HTML('.navbar-nav > li > a, .navbar-brand {
                            padding-top:25px !important; 
                            padding-bottom:0 !important;
                            height: 75px;
                            }
                           .navbar {min-height:25px !important;}'))
             ),
    
             windowTitle = "Safety Collision Data", 
             theme = "styles.css",
             position = "fixed-top",
             
    tabPanel(title=HTML("Map"),
             value="Safety_Map",
             
             fluidRow(column(12, 
               div(style = "height: 100px; background-color: #005753; width: 100%;",
                 tags$p(
                   "Injury Collision Data: 2015 to 2022", 
                   style = 
                     "color: white; font-family: Poppins; font-size: 18pt; font-weight: bold; position: relative; top: 50%; -ms-transform: translateY(-50%); transform: translateY(-50%); padding-right: 25px; padding-left: 25px;"
                 )))),
             
             br(),
                
             fluidRow(column(4, style='padding-left:25px; padding-right:0px;',
                             br(),
                             strong(tags$div(class="sidebar_headings", "Possible Injury:")),
                             tags$div(class="sidebar_notes", textOutput("possibleinjury")),
                             br(),
                             strong(tags$div(class="sidebar_headings", "Evident Injury:")),
                             tags$div(class="sidebar_notes", textOutput("evidentinjury")),
                             br(),
                             strong(tags$div(class="sidebar_headings", "Serious Injury:")),
                             tags$div(class="sidebar_notes", textOutput("seriousinjury")),
                             br(),
                             strong(tags$div(class="sidebar_headings", "Traffic Related Death:")),
                             tags$div(class="sidebar_notes", textOutput("fatalinjury"))),
                      
                      column(8, style='padding-left:25px; padding-right:25px;',
                             
                             fluidRow(column(3, ""),
                                      column(9, selectInput("City","Select City:", cities, selected = "Carnation"))),

                             fluidRow(column(12, leafletOutput("safety_map"))),
                             tags$div(class="chart_source", textOutput("safetysource"))
                            
                      ),
                      hr()),
             
             fluidRow(column(12, 
                             hr(style = "border-top: 1px solid #000000;"),
                             strong(tags$div(class="sidebar_headings", "Note on Safety Data:")),
                             tags$div(class="chart_source", textOutput("safetydisclaimer")),
                             hr(style = "border-top: 1px solid #000000;")))
             
    ), # end Tabpanel

                      
    tags$footer(footer_ui('psrcfooter'))
    
             ) # End of NavBar Page
  ) # End of Shiny App
