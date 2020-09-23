#!/bin/bash
#####################################################################################
#  The script reads in the output from the model runs and processes the             #
#  output data in the same way as the observational data                            #   
#  Written 4/9/15 by Katie Osterried                                                #
#####################################################################################

#SBATCH --job-name="calib_reference"
#SBATCH --account=ch4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=reference_out.txt
#SBATCH --error=reference_err.txt
#SBATCH --time=00:35:00


# To run this script, the cdo, PrgEnv-gnu, and 
# nco modules must be loaded!!!

# Loop over the years 
for ii in 1994 1995 1996 1997 1998
do
  
  #########################################
  # First, 2M temperature and cloud cover #
  #########################################

  # Begin the timing for block 1 
  starttime=$(date +"%s")
  echo "Beginning block 1 of 2 in $ii"

  # Copy the output tar file
  cp /project/ch4/ksilver/cosmo5_calibration/output/reference/reference_out01_"$ii".tar .

  # Unpack the data and move into the directory
  tar -xf reference_out01_"$ii".tar
  if [ -d "scratch" ]
  then
  mv scratch/daint/ksilver/calibration/run/reference/output/out01 out01
  rm -rf scratch
  fi
  cd out01

  # Select the 2m temperature and the total cloud cover
  for f in *.nc
  do
  cdo -s selname,T_2M,CLCT "$f" "t2mclct_$f"
  done

  # Remove the original output files
  rm lff*

  # Put all the files in one file and take a monthly mean
  cdo cat *.nc t2mclct_"$ii".nc
  cdo monmean t2mclct_"$ii".nc t2mclct_"$ii"_mm.nc

  # Remove the intermediate files
  rm t2mclct_lff* t2mclct_"$ii".nc
 
  # Move back into the working directory
  cd ..

  # Split the 2 variables and put them in the working directory
  cdo splitname ./out01/t2mclct_"$ii"_mm.nc "$ii"_mm_

  # Remove the output folder and tar file
  rm -rf out01 reference_out01*

  # Finish timing for block 1
  endtime=$(date +"%s")
  diff=$(($endtime-$starttime))
  echo "Finished with block 1 of 2 in $ii, time elapsed was: $(($diff/60)) minutes and $(($diff % 60)) seconds"

  ###############################
  # Now for TOTAL_PREC (aka rr) #
  ###############################

  # Copy the output tar file
  cp /project/ch4/ksilver/cosmo5_calibration/output/reference/reference_out02_"$ii".tar .

  # Start the timing in block 2
  starttime=$(date +"%s")
  echo "Beginning block 2 of 2 in $ii"

  # Unpack the data and move into the directory
  tar -xf reference_out02_"$ii".tar
  if [ -d "scratch" ]
  then
  mv scratch/daint/ksilver/calibration/run/reference/output/out02 out02
  rm -rf scratch
  fi
  cd out02
 
  # Select the total precipitation
  for f in *.nc
  do
  cdo -s selname,TOT_PREC "$f" "tot_prec_$f"
  done

  # Put all the files in one file 
  cdo cat tot_prec_lff* tot_prec_"$ii".nc

  # Remove the intermediate files
  rm tot_prec_lff*
 
  # Move the file up one folder
  cp tot_prec_"$ii".nc ../.

  ###############
  # Now for DTR #
  ###############
  
  # Remove the precipitation files
  rm tot_prec*

  # Select the min and max 2M temperature and take the difference to get DTR
  for f in lffd*
  do
  cdo -s selname,TMIN_2M,TMAX_2M "$f" ts_"$f"
  cdo -s splitname ts_"$f" "$f"_
  cdo -s sub "$f"_TMAX_2M.nc "$f"_TMIN_2M.nc dtr_"$f"
  rm "$f"_TMAX_2M.nc "$f"_TMIN_2M.nc ts_"$f"
  done

  # Remove the original files
  rm lff*

  # Put all the files in one file 
  cdo cat *.nc dtr_"$ii".nc

  # Move into the working directory
  cd ..

  # Move the file up one folder
  cp ./out02/dtr_"$ii".nc .

  # Remove the output folder and tar file
  rm -rf out02 reference_out02*
  endtime=$(date +"%s")
  diff=$(($endtime-$starttime))
  echo "Finished with block 2 of 2 in $ii, time elapsed was: $(($diff/60)) minutes and $(($diff % 60)) seconds"
done

###############################################################
# Cat all the DTR and precipitation files in one time series. #
# Then, shift the time axis and calculate the monthly mean    #
# from the second day in the month to the first day of the    #
# next month.                                                 #
###############################################################

cdo cat dtr_1994.nc dtr_1995.nc dtr_1996.nc dtr_1997.nc dtr_1998.nc dtr_mod.nc
cdo cat tot_prec_1994.nc tot_prec_1995.nc tot_prec_1996.nc tot_prec_1997.nc tot_prec_1998.nc rr_mod.nc

cdo -s monmean -selyear,1994,1995,1996,1997,1998 -shifttime,-1day rr_mod.nc rr_mod_mm.nc

cdo -s monmean -selyear,1994,1995,1996,1997,1998 -shifttime,-1day dtr_mod.nc dtr_mod_mm.nc

##############################################################
# Next, cat all the CLCT and T_2M files into one time series #
##############################################################

cdo cat 1994_mm_CLCT.nc 1995_mm_CLCT.nc 1996_mm_CLCT.nc 1997_mm_CLCT.nc 1998_mm_CLCT.nc clct_mod_mm.nc
cdo cat 1994_mm_T_2M.nc 1995_mm_T_2M.nc 1996_mm_T_2M.nc 1997_mm_T_2M.nc 1998_mm_T_2M.nc t2m_mod_mm.nc

# Remove the yearly files
rm 19* dtr_19* tot_prec_19*

#########################################################################################
# Now, calculate the mean over the PRUDENCE regions, after masking out the ocean values #
#########################################################################################

# Link the masks file
ln -s /users/ksilver/calibration/output/mask/masks_044.nc .

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

#####################################
# Put all the variables in one file #
#####################################

cdo -s merge t2m_mod_1.nc clct_mod_1.nc rr_mod_1.nc dtr_mod_1.nc mod_1.nc
cdo -s merge t2m_mod_2.nc clct_mod_2.nc rr_mod_2.nc dtr_mod_2.nc mod_2.nc
cdo -s merge t2m_mod_3.nc clct_mod_3.nc rr_mod_3.nc dtr_mod_3.nc mod_3.nc
cdo -s merge t2m_mod_4.nc clct_mod_4.nc rr_mod_4.nc dtr_mod_4.nc mod_4.nc
cdo -s merge t2m_mod_5.nc clct_mod_5.nc rr_mod_5.nc dtr_mod_5.nc mod_5.nc
cdo -s merge t2m_mod_6.nc clct_mod_6.nc rr_mod_6.nc dtr_mod_6.nc mod_6.nc
cdo -s merge t2m_mod_7.nc clct_mod_7.nc rr_mod_7.nc dtr_mod_7.nc mod_7.nc
cdo -s merge t2m_mod_8.nc clct_mod_8.nc rr_mod_8.nc dtr_mod_8.nc mod_8.nc


############################################################
# Correct the name of the daily temperature range variable #
############################################################

ncrename -v TMAX_2M,DTR mod_1.nc
ncrename -v TMAX_2M,DTR mod_2.nc
ncrename -v TMAX_2M,DTR mod_3.nc
ncrename -v TMAX_2M,DTR mod_4.nc
ncrename -v TMAX_2M,DTR mod_5.nc
ncrename -v TMAX_2M,DTR mod_6.nc
ncrename -v TMAX_2M,DTR mod_7.nc
ncrename -v TMAX_2M,DTR mod_8.nc

ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_1.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_2.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_3.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_4.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_5.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_6.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_7.nc
ncatted -O -a long_name,DTR,o,c,"daily temperature range" mod_8.nc

#########################################
# Copy the output files back to project #
#########################################

mkdir /project/ch4/ksilver/cosmo5_calibration/output/reference/post_process

rsync -av mod_* /project/ch4/ksilver/cosmo5_calibration/output/reference/post_process/.




