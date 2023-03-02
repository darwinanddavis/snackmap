# check '_snackmap.txt' for dir of downloaded google location data 

# read geolocation data ---------------------------------------------------------------
# check all food options 
ff <- here::here("snackmap","data") 
paste0(ff,"/Takeout","/Saved") %>% list.files()
fh <- "Bagels"
d <- paste0(ff,"/Takeout","/Saved") %>% list.files(fh,full.names = T) %>%  read_csv

# first check if we've already downloaded data  
if(paste0(ff,"/final_locations") %>% list.files(fh,ignore.case = T,full.names = T) %>% is_empty()){
  cat("Getting new google geocodedata from web")
  dr <- geocode(d %>% pull(Title), output = "more",nameType = "long")
  dr <- dr %>% mutate(name = d %>% pull(Title),
                      note = d %>% pull(Note)) %>% 
    mutate_at("note", ~replace(.,is.na(.), "")) %>%  # replace NA with empty string
    # add fh, col, style, popups, and labels for leaflet to saved file
    mutate("fh" = fh,
           "colv" = "#6B56A7", #id_df %>% filter(Name == fn) %>% pull(Col),
           "style" = "mapbox://styles/darwinanddavis/ckfp0sbhb0dkm19nr5dvf68km", # id_df %>% filter(Name == fn) %>% pull(Style)
           "popup" = paste0("<strong>",name,"</strong><br/><span style=color:",colv,";>", address %>% str_to_title(),"</span><br/>",note) %>% purrr::map(htmltools::HTML),
           "label" = paste0("<strong>",name,"</strong><br/><span style=color:",colv,";>", address %>% str_to_title(),"</span><br/>",note) %>% purrr::map(htmltools::HTML)
    )
  if(d %>% nrow!=dr %>% nrow) cat("Missing" ,d %>% nrow-dr %>% nrow, "locations")
  cat(paste0("Saving ",fh,".Rda to dir"))
  dr %>% saveRDS(paste0(ff,"/final_locations/",fh %>% str_replace_all(" ","_") %>% str_to_lower(),".Rda"))
}

# 
# d <- "/Users/malishev/Documents/Data/snackmap/data/final_locations/happy_hour.Rda" %>%
#   readRDS %>% 
#   mutate_at(
#     "popup", ~paste0("<strong>",name,"</strong><br/><span style=color:",colv,";>", address %>% str_to_title(),"</span><br/>",note) %>% purrr::map(htmltools::HTML)) %>% 
#   mutate_at(
#     "label", ~paste0("<strong>",name,"</strong><br/><span style=color:",colv,";>", address %>% str_to_title(),"</span><br/>",note) %>% purrr::map(htmltools::HTML)
#   )
# 
# master[["happy_hour"]] <- d

  
  



