#!/bin/bash
#####################################################################################
#  The script corrects the precipitation data by applying a new mask and            #
#  recalulating the field means over the PRUDENCE regions for precipitation.        #   
#  Written 7/16/15  by Katie Osterried                                              #
#####################################################################################

# First, I define a function, correct_prec, to do the correction. 
correct_prec () {

# First, test the code by printing the path name
#echo "$1"
#return
# Link the CDO mask file

ln -s /users/ksilver/calibration/output/mask/masks_044_cdo.nc .

# Delete the incorrect precipitation files

rm rr_mod_1.nc rr_mod_2.nc rr_mod_3.nc rr_mod_4.nc rr_mod_5.nc rr_mod_6.nc
rm rr_mod_7.nc rr_mod_8.nc

mv mod_1.nc mod_1_wrong.nc
mv mod_2.nc mod_2_wrong.nc
mv mod_3.nc mod_3_wrong.nc
mv mod_4.nc mod_4_wrong.nc
mv mod_5.nc mod_5_wrong.nc
mv mod_6.nc mod_6_wrong.nc
mv mod_7.nc mod_7_wrong.nc
mv mod_8.nc mod_8_wrong.nc

# Apply the CDO masks for precipitation
cdo fldmean -ifthen -selname,MASK_BI masks_044_cdo.nc rr_mod_mm.nc rr_mod_1.nc
cdo fldmean -ifthen -selname,MASK_IP masks_044_cdo.nc rr_mod_mm.nc rr_mod_2.nc
cdo fldmean -ifthen -selname,MASK_FR masks_044_cdo.nc rr_mod_mm.nc rr_mod_3.nc
cdo fldmean -ifthen -selname,MASK_ME masks_044_cdo.nc rr_mod_mm.nc rr_mod_4.nc
cdo fldmean -ifthen -selname,MASK_SC masks_044_cdo.nc rr_mod_mm.nc rr_mod_5.nc
cdo fldmean -ifthen -selname,MASK_AL masks_044_cdo.nc rr_mod_mm.nc rr_mod_6.nc
cdo fldmean -ifthen -selname,MASK_MD masks_044_cdo.nc rr_mod_mm.nc rr_mod_7.nc
cdo fldmean -ifthen -selname,MASK_EA masks_044_cdo.nc rr_mod_mm.nc rr_mod_8.nc

# Replace the precipitation value in the mod_ files with the correct value

cdo replace mod_1_wrong.nc rr_mod_1.nc mod_1.nc
cdo replace mod_2_wrong.nc rr_mod_2.nc mod_2.nc
cdo replace mod_3_wrong.nc rr_mod_3.nc mod_3.nc
cdo replace mod_4_wrong.nc rr_mod_4.nc mod_4.nc
cdo replace mod_5_wrong.nc rr_mod_5.nc mod_5.nc
cdo replace mod_6_wrong.nc rr_mod_6.nc mod_6.nc
cdo replace mod_7_wrong.nc rr_mod_7.nc mod_7.nc
cdo replace mod_8_wrong.nc rr_mod_8.nc mod_8.nc

# Copy the new file to /project/ch4/...

rsync -av mod_1.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_2.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_3.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_4.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_5.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_6.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_7.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.
rsync -av mod_8.nc /project/ch4/ksilver/cosmo5_calibration/output/"$1"/post_process/.

# Delete the wrong files

#rm *_wrong.nc

}

# Now, write the code to call the function

# First, the reference run

#cd /scratch/pilatus/ksilver/calibration/reference

#correct_prec reference

######################################################
# Next, the one parameter runs:


# Set some variables
min='n'
max='x'

for param in rl e q u f t ra s
do

cd /scratch/pilatus/ksilver/calibration/$param$min

correct_prec $param$min

cd /scratch/pilatus/ksilver/calibration/$param$max

correct_prec $param$max

done

######################################################

i1='1'
for param1 in rl e q u f t ra s
  do
  i2='1'
  for param2 in rl e q u f t ra s
    do
    if [ "$i1" -lt "$i2" ]
      then

        val1=$param1$min
        val2=$param2$min

        cd /scratch/pilatus/ksilver/calibration/${val1}_${val2}

        correct_prec ${val1}_${val2}

        val1=$param1$min
        val2=$param2$max
        cd /scratch/pilatus/ksilver/calibration/${val1}_${val2}

        correct_prec ${val1}_${val2}

        val1=$param1$max
        val2=$param2$min
        cd /scratch/pilatus/ksilver/calibration/${val1}_${val2}

        correct_prec ${val1}_${val2}

        val1=$param1$max
        val2=$param2$max

        cd /scratch/pilatus/ksilver/calibration/${val1}_${val2}

        correct_prec ${val1}_${val2}

     fi
    i2=$(($i2+1))
  done
  i1=$(($i1+1))
done





