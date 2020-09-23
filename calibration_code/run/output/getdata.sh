#!/bin/bash
#####################################################################################
#  The script reads in the output from the model runs and processes the             #
#  output data in the same way as the observational data                            #   
#  Written 4/9/15 by Katie Osterried                                                #
#####################################################################################

#SBATCH --job-name="process_calib"
#SBATCH --account=ch4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=process_output.txt
#SBATCH --error=process_error.txt
#SBATCH --partition=long
#SBATCH --time=40:00:00

###################################################################################
# The function process_mod does the same post-processing steps on all of the runs #
###################################################################################

# Beginning of function process_mod

process_mod ()
{
# First, 2m temperature and CLCT
mkdir "$1"
cd "$1"
# Loop over the years 
for ii in 1994 1995 1996 1997 1998
do
starttime=$(date +"%s")
echo "Beginning block 1 of 2 in $ii"
cp /project/ch4/ksilver/cosmo5_calibration/output/"$1"/"$1"_out01_"$ii".tar .

# Unpack the data
tar -xf "$1"_out01_"$ii".tar
cd out01
# Select the 2m temperature and the total cloud cover
for f in *.nc
do
cdo -s selname,T_2M,CLCT "$f" "t2mclct_$f"
done

rm lff*
# Put all the files in one file and take a monthly mean
cdo cat *.nc t2mclct_"$ii".nc
cdo monmean t2mclct_"$ii".nc t2mclct_"$ii"_mm.nc

rm t2mclct_lff* t2mclct_"$ii".nc

cd ..
# Split the 2 variables and put them in the outer directory
cdo splitname ./out01/t2mclct_"$ii"_mm.nc "$ii"_mm_
# Remove the folder
rm -rf out01 "$1"_out01*
endtime=$(date +"%s")
diff=$(($endtime-$starttime))
echo "Finished with block 1 of 2 in $ii, time elapsed was: $(($diff/60)) minutes and $(($diff % 60)) seconds"
#########################################################################
# Now for TOTAL_PREC (aka rr)

cp /project/ch4/ksilver/cosmo5_calibration/output/"$1"/"$1"_out02_"$ii".tar .
starttime=$(date +"%s")
echo "Beginning block 2 of 2 in $ii"
# Unpack the data
tar -xf $1_out02_"$ii".tar
cd out02
# Select the total precipitation
for f in *.nc
do
cdo -s selname,TOT_PREC "$f" "tot_prec_$f"
done

# Put all the files in one file and take a monthly mean
cdo cat tot_prec_lff* tot_prec_"$ii".nc
cdo monmean tot_prec_"$ii".nc tot_prec_"$ii"_mm.nc

rm tot_prec_lff*

cd ..

# Move the file up one folder
cp ./out02/tot_prec_"$ii"_mm.nc .

#########################################################################
# Now for DTR
cd out02

rm tot_prec*
# Select the min and max 2M temperature and take the difference to get DTR
for f in lffd*
do
cdo -s selname,TMIN_2M,TMAX_2M "$f" ts_"$f"
cdo -s splitname ts_"$f" "$f"_
cdo -s sub "$f"_TMAX_2M.nc "$f"_TMIN_2M.nc dtr_"$f"
rm "$f"_TMAX_2M.nc "$f"_TMIN_2M.nc ts_"$f"
done

rm lff*
# Put all the files in one file and take a monthly mean
cdo cat *.nc dtr_"$ii".nc
cdo monmean dtr_"$ii".nc dtr_"$ii"_mm.nc

cd ..

# Move the file up one folder
cp ./out02/dtr_"$ii"_mm.nc .

# Remove the folder
rm -rf out02 "$1"_out02*
endtime=$(date +"%s")
diff=$(($endtime-$starttime))
echo "Finished with block 2 of 2 in $ii, time elapsed was: $(($diff/60)) minutes and $(($diff % 60)) seconds"
done

# Next, cat all the files into one time series
cdo cat 1994_mm_CLCT.nc 1995_mm_CLCT.nc 1996_mm_CLCT.nc 1997_mm_CLCT.nc 1998_mm_CLCT.nc clct_mod_mm.nc
cdo cat 1994_mm_T_2M.nc 1995_mm_T_2M.nc 1996_mm_T_2M.nc 1997_mm_T_2M.nc 1998_mm_T_2M.nc t2m_mod_mm.nc
cdo cat tot_prec_1994_mm.nc tot_prec_1995_mm.nc tot_prec_1996_mm.nc tot_prec_1997_mm.nc tot_prec_1998_mm.nc rr_mod_mm.nc
cdo cat dtr_1994_mm.nc dtr_1995_mm.nc dtr_1996_mm.nc dtr_1997_mm.nc dtr_1998_mm.nc dtr_mod_mm.nc

# Remove the yearly files
rm 19* dtr_19* tot_prec_19*
#################################################################################################
# Now, calculate the mean over the PRUDENCE regions, after masking out the ocean values

# Copy over the masks file
cp ~/calibration/output/mask/masks_044.nc .

# First, apply the mask
# Next, change the zeros to missing values
# Select the region
# Take the field mean

# 2M temperature
cdo -s fldmean -sellonlatbox,-10,2,50,59 -setctomiss,0 -mul -selname,MASK_BI masks_044.nc t2m_mod_mm.nc t2m_mod_1.nc
cdo -s fldmean -sellonlatbox,-10,3,36,44 -setctomiss,0 -mul -selname,MASK_IP masks_044.nc t2m_mod_mm.nc t2m_mod_2.nc
cdo -s fldmean -sellonlatbox,-5,5,44,50 -setctomiss,0 -mul -selname,MASK_FR masks_044.nc t2m_mod_mm.nc t2m_mod_3.nc
cdo -s fldmean -sellonlatbox,2,16,48,55 -setctomiss,0 -mul -selname,MASK_ME masks_044.nc t2m_mod_mm.nc t2m_mod_4.nc
cdo -s fldmean -sellonlatbox,5,30,55,70 -setctomiss,0 -mul -selname,MASK_SC masks_044.nc t2m_mod_mm.nc t2m_mod_5.nc
cdo -s fldmean -sellonlatbox,5,15,44,48 -setctomiss,0 -mul -selname,MASK_AL masks_044.nc t2m_mod_mm.nc t2m_mod_6.nc
cdo -s fldmean -sellonlatbox,3,25,36,44 -setctomiss,0 -mul -selname,MASK_MD masks_044.nc t2m_mod_mm.nc t2m_mod_7.nc
cdo -s fldmean -sellonlatbox,16,30,44,55 -setctomiss,0 -mul -selname,MASK_EA masks_044.nc t2m_mod_mm.nc t2m_mod_8.nc

#CLCT
cdo -s fldmean -sellonlatbox,-10,2,50,59 -setctomiss,0 -mul -selname,MASK_BI masks_044.nc clct_mod_mm.nc clct_mod_1.nc
cdo -s fldmean -sellonlatbox,-10,3,36,44 -setctomiss,0 -mul -selname,MASK_IP masks_044.nc clct_mod_mm.nc clct_mod_2.nc
cdo -s fldmean -sellonlatbox,-5,5,44,50 -setctomiss,0 -mul -selname,MASK_FR masks_044.nc clct_mod_mm.nc clct_mod_3.nc
cdo -s fldmean -sellonlatbox,2,16,48,55 -setctomiss,0 -mul -selname,MASK_ME masks_044.nc clct_mod_mm.nc clct_mod_4.nc
cdo -s fldmean -sellonlatbox,5,30,55,70 -setctomiss,0 -mul -selname,MASK_SC masks_044.nc clct_mod_mm.nc clct_mod_5.nc
cdo -s fldmean -sellonlatbox,5,15,44,48 -setctomiss,0 -mul -selname,MASK_AL masks_044.nc clct_mod_mm.nc clct_mod_6.nc
cdo -s fldmean -sellonlatbox,3,25,36,44 -setctomiss,0 -mul -selname,MASK_MD masks_044.nc clct_mod_mm.nc clct_mod_7.nc
cdo -s fldmean -sellonlatbox,16,30,44,55 -setctomiss,0 -mul -selname,MASK_EA masks_044.nc clct_mod_mm.nc clct_mod_8.nc

# Total precipitation
cdo -s fldmean -sellonlatbox,-10,2,50,59 -setctomiss,0 -mul -selname,MASK_BI masks_044.nc rr_mod_mm.nc rr_mod_1.nc
cdo -s fldmean -sellonlatbox,-10,3,36,44 -setctomiss,0 -mul -selname,MASK_IP masks_044.nc rr_mod_mm.nc rr_mod_2.nc
cdo -s fldmean -sellonlatbox,-5,5,44,50 -setctomiss,0 -mul -selname,MASK_FR masks_044.nc rr_mod_mm.nc rr_mod_3.nc
cdo -s fldmean -sellonlatbox,2,16,48,55 -setctomiss,0 -mul -selname,MASK_ME masks_044.nc rr_mod_mm.nc rr_mod_4.nc
cdo -s fldmean -sellonlatbox,5,30,55,70 -setctomiss,0 -mul -selname,MASK_SC masks_044.nc rr_mod_mm.nc rr_mod_5.nc
cdo -s fldmean -sellonlatbox,5,15,44,48 -setctomiss,0 -mul -selname,MASK_AL masks_044.nc rr_mod_mm.nc rr_mod_6.nc
cdo -s fldmean -sellonlatbox,3,25,36,44 -setctomiss,0 -mul -selname,MASK_MD masks_044.nc rr_mod_mm.nc rr_mod_7.nc
cdo -s fldmean -sellonlatbox,16,30,44,55 -setctomiss,0 -mul -selname,MASK_EA masks_044.nc rr_mod_mm.nc rr_mod_8.nc

# DTR
cdo -s fldmean -sellonlatbox,-10,2,50,59 -setctomiss,0 -mul -selname,MASK_BI masks_044.nc dtr_mod_mm.nc dtr_mod_1.nc
cdo -s fldmean -sellonlatbox,-10,3,36,44 -setctomiss,0 -mul -selname,MASK_IP masks_044.nc dtr_mod_mm.nc dtr_mod_2.nc
cdo -s fldmean -sellonlatbox,-5,5,44,50 -setctomiss,0 -mul -selname,MASK_FR masks_044.nc dtr_mod_mm.nc dtr_mod_3.nc
cdo -s fldmean -sellonlatbox,2,16,48,55 -setctomiss,0 -mul -selname,MASK_ME masks_044.nc dtr_mod_mm.nc dtr_mod_4.nc
cdo -s fldmean -sellonlatbox,5,30,55,70 -setctomiss,0 -mul -selname,MASK_SC masks_044.nc dtr_mod_mm.nc dtr_mod_5.nc
cdo -s fldmean -sellonlatbox,5,15,44,48 -setctomiss,0 -mul -selname,MASK_AL masks_044.nc dtr_mod_mm.nc dtr_mod_6.nc
cdo -s fldmean -sellonlatbox,3,25,36,44 -setctomiss,0 -mul -selname,MASK_MD masks_044.nc dtr_mod_mm.nc dtr_mod_7.nc
cdo -s fldmean -sellonlatbox,16,30,44,55 -setctomiss,0 -mul -selname,MASK_EA masks_044.nc dtr_mod_mm.nc dtr_mod_8.nc

cd ..
}
# End of function process_mod

################################################################################################
# This is the main part of the script that calls the function process_mod for all of the runs. #
################################################################################################

# Load the CDO module
module load cdo

# Move onto Pilatus scratch
cd /scratch/pilatus/ksilver

# Call the function for the reference run

echo "Beginning with the reference run"
process_mod reference
echo "Finished with the reference run"
# Now for the one parameter runs

min='n'
max='x'

for param in rl e q u f t ra s
do

# First the minimum
echo "Beginning with the $param$min run"
process_mod $param$min
echo "Finished with the $param$min run"
# Then the maximum
echo "Beginning with the $param$max run"
process_mod $param$max
echo "Finished with the $param$max run"
done

# Now for the two parameter runs

i1='1'
for param1 in rl e q u f t ra s
  do
  i2='1'
  for param2 in rl e q u f t ra s
    do
    if [ "$i1" -lt "$i2" ]
      then
      # Both parameters minimum
      val1=$param1$min
      val2=$param2$min
      echo "Beginning with the ${val1}_${val2} run"
      process_mod ${val1}_${val2}
      echo "Finished with the ${val1}_${val2} run"

      # param1 min and param2 max
      val1=$param1$min
      val2=$param2$max
      echo "Beginning with the ${val1}_${val2} run"
      process_mod ${val1}_${val2}
      echo "Beginning with the ${val1}_${val2} run"

      # param1 max and param2 min
      val1=$param1$max
      val2=$param2$min
      echo "Beginning with the ${val1}_${val2} run"
      process_mod ${val1}_${val2}
      echo "Beginning with the ${val1}_${val2} run"

      # Both parameters maximum
      val1=$param1$max
      val2=$param2$max
      echo "Beginning with the ${val1}_${val2} run"
      process_mod ${val1}_${val2}
      echo "Beginning with the ${val1}_${val2} run"

    fi

    i2=$(($i2+1))
  done
    i1=$(($i1+1))
done





