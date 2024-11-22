#!/bin/ksh
#####################################################
# machine set up (users should change this part)
#####################################################

# For Hera, Jet, Orio
#SBATCH --time=23:30:00
#SBATCH --qos=batch
#SBATCH --partition=service
#SBATCH --ntasks=1
#SBATCH --account=nrtrr
#SBATCH --job-name=aws_GFS
#SBATCH --output=./log.aws_GFS


# https://noaa-gfs-bdp-pds.s3.amazonaws.com/gfs.20240526/18/atmos/gfs.t18z.pgrb2.0p25.f000  (hourly up to f120, ~520M)
# https://noaa-gfs-bdp-pds.s3.amazonaws.com/gfs.20240526/18/atmos/gfs.t18z.pgrb2b.0p25.f000 (hourly up to f120, ~230M)

set -x

# Jet:
#datadir=/lfs4/BMC/wrfruc/RRFS_RETRO_DATA/GEFS
datadir=/lfs5/BMC/wrfruc/Chunhua.Zhou/w4/data/GFS/from_aws
# Hera:
#datadir=/scratch2/BMC/zrtrr/RRFS_RETRO_DATA/GEFS

waittime=30
maxtries=10

#for dates in 202307{28..31} 202308{01..07} 202308{25..31}
for dates in 20240526
do
  for hh in 18
  do
  awsdir="https://noaa-gfs-bdp-pds.s3.amazonaws.com/gfs.${dates}/${hh}/atmos"

    for fcsthr in {00..45..01}
      do
      fhr=$( printf "%03d" $fcsthr )

      yyyymmdd=$dates
      yy="${yyyymmdd:2:2}"
      yyyy="${yyyymmdd:0:4}"
      mm="${yyyymmdd:4:2}"
      dd="${yyyymmdd:6:2}"
      doy=`date  --date=$yyyymmdd +%j `

      echo "processing for $yyyymmdd $hh"
      indir=$datadir/gfs.${dates}/${hh}
      if [ ! -d ${indir} ]; then
        mkdir -p ${indir}
      fi

         cd ${indir}

         awsfile_a="${awsdir}/gfs.t${hh}z.pgrb2.0p25.f${fhr}"
         localfile_a=$(basename ${awsfile_a} )
         if [ ! -s  ${localfile_a} ]; then
           tries=0
           while [[ ! -s ${localfile_a} && $tries -lt $maxtries ]]
           do
              timeout  --foreground  $waittime wget ${awsfile_a}
              if [ $? -ne 0 ] ; then
                echo "Failed to download ${awsfile_a} ... trying again ..."
                rm -f ${localfile_a}
                let tries=$((tries+1))
              fi
           done
         fi

         awsfile_b="${awsdir}/gfs.t${hh}z.pgrb2b.0p25.f${fhr}"
         localfile_b=$(basename ${awsfile_b} )
         if [ ! -s  ${localfile_b} ]; then
           tries=0
           while [[ ! -s ${localfile_b} && $tries -lt $maxtries ]]
           do
              timeout  --foreground  $waittime wget ${awsfile_b}
              if [ $? -ne 0 ] ; then
                echo "Failed to download ${awsfile_b} ... trying again ..."
                rm -f ${localfile_b}
                let tries=$((tries+1))
              fi
           done
         fi

      done   # fcsthr
  done  # hh
done  # dates
