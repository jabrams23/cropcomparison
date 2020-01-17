##########################################
# Script to load crop harvested area rasters and 
# compare them to determine dominant crop 
#
# By Jesse F. Abrams
##########################################

# load libraries
library(raster)
library(sp)

# set working directory and load rasters
setwd("~/harvard_data/spam2010v1r1_global_harv_area.geotiff")

coco <- raster("spam2010V1r1_global_H_CNUT_A.tif")
sunf <- raster("spam2010V1r1_global_H_SUNF_A.tif")
maize <- raster("spam2010V1r1_global_H_MAIZ_A.tif")
oilpalm <- raster("spam2010V1r1_global_H_OILP_A.tif")
rape <- raster("spam2010V1r1_global_H_RAPE_A.tif")
soy <- raster("spam2010V1r1_global_H_SOYB_A.tif")
ground <- raster("spam2010V1r1_global_H_GROU_A.tif")
olive <- raster("~/earthstat/olive_HarvestedAreaHectares.tif")

# olive raster not available in SPAM dataset
# used olive data from earthstat
# have to resample oil raster to match others
olive <- resample(olive,coco,method='bilinear')

# create raster stack and variable with layer names
raster_names <- c("coco","sunf","maize","oilpalm","olive","rape","ground","soy")
raster_names <- as.factor(raster_names)
rr <- list(coco,sunf,maize,oilpalm,olive,rape,ground,soy)
s <- stack(rr)

# Extract the pixel-wise max values
max_val <- max(s)

# dummy variable for dominant crop
dominant <- coco

# determine which crop is dominant and
# assign that factor level to the dominant raster
for (i in 1:8) {
  tmp <- max_val - rr[[i]]
  values(dominant)[values(tmp)==0]<-raster_names[i]
}

# get rid of artifacts 
values(dominant)[values(max_val)<0.1] <- NA

# save raster
writeRaster(dominant,'dominant.tif',options=c('TFW=YES'),overwrite=TRUE)
