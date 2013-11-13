## Author: Thanos Strantzalis
## Date: November 2013
## Description: The script evaluates the average yield (tones/ha) per polygon
##and plot the map



rm(list = ls())

library(rgdal)
library(sp)
library(rgeos)

# load the clean_lines shapefile
cln_lines_df<-readOGR("data", "cln_lines")

# 1. buffer the cleaned lines to create harvest blocks
cln_buffer <- gBuffer(cln_lines_df,byid = T, width=0.75*cln_lines_df$width,
                      capStyle="ROUND")

# 2. Fill small holes by swelling and shrinking
cln_buffer <- gBuffer(cln_buffer, byid=T,id=rownames(cln_buffer), width = 2.0)
cln_buffer <- gBuffer(cln_buffer, byid=T,id=rownames(cln_buffer), width = -2.0)
cln_poly_df <- SpatialPolygonsDataFrame(cln_buffer, cln_lines_df@data)

# 3 compute for each block the yield per hectare and 
# add this attribute to the spatial polygons data frame;
cln_poly_df$area <-gArea(cln_poly_df, byid=T)
cln_poly_df$tones_ha<-((cln_poly_df$loads/cln_poly_df$area)*10000)

# 4 make a map showing the the yield per hectare of each block, using spplot;
spplot(cln_poly_df, zcol="tones_ha", lwd=1.5, col.regions =
         bpy.colors(nlevels(cln_poly_df$ID)))

# 5 export the spatial polygons data frame to
# display polygon boundaries in Google Earth using writeOGR;
prj_string_WGS <- CRS("+proj=longlat +datum=WGS84")
cln_poly_df<- spTransform(cln_poly_df, prj_string_WGS)
writeOGR(cln_poly_df, file.path("data","cln_poly.kml"),
         "cln_poly_df", driver="KML", overwrite_layer=TRUE)
