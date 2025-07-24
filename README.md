# rrfs-stagedata
This repository contains scripts to stage RRFS data for retrospective experiments.


We will need to stage these data for RRFS retro run: 

Observation: GVF, SST, snow,  conventional observation, vaisala lightning, radar reflectivity
Data Assimilation: GDAS or RRFS ensemble for GSI hybrid, mesonet use list, amdar reject list
Model: GFS forecast as ICs/LBCs, RAP/HRRR soil for soil surgery

These scripts mainly provide the HPSS path for each data, please make a copy and necessary changes for your use.


Clone scripts:
git clone https://github.com/NOAA-GSL/rrfs-stagedata.git



## Observation Scripts:

GVF: `gvf.ksh`, zip file contains j01 and npp data, npp is used in RRFS.

SST: `sst.ksh`

Snow: `snow.ksh`


RRFS reads GVF, SST and snow from the previous day for the current cycle, so if retro run start from July 20, you need to save July 19 data also.

Vaisala lightning: `lightning.ksh`

RAP conventional observation: `obsrap.ksh`,
zip file contain several types of data, *.rap.* and *rap_e* data are used in RRFS, you can delete other types if it’s needed.

Radar reflectivity: `refl_oneColumnADay.ksh` finds a MRMS reflectivity column around 00, 15, 30, 45 minute, so four columns each hour, ~3k files per day. These columns are used in RRFS, so suggest to use this script to stage data.

`refl.ksh` gets all MRMS reflectivity columns, it’s ~23K per day. The files are saved under `upperair/mrms/conus/MergedReflectivityQC` automatically, so usually I put data in tmp directory, if all data looks good, then  move data day by day to the desired location, for example, 
            `mv tmp/upperair/mrms/conus/MergedReflectivityQC/*20230610*   reflectivity/`
	

## Data Assimilation scripts:
                 
mesonet use list and amdar reject list are saved on Jet at
```
AIRCRAFT_REJECT="/home/role.amb-verif/acars_RR/amdar_reject_lists"
SFCOBS_USELIST="/lfs4/BMC/amb-verif/rap_ops_mesonet_uselists"
```
If retro run is on Hera, please copy the required file to Hera. GSI reads the previous day file for the current cycle, so if retro run start from July 20, you need to save July 19 data also.

GDAS ensemble: `getFV3GDASensembles`,GSI reads previous six hour GDAS members for current cycle, so if retro run starts on July 20 03Z, you need to stage July 19 18Z members also.
 
RRFS ensemble

`retrieve_dsg_GEFS.sh`: pull GEFS GRIB-2 data for initializing the RRFS ensemble

`Fill_GEFS_from_aws.sh`: pull GEFS data from AWS and fill the DSG GEFS data gap
            
Previous 30 hr GEFS data is needed,  if retro run starts on July 20 03Z, you need to stage July 19 00Z members also.
 
If need to interpolate the 3-hourly GEFS data to hourly data, please refer to the scripts at  https://github.com/NOAA-GSL/GEFS_time_interpolation


## Model scripts:

GFS forecast: `gfs.ksh`, 50 hour forecast should be enough for current RRFS. If retro starts on July 20 03Z, you need to stage July 19 18Z GFS forecast also. 

If you need to interpolate 3-hourly GFS data to hourly data (e.g. 2020 gfs data), use `/scratch1/BMC/wrfruc/chunhua/code/GEFS_time_interpolation/GFS_time_interp_standalone.sh`
 
For example, get hourly data for 00Z July 27, 2020 from forecast hours 0 to 24, please do so:
`./GFS_time_interp_standalone.sh 2020727 0 24 00`

RAP/HRRR soil: 
If you use GFS for ICs, you need to do soil surgery. Use `get_raphrrrsoil.ksh` to get rap/hrrr soil, for example, retro run starts at 2022072003(spin up cycle), soil surgery should be done at 04Z, so stage 2022072004 rap.t04z.wrf_inout_smoke and hrrr.t04z.wrf_inout. If the data is missing for current cycle, use previous/next cycle data instead since soil does not change much.
 
If you use RAP for ICs, there is no need to do soil surgery.


After stage data, usually I will check the file number for each data using `retro_check.ksh`, it checks GFS forecast, lightning, GDAS ensembles, RAP observation and MRMS reflectivity. For other data, it’s easy to check manually. If all data looks good, then update the data path in rrfs-workflow/ush/set_rrfs_config.sh before generating the workflow.

For example, update these variables to your location on Hera if it’s needed:
if [[ $DO_RETRO == "TRUE" ]] ; then
…
if [[ $MACHINE == "hera" ]] ; then
…     
    RETRODATAPATH="/scratch2/BMC/zrtrr/RRFS_RETRO_DATA"

