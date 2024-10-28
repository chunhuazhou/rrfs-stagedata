#!/bin/sh
#####################################################
# machine set up (users should change this part)
#####################################################

# For Hera, Jet, Orion
#SBATCH --account=nrtrr
#SBATCH --qos=batch
#SBATCH --ntasks=1
#SBATCH --partition=service   ## maxium 23:30 hours
#SBATCH --time=23:00:00
#SBATCH --job-name=get_rrfs
#SBATCH -o log.rrfs

set -ax

module load hpss

datadir=/lfs5/BMC/wrfruc/Chunhua.Zhou/w4/data/RRFS

# /5year/NCEPDEV/emc-meso/emc.lam/5year/rh2024/202401/20240116/lfs_h2_emc_stmp_emc.lam_rrfs.2024011600.natlev.tar
# ./runhistory_retro/20240116/00/rrfs.t00z.natlev.f060.grib2

for dates in 20240116; do
  hpsspath=/5year/NCEPDEV/emc-meso/emc.lam/5year/rh${dates:0:4}/${dates:0:6}/${dates}
  for hh in 00 06 12 18 ; do
    tarfile=lfs_h2_emc_stmp_emc.lam_rrfs.${dates}${hh}.natlev.tar
    mkdir -p $datadir/RRFS/rrfs_a.${dates}/${hh}
    cd $datadir/RRFS/rrfs_a.${dates}/${hh}
    filelist=''
    for fcsthrs in $(seq -w 00 48 ); do
      localfile=./runhistory_retro/${dates}/${hh}/rrfs.t${hh}z.natlev.f0${fcsthrs}.grib2
      ln -sf ${localfile} ./rrfs.t${hh}z.natlev.f0${fcsthrs}.grib2
      filelist=" ${filelist} ${localfile} "
    done
    echo " filelist = ${filelist} "
    if [[ -n "${filelist// /}" ]]; then
       htar -xvf ${hpsspath}/$tarfile $filelist
    fi
  done
done
