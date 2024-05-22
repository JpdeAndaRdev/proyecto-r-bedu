# proyecto-r-bedu
proyecto del modulo de r en Bedu (Juan Pablo De Anda / Javier Alejandro De Anda)


Explicación detallada: ShinyApp geoespacial final


0) Preparación

pacman::p_load(tidyverse,rgbif,scrubr,sf,shiny,leaflet,bslib,plotly,mapview)

Esta línea carga las bibliotecas necesarias para el código. 'pacman' es una biblioteca en R que puede manejar paquetes. La función 'p_load' de 'pacman' instalará y cargará las bibliotecas si aún no están instaladas.

Aquí hay una breve descripción de los paquetes que se están cargando:


- `tidyverse`: Colección de paquetes para manipulación y visualización de datos.

- `rgbif`: Proporciona una interfaz a la API de GBIF para acceder a datos de biodiversidad.

- `sf`: Para manipulación de datos espaciales.

- `shiny`: Para construir aplicaciones web interactivas.

- `leaflet`: Para crear mapas interactivos.

- `bslib`: Para estilizar aplicaciones Shiny con Bootstrap.

- `plotly`: Para crear gráficos interactivos.

- `mapview`: Para visualizar datos espaciales.


1) Preparación

El bloque de código en esta sección realiza varias tareas:

- Utiliza la función `occ_search` del paquete `rgbif` para buscar datos de presencia de las especies Nothofagus pumilio y Nothofagus antarctica.

- Usa operadores de "pipe" (`%>%`) para enlazar múltiples funciones.

- Selecciona solo las columnas `decimalLatitude` y `decimalLongitude` con `dplyr::select`.

- Renombra las columnas de latitud y longitud con `rename`.

- Elimina duplicados con `dedup`.

- Agrega una nueva columna para la especie con `mutate`.

- Filtra los datos para que solo incluyan observaciones en el hemisferio sur y oeste (latitud y longitud negativas) con `dplyr::filter`.

El resultado es un conjunto de datos limpio para cada especie que contiene latitud, longitud y nombre de la especie.

datos <- np %>% bind_rows(na)

Esta línea combina las filas de los dos conjuntos de datos en un solo conjunto de datos.

datos_esp <- datos %>% st_as_sf(coords = c(2, 1), crs = 4326)

Aquí, los datos se convierten en un objeto de tipo "sf" (simple features), que es un formato que se utiliza para manejar datos espaciales en R. Las columnas que contienen las coordenadas son especificadas por `coords = c(2, 1)`, y `crs = 4326` especifica el sistema de referencia de coordenadas (CRS) a utilizar.

esp <- datos$especie %>% unique

Esta línea extrae las especies únicas del conjunto de datos `datos` en la variable `esp`.

tema1 <- bs_theme(bg = "green", fg = "black", primary = "black")

Aquí, se crea un tema de bootstrap para usarlo en la aplicación Shiny.

2) UI

Este bloque de código define la interfaz de usuario (UI) para la aplicación Shiny. La interfaz de usuario incluye un panel de título, un panel lateral con una entrada de selección y un botón de acción, y un panel principal con dos pestañas para mostrar el mapa y el gráfico de dispersión.

3) Server

El bloque de código en esta sección define el lado del servidor de la aplicación Shiny. Esto incluye:

- Crear una salida reactiva que se actualiza cada vez que el usuario hace clic en el botón "Actualizar".

- Definir las salidas que se mostrarán en la interfaz de usuario. Esto incluye un mapa creado con `leaflet` y un gráfico de dispersión creado con `plotly`.

4) Ejecutar

Finalmente, la función `shinyApp` se utiliza para lanzar la aplicación Shiny con la interfaz de usuario y el servidor que se han definido anteriormente.

Ahora, vamos a desglosar más detalles sobre las partes específicas:

Código de la función occ_search()

occ_search(scientificName = "Nothofagus pumilio")$data

La función `occ_search` proviene del paquete `rgbif`, que proporciona acceso a la API del Global Biodiversity Information Facility (GBIF). Esta función realiza una búsqueda de la presencia de una especie específica (en este caso, "Nothofagus pumilio"). Los resultados de la búsqueda se devuelven como una lista, y `$data` se utiliza para extraer el dataframe que contiene los datos de presencia de la especie.

Código de la función dedup()

dedup

La función `dedup` proviene del paquete `scrubr`, que proporciona métodos para limpiar los datos de biodiversidad. En este caso, `dedup` se utiliza para eliminar los registros duplicados del conjunto de datos.

Código de la función mutate()

mutate(especie = "Nothofagus pumilio")

La función `mutate` proviene del paquete `dplyr` y se utiliza para añadir nuevas variables al conjunto de datos. En este caso, se añade una nueva columna llamada "especie", que tiene el valor "Nothofagus pumilio" para todos los registros.

Código de la función st_as_sf()

st_as_sf(coords = c(2, 1), crs = 4326)

La función `st_as_sf` proviene del paquete `sf`, que proporciona clases y métodos para manipular datos espaciales. La función `st_as_sf` convierte un objeto en un objeto de clase 'sf'. Las coordenadas geográficas (latitud y longitud) se especifican con `coords = c(2, 1)`, y el sistema de referencia de coordenadas (CRS) se especifica con `crs = 4326`.

Código de la función bs_theme()

bs_theme(bg = "green", fg = "black", primary = "black")

La función `bs_theme` proviene del paquete `bslib` y se utiliza para crear un tema personalizado de Bootstrap para la aplicación Shiny. Los argumentos `bg`, `fg` y `primary` se utilizan para especificar los colores de fondo, de primer plano y primario, respectivamente.

Código de la función eventReactive()

pto <- eventReactive(input$recalc, { datos_esp %>% dplyr::filter(especie == input$name) })

La función `eventReactive` se utiliza para crear una salida reactiva que se actualiza en respuesta a un evento. En este caso, la salida `pto` se actualiza cada vez que el usuario hace clic en el botón "Actualizar" (input$recalc). Cuando se actualiza, se filtra el conjunto de datos `datos_esp` para incluir solo los registros de la especie seleccionada por el usuario (input$name).



Código de las funciones renderLeaflet() y renderPlotly()



output$mymap <- renderLeaflet({ leaflet() %>% addProviderTiles("OpenStreetMap") %>% addCircles(data = pto()) })



output$plot <- renderPlotly({ plot_ly(data = datos, x = ~lon, y = ~lat, color = ~especie, size = 2) %>% layout(title = "Coordenadas Nothofagus", yaxis = list(title = "Latitud"), xaxis = list(title = "Longitud")) })



Estas dos funciones se utilizan para crear salidas reactivas que se mostrarán en la interfaz de usuario. `renderLeaflet` genera un mapa interactivo usando la biblioteca `leaflet`. `addProviderTiles("OpenStreetMap")` añade los mosaicos del mapa de OpenStreetMap, y `addCircles(data = pto())` añade círculos a las ubicaciones de las observaciones de la especie seleccionada por el usuario.



Por otro lado, `renderPlotly` genera un gráfico de dispersión interactivo utilizando la biblioteca `plotly`. Los argumentos `x = ~lon`, `y = ~lat` y `color = ~especie` se utilizan para especificar las variables que se utilizarán para los ejes x e y y el color de los puntos, respectivamente.



Código de la función shinyApp()



shinyApp(ui, server)



Finalmente, la función `shinyApp` se utiliza para crear y lanzar la aplicación Shiny. Los argumentos `ui` y `server` se refieren a la interfaz de usuario y al servidor que se han definido anteriormente.
