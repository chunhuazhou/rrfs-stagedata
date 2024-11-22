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
#SBATCH --job-name=aws_GEFS
#SBATCH --output=./log.aws_GEFS.2

# For WCOSS2
##PBS -A RRFS-DEV
##PBS -q dev_transfer
##PBS -l select=1:ncpus=1:mem=2G
##PBS -l walltime=06:00:00
##PBS -N Fill_GEFS_from_aws
##PBS -j oe -o log.Fill_GEFS_from_aws

# https://noaa-gefs-pds.s3.amazonaws.com/gefs.20220429/00/atmos/pgrb2ap5/gep01.t00z.pgrb2a.0p50.f114
# https://noaa-gefs-pds.s3.amazonaws.com/gefs.20220429/00/atmos/pgrb2bp5/gep01.t00z.pgrb2b.0p50.f114

set -x

# Jet:
#datadir=/lfs4/BMC/wrfruc/RRFS_RETRO_DATA/GEFS
datadir=/lfs5/BMC/wrfruc/Chunhua.Zhou/w4/data/GEFS
# Hera:
#datadir=/scratch2/BMC/zrtrr/RRFS_RETRO_DATA/GEFS

waittime=30
maxtries=10
merge=false  # true

#for dates in 202307{28..31} 202308{01..07} 202308{25..31}
for dates in 20240525
do
  for hh in 12
  do
    awsdir="https://noaa-gefs-pds.s3.amazonaws.com/gefs.${yyyymmdd}/${hh}/atmos"
    for mems in {01..30}
    do
      mem=gep$( printf "%02d" $mems )

      if [[ ${merge} == true ]]; then
        mkdir -p ${datadir}/$mem
      fi

      for fcsthr in {00..45..03}
        do
        fhr=$( printf "%03d" $fcsthr )

        yyyymmdd=$dates
        yy="${yyyymmdd:2:2}"
        yyyy="${yyyymmdd:0:4}"
        mm="${yyyymmdd:4:2}"
        dd="${yyyymmdd:6:2}"
        doy=`date  --date=$yyyymmdd +%j `

        echo "processing member $mem for $yyyymmdd $hh"
        a_dir=$datadir/gefs.${dates}/${hh}/pgrb2ap5
        if [ ! -d ${a_dir} ]; then
          mkdir -p ${a_dir}
        fi
        b_dir=$datadir/gefs.${dates}/${hh}/pgrb2bp5
        if [ ! -d ${b_dir} ]; then
          mkdir -p ${b_dir}
        fi

        awsfile_a="${awsdir}/pgrb2ap5/${mem}.t${hh}z.pgrb2a.0p50.f${fhr}"
        cd ${a_dir}
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

        awsfile_b="${awsdir}/pgrb2bp5/${mem}.t${hh}z.pgrb2b.0p50.f${fhr}"
        cd ${b_dir}
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
 
        if [[ ${merge} == true ]]; then
          localfile=${datadir}/$mem/${yy}${doy}${hh}000${fhr}
          if [ -s ${a_dir}/${localfile_a} ] && [ -s ${b_dir}/${localfile_b} ]; then
             cat ${a_dir}/${localfile_a} ${b_dir}/${localfile_b} > ${localfile}
          fi
        fi

      done   # fcsthr
    done  # mems
  done  # hh
done  # dates
