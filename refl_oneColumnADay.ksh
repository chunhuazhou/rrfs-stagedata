#!/bin/ksh --login
#####################################################
# machine set up (users should change this part)
#####################################################

#SBATCH --account=zrtrr
#SBATCH --qos=batch
#SBATCH --ntasks=1
#SBATCH --partition=service
#SBATCH --time=23:30:00
#SBATCH --job-name=get_reflObs
#SBATCH -o log.reflObs


#--------------#
# reflectivity
#--------------# 

refl_dir=/scratch2/BMC/zrtrr/rli/data/reflectivity
mrms="MergedReflectivityQC"
obs_appendix="grib2.gz"
yy=2024
mm=05

mkdir -p tmp
cd tmp

for dd in $(seq -w 22 2 24); do

 # 2020-Jun. 2022
 #htar -xvf /NCEPPROD/hpssprod/runhistory/rh${yy}/${yy}${mm}/${yy}${mm}${dd}/dcom_prod_ldmdata_obs.tar ./upperair/mrms/conus/MergedReflectivityQC/MergedReflectivityQC_*_${yy}${mm}${dd}-*.grib2.gz

 # start from Jul. 2022, tar file name changed
 htar -xvf /NCEPPROD/hpssprod/runhistory/rh${yy}/${yy}${mm}/${yy}${mm}${dd}/dcom_ldmdata_obs.tar ./upperair/mrms/conus/MergedReflectivityQC/MergedReflectivityQC_*_${yy}${mm}${dd}-*.grib2.gz

 cd upperair/mrms/conus/MergedReflectivityQC

 for hh in $(seq -w 00 23); do
   for min in 00 15 30 45; do
     min1=$((min + 0))
     min2=$((min + 4))
     found=false
     #echo "Minutes range: " ${min1} '-' ${min2}

     # find a column between min1-min2 and exit, go to next min
     while [[ $min1 -le min2 ]]; do 
       min3=$(printf %2.2i ${min1})
       s=0
       while [[ $s -le 59 ]]; do
         ss=$(printf %2.2i ${s})
         nsslfile=*${mrms}_00.50_${yy}${mm}${dd}-${hh}${min3}${ss}.${obs_appendix}
         if [ -s $nsslfile ]; then
           echo "Found file: "${yy}"-"${mm}"-"${dd}" "${hh}":"${min3} " " ${nsslfile}
           nsslfile1=*${mrms}_*_${yy}${mm}${dd}-${hh}${min3}*.${obs_appendix}
           numgrib2=$(ls ${nsslfile1} | wc -l)
           if [ ${numgrib2} -ge 10 ]; then
	     for file in `ls ${nsslfile1}`; do
               gzip -d ${file}
             done
             echo 'Found the column and unzip it: number of files: '${numgrib2}
	     echo " "
	     found=true
	     break
           fi
         fi
         ((s+=1))
       done

       if [[ "$found" == true ]]; then
	 break
       fi

       ((min1+=1))

     done #while [[ $min1 -le min2 ]]

   done

   nsslfile2=*${mrms}_*_${yy}${mm}${dd}-${hh}*.grib2
   numgrib2_1=$(ls ${nsslfile2} | wc -l)
   echo "Number of grib2 files for " ${yy}"-"${mm}"-"${dd}" "${hh}"Z " ${numgrib2_1}
   mv ${nsslfile2} ${refl_dir}
   echo " "
 done

 rm * 

 # return to tmp directory
 cd ../../../../

done


