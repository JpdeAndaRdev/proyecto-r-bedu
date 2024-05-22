# 0) Pre ------------------------------------]
install.packages("tidyverse")
install.packages("leaflet")
install.packages( "bslib")
install.packages("plotly")
install.packages("rgbif")
install.packages("scrubr")
install.packages("sf")
install.packages("shiny")
install.packages("mapview")
pacman::p_load(tidyverse, rgbif, scrubr, sf, shiny, leaflet, bslib, plotly, mapview)

# 1) Preparación de datos ---------------------]

np <- occ_search(scientificName = 'Nothofagus pumilio')$data %>%
  dplyr::select(decimalLatitude, decimalLongitude) %>%
  na.omit %>%
  rename(lat = decimalLatitude, lon = decimalLongitude) %>%
  #dedup %>% 
  distinct() %>%
  mutate(especie = 'Nothofagus pumilio') %>%
  dplyr::filter(lat < 0, lon < 0)

na <- occ_search(scientificName = 'Nothofagus antarctica')$data %>%
  dplyr::select(decimalLatitude, decimalLongitude) %>%
  na.omit %>%
  rename(lat = decimalLatitude, lon = decimalLongitude) %>%
  #dedup %>%
  distinct() %>%
  mutate(especie = 'Nothofagus antarctica') %>%
  dplyr::filter(lat < 0, lon < 0)

datos <- np %>% 
  bind_rows(na)

datos_esp <- datos %>%
  st_as_sf(coords = c(2, 1),
           crs = 4326)

mapview(datos_esp)

ggplot(datos, aes(x = lon, y = lat)) + 
  geom_point() +
  theme_bw() +
  facet_wrap(~especie)

esp <- datos$especie %>% unique()

tema1 <- bs_theme(
  bg = "green",
  fg = "black",
  primary = "black"
)


# 2) UI -------------------------------------------]

ui <- fluidPage(
  
  theme = tema1,
  
  titlePanel('Presencias de Nothofagus'),
  
  sidebarLayout(
    
    sidebarPanel(
      selectInput('name', 'Seleccionar especie', esp),
      actionButton('recalc', 'Actualizar')
    ),
    
    mainPanel(
      
      tabsetPanel(
        tabPanel("Map",leafletOutput("mymap", height = 700)),
        tabPanel("Plot", plotlyOutput("plot", height = 700))
      )
      
    )
  )
)

# 3) Server ----------------------------------------]

server <- function(input, output, session) {
  
  pto <- eventReactive(input$recalc, {
    
    datos_esp %>%
      dplyr::filter(especie == input$name)
    
  })
  
  output$mymap <- renderLeaflet({
    
    leaflet() %>% 
      addProviderTiles("OpenStreetMap") %>%
      addCircles(data = pto())
    
  })
  
  output$plot <- renderPlotly({
    
    plot_ly(data = datos, x = ~lon, y = ~lat, color = ~especie, size = 2) %>%
      layout(title = "Coordenadas Nothofagus",
             yaxis = list(title = "Latitud"),
             xaxis = list(title = "Longitud"))
  })
}

# 4) Ejecutar Shiny app -------------------------------]

shinyApp(ui, server) 