# Preprocessing of the remote sensing data

library(terra)
library(mapview)

imagepath <- "S2A_MSIL2A_20220623T103031_N0400_R108_T32ULC_20220623T170319.SAFE/GRANULE/L2A_T32ULC_A036570_20220623T103034/IMG_DATA/"

################################################################################
# Resample channels to same geometry (target: 10m)
################################################################################

# read a stack for the 10m channels
images10m <- list.files(paste0(imagepath,"/R10m"),full.names = TRUE)
images10m <- images10m[grepl("B02|B03|B04|B08",images10m)]
senstack_10 <- rast(images10m)

#... and one for the 20m channels:
images20m <- list.files(paste0(imagepath,"/R20m"),full.names = TRUE)
images20m <- images20m[grepl("B05|B06|B07|B11|B12|B8A",images20m)]
senstack_20 <- rast(images20m)

# crop to the extent of the study area
senstack_10 <- crop(senstack_10,c(390309.5, 418741.3, 5746125.4,5768919.6))
senstack_20 <- crop(senstack_20,c(390309.5, 418741.3, 5746125.4,5768919.6))

#resample from 20 to 10m, stack all channels
senstack_20_res <- resample(senstack_20,senstack_10)
sen_ms <- c(senstack_10,senstack_20_res)

# adjust names
names(sen_ms) 
names(sen_ms) <- substr(names(sen_ms),
                              nchar(names(sen_ms))-6, # from the 6th-last position...
                              nchar(names(sen_ms))-4) #to the 4th-last

names(sen_ms)

################################################################################
# Visualization
################################################################################
plot(sen_ms)
plotRGB(sen_ms,r=3,g=2,b=1,stretch="lin")
plotRGB(sen_ms,r=4,g=3,b=2,stretch="lin")


################################################################################
# NDVI calculation
################################################################################
sen_ms$NDVI <- (sen_ms$B08-sen_ms$B04)/(sen_ms$B08+sen_ms$B04)
plot(sen_ms$NDVI )

################################################################################
# Optional: Texture information
################################################################################
sen_ms$NDVI_5x5_sd <- focal(sen_ms$NDVI,w=matrix(1,5,5), fun=sd)
plot(sen_ms$NDVI_5x5_sd)

################################################################################
# Write Raster
################################################################################
writeRaster(sen_ms,
            "sentinel_combined.tif",
            overwrite=T)