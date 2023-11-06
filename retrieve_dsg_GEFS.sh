#!/bin/ksh
#####################################################
# machine set up (users should change this part)
#####################################################

# For Hera, Jet, Orion
#SBATCH --time=23:30:00
#SBATCH --qos=batch
#SBATCH --partition=service
#SBATCH --ntasks=1
#SBATCH --account=zrtrr
#SBATCH --job-name=retrieve_dsg_gefs
#SBATCH --output=./retrieve_dsg_gefs.log

# For WCOSS2
#PBS -A RRFS-DEV
#PBS -q dev_transfer
#PBS -l select=1:ncpus=1:mem=2G
#PBS -l walltime=06:00:00
#PBS -N retrieve_dsg_gefs
#PBS -j oe -o log.retrieve_dsg_gefs

set -x

module load hpss

# /BMC/fdr/Permanent/2021/03/25/grib/gens_pgrb2b/gep01/7/2/107/0_259920_0/: 202103251200.zip   202103251800.zip 

sourcedir1=/BMC/fdr/Permanent/
sourcedir2=/grib/gens_pgrb2b
sourcedir3=/7/2/107/0_259920_0/
#stagedir=/mnt/lfs4/HFIP/gsihyb/Chunhua.Zhou/data/GEFS/public/pgrb2.merged
stagedir=/scratch1/BMC/wrfruc/chunhua/data/GEFS

#yyyymmddhh=` date '+%Y%m%d%H' -d "-4 hours"  `
for yyyymmdd in  20220208 20220209 20220210 20220211 20220212 20220213 ; do

  yyyy="${yyyymmdd:0:4}"
  yy="${yyyymmdd:2:2}"
  mm="${yyyymmdd:4:2}"
  dd="${yyyymmdd:6:2}"
  doy=`date  --date=$yyyymmdd +%j `

  for mem in $(seq -w 1 30);  do
    mkdir -p $stagedir/gep${mem}
    cd $stagedir/gep${mem}
    for hh in $(seq -w 0 6 18) ; do
      if [ ! -s $stagedir/gep${mem}/${yy}${doy}${hh}000000 ] ; then
        echo hsi get  "$sourcedir1/$yyyy/$mm/$dd/$sourcedir2/gep${mem}/$sourcedir3/${yyyymmdd}${hh}00.zip"
        hsi get  $sourcedir1/$yyyy/$mm/$dd/$sourcedir2/gep${mem}/$sourcedir3/${yyyymmdd}${hh}00.zip
        if [ $? -ne 0 ]; then
          exit 999
        fi
        echo y | unzip -o ${yyyymmdd}${hh}00.zip
        rm -f ${yyyymmdd}${hh}00.zip
        rm -f ${yy}${doy}${hh}0003??  ${yy}${doy}${hh}0002??  ${yy}${doy}${hh}0001?? 
      fi
    done
  done

done

#
