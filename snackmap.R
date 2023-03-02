# 2023 snackmap 

master_exists <- T # already have all indiviudal .Rda combined into one file?

# pcks --------------------------------------------------------------------
pacman::p_load(rvest,here,dplyr,readr,leaflet,leaflet.extras,stringr,htmltools,colorspace,scales)

# load dat/map styles -----------------------------------------------------
ff <- here::here("data") 
id_df <- paste0(ff,"/id_df.csv") %>% read_csv 

# load master or combine all saved files into master
if(master_exists){
  cat("Reading master from dir")
  master <- readRDS(paste0(ff,"/final_locations/","_master.Rda"))  
}else{
  cat("Combining all data and saving to dir")
  dl <- paste0(ff,"/final_locations") %>% list.files(ignore.case = T,full.names = T) 
  nn <- paste0(ff,"/final_locations") %>% list.files(ignore.case = T,full.names = F) %>% str_remove_all(".Rda") 
  master <- list()
  for(i in seq_along(dl)){
    l <- dl[i] %>% readRDS() %>% list
    names(l) <- nn[i]
    master <- c(l,master) 
    master %>% saveRDS(paste0(ff,"/final_locations/","_master.Rda"))  
  }
}


# get place data ----------------------------------------------------------
fh <- "Bagels"
fn <- fh %>% str_replace_all(" ","_") %>% str_to_lower
m <- ff %>% paste0("/final_locations/", fn,".Rda") %>% readRDS

# test plot latlon
# leaflet() %>% setView(dr$lon[1],dr$lat[1],zoom=12) %>% addProviderTiles("CartoDB") %>% addCircles(dr$lon,dr$lat,label = dr$name, color = m$colv)

# map ----------------------------------------------------------------------
custom_tile <- "http://b.sm.mapstack.stamen.com/((mapbox-water,$f2f7ff[hsl-color]),(positron,$f2f7ff[hsl-color]),(buildings,$f2f7ff[hsl-color]),(parks,$2c403b[hsl-color]))/{z}/{x}/{y}.png"

# pars
setview <- c(144.960576, -37.81685)
ttl <- fh
opac <- 0.7
zoom = 13

marker_pulse <- makePulseIcon(
  color = m$colv,
  iconSize = 20,
  animate = T,
  heartbeat = 5
)

# iconset 
iconSet = pulseIconList(makePulseIcon(color = m$colv))
  

# easy buttons 
locate_me <- easyButton( # locate user
  icon="fa-crosshairs", title="Zoom to my position",
  onClick=JS("function(btn, map){ map.locate({setView: true}); }"));

reset_zoom <- easyButton( # reset zoom 
  icon="fa-globe", title="Reset zoom",
  onClick=JS("function(btn, map){ map.setZoom(5);}"));  

# text labels 
style <- list(
  "color" = m$colv,
  "font-weight" = "normal",
  "padding" = "8px"
)

# label options
text_label_opt <- labelOptions(noHide = F, direction = "top", textsize = "15px",
                               textOnly = F, opacity = 0.7, offset = c(0,0),
                               style = style, permanent = T
)

# layer options 
layer_options <- layersControlOptions(collapsed = F)


# title 
map_title <- tags$style( 
  HTML(".leaflet-control.map-title { 
       transform: translate(-50%,20%);
       position: fixed !important;
       left: 50%;
       text-align: center;
       padding-left: 10px; 
       padding-right: 10px; 
       background: white; opacity: 0.5;
       font-size: 40px;
       }"
  ))

title <- tags$div(
  map_title, HTML(ttl)
)  


# map
df <- m 
map <- leaflet() %>%  # initiate the leaflet map object
  setView(setview[1], setview[2], zoom = zoom) %>%
  addTiles(
    # df$style %>% unique
    custom_tile,
    group = c(fh),
    ) %>%  # add map tiles to the leaflet object
  addPulseMarkers(df$lon, df$lat,
                  icon = iconSet,  # marker_pulse,
                  popup = df$popup,
                  label = df$label,
                  popupOptions = text_label_opt,
                  labelOptions= text_label_opt,
                  group = fh
  ) %>%
# addCircleMarkers(df$lon, df$lat,
#                  radius = 10,
#                  stroke = T,
#                  weight = 3,
#                  opacity = opac,
#                  color = df$colv,
#                  fillColor = df$colv,
#                  popup = df$popup,
#                  label = df$label,
#                  popupOptions = text_label_opt,
#                  labelOptions= text_label_opt,
#                  group = fh
# ) %>%
  addLayersControl(
    baseGroups = c(fh
                   # ,layer2,layer3
                   ),
    options = layer_options) %>%
  # hideGroup(c(layer2,layer3)) %>% 
  addControl(title, "bottomleft", className = "map-title") %>% 
  # addControl(control_box, "topright", className = "layers-base") %>% 
  addEasyButton(reset_zoom) %>% 
  addEasyButton(locate_me) 

map 

