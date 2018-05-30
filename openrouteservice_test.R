library(httr)
library(leaflet)
library(geojson)
library(sp)
library(rgdal)
library(geojsonio)
library(dplyr)

#### zorg dat je een apikey hebt van openrouteservice
key = readRDS("key.RDs")

### link naar api serive isochrones
link = "https://api.openrouteservice.org/isochrones"

### roep de service aan met een locatie en vertaal output meteen naar een geojson object
ors_out = GET(
  url = link,
  add_headers("Accept" = "application/json" , "charset"="utf-8"),
  query = list(
    api_key  = key,
    profile  = "driving-car",
    locations = "4.8510,52.3090",
    range_type = "time",
    range = "2000",
    interval = "2000"
  )
) %>%
  content("text") %>%
  as.geojson()
  
#### plot de regio op een leaflet
leaflet() %>%
  addTiles() %>%
  addGeoJSON(ors_out) %>% 
  fitBounds(bbox_get(ors_out)[1], bbox_get(ors_out)[2], bbox_get(ors_out)[3], bbox_get(ors_out)[4])
 
#### om te kijken of een lijst met punten in de regio zitten , hier bijv alle postcode punten
postcodes = readRDS("PostcodeTabelNL.RDs")

# Maak van lijst  een spatialpoint dataframe
coordinates(postcodes) = ~   Long_Postcode6P + Lat_Postcode6P
proj4string(postcodes) = CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")

### maak van geojso een spatial polygon data frame
spobject = geojson_sp(ors_out)

### nu kunnen we checken of een punt in de regio zit.
buurtinfo = sp::over( postcodes, spobject)

### filter de punten die in de regio liggen en in dit geval nog een kleine sample
postcodes2 = bind_cols(postcodes@data,as.data.frame(postcodes@coords),buurtinfo) %>%  
  filter(!is.na(group_index)) %>% sample_n(100)


####Zet ze op de kaart
leaflet() %>%
  addTiles() %>%
  addGeoJSON(ors_out) %>% 
  addMarkers(data = postcodes2, lng = ~Long_Postcode6P, lat = ~Lat_Postcode6P) %>% 
  fitBounds(bbox_get(ors_out)[1], bbox_get(ors_out)[2], bbox_get(ors_out)[3], bbox_get(ors_out)[4])



##########  CBS buurt data
CBS <- maptools::readShapeSpatial("CBS_PC4_2017_v1.shp")

#### Zet coordinatensysteem
proj4string(CBS) <-CRS("+init=epsg:28992 +towgs84=565.237,50.0087,465.658,-0.406857,0.350733,-1.87035,4.0812")


#### transformeer naar long /lat
CBS = spTransform(CBS, CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))

CBS@data[1,]

#### maak een hele simpele plot
plot(CBS)


tmp = over(CBS, spobject)
tmp2 = bind_cols(CBS@data,tmp)

######################################################################################

############ geocoding

link = "https://api.openrouteservice.org/geocode/search" 
?New%20item=Amstelveen


geo_out = GET(
  url = link,
  add_headers("Accept" = "application/json" , "charset"="utf-8"),
  query = list(
    api_key  = key,
    text = "30 West 26th Street, New York, NY"  
  )
) 

pp = content(geo_out)
