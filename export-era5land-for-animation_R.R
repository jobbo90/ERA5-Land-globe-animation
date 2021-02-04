# Quick export of ERA5-Land data from GEE for animation
# Philip Kraaijenbrink, 20201217
# Edited by Job de Vries 20210204 to rgee


library(rgee)
ee_Initialize()

# get era5 data
e5l       = ee$ImageCollection("ECMWF/ERA5_LAND/HOURLY")
expcrs    = e5l$first()$projection()$crs()$getInfo()
expscale  = e5l$first()$projection()$nominalScale()$getInfo()*2
expextent = ee$Geometry$LinearRing(list(c(-180, -90), c(180, -90), c(180, 90), c(-180, 90), c(-180, -90)), 'EPSG:4326', F)

# set list of variables to export
allbands     = e5l$first()$bandNames()$getInfo()
export_bands = c('dewpoint_temperature_2m','u_component_of_wind_10m', 'total_evaporation_hourly', 'soil_temperature_level_1', 'total_precipitation_hourly', 
                'soil_temperature_level_4', 'volumetric_soil_water_layer_1', 'skin_temperature', 'snowfall_hourly', 'surface_sensible_heat_flux_hourly','v_component_of_wind_10m',
                'surface_solar_radiation_downwards_hourly', 'leaf_area_index_low_vegetation', 'surface_latent_heat_flux_hourly', 'temperature_2m', 'potential_evaporation_hourly', 
                'surface_pressure','surface_net_solar_radiation_hourly')

delta <- 0
days_per_var <- 1
startdate = as.Date('2020-01-01')
for(band in export_bands){
  # band <- export_bands[1]
  # get time filter params
  sdate = startdate + delta
  edate = startdate + delta + days_per_var
  sdate_str = as.character(as.Date(sdate))#dt.strftime(sdate,'%Y-%m-%d')
  edate_str = as.character(as.Date(edate))#dt.strftime(edate,'%Y-%m-%d')
  delta <- delta + days_per_var

  # get bandstack of the hourly data for current var
  expimg = e5l$filterDate(sdate_str, edate_str)$
    select(band)$toBands()

# export
  task =ee$batch$Export$image$toDrive(
    # ee_image_to_drive(
    image=expimg,
    region=expextent,
    scale=expscale,
    crs=expcrs,
    description= paste0('E5L_',band),
    folder ='GEE',
    fileNamePrefix= paste0(gsub('-', '', sdate_str), '-', 
                           gsub('-', '', edate_str), '_', band))
      
  task$start()

  print( paste0(gsub('-', '', sdate_str), '-', 
                gsub('-', '', edate_str), '_', band))
}
