rm(list = ls())

library(rgdal)
library(sp)

# load the clean_lines shapefile
cln_lines_df<-readOGR("data", "cln_lines")

# Buffer clean lines to make harvesting blocks
cln_buffer <- gBuffer(cln_lines_df,byid = T, width=0.75*cln_lines_df$width,
                      capStyle="ROUND")

#  Fill small holes by swelling and shrinking
cln_buffer <- gBuffer(cln_buffer, byid=T,id=rownames(cln_buffer), width = 2.0)
cln_buffer <- gBuffer(cln_buffer, byid=T,id=rownames(cln_buffer), width = -2.0)
cln_lines_df <- SpatialPolygonsDataFrame(cln_buffer, cln_lines_df@data)


spplot(cln_buffer, zcol="loads", lwd=1.5, col.regions =
         bpy.colors(nlevels(sp_polys$ID)))