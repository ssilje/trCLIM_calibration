#!/bin/bash
#####################################################################################
#  The script reads in the output from the model runs and processes the             #
#  output data in the same way as the observational data                            #   
#  Written 4/9/15 by Katie Osterried                                                #
#####################################################################################

#SBATCH --account=pr04
#SBATCH --nodes=1
#SBATCH --constraint=gpu
#SBATCH --time=23:59:00
#SBATCH --output=log/getdata-calibration_2000-2009.out
#SBATCH --error=log/getdata-calibration_2000-2009.err
#SBATCH --job-name="getcali_2000-2009"

###################################################################################
# The function process_mod does the same post-processing steps on all of the runs #
###################################################################################

# Beginning of function process_mod

process_mod ()
{
## SET THE DIRECTORIES ##

data_dir=/scratch/snx3000/ssilje/COSMO-crCLIM_calibration/output
workdir=/scratch/snx3000/ssilje/output_2000-2009/
savedir=/scratch/snx3000/ssilje/DATA_CALIBRATION/data_2000-2009_new


# First, 2m temperature and CLCT
cd "$1"
# Loop over the years 
for ii in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
#for ii in   2005 2006 2007 2008 2009
do
starttime=$(date +"%s")
echo "Beginning block 1 of 2 in $ii"
out01=${data_dir}/"$1"/"$1"_out01_"$ii".tar
echo ${out01}
tar -xf ${data_dir}/"$1"/"$1"_out01_"$ii".tar --strip-components=6 

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
rm -rf out01 
endtime=$(date +"%s")
diff=$(($endtime-$starttime))
echo "Finished with block 1 of 2 in $ii, time elapsed was: $(($diff/60)) minutes and $(($diff % 60)) seconds"
#########################################################################
# Now for TOTAL_PREC (aka rr)
out02=${data_dir}/"$1"/"$1"_out02_"$ii".tar
echo ${out02}
tar -xf ${data_dir}/"$1"/"$1"_out02_"$ii".tar --strip-components=6

starttime=$(date +"%s")
echo "Beginning block 2 of 2 in $ii"
# Unpack the data
#tar -xf $1_out02_"$ii".tar
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

# Remove the folder
rm -rf out02 
endtime=$(date +"%s")
diff=$(($endtime-$starttime))
echo "Finished with block 2 of 2 in $ii, time elapsed was: $(($diff/60)) minutes and $(($diff % 60)) seconds"
done

# Next, cat all the files into one time series
cdo cat 200*_mm_CLCT.nc clct_mod_mm.nc
cdo cat 200*_mm_T_2M.nc t2m_mod_mm.nc
cdo cat tot_prec_200*_mm.nc rr_mod_mm.nc

# Remove the yearly files
rm 200*mm* tot_prec*

#################################################################################################
# Now, calculate the mean over the PRUDENCE regions, after masking out the ocean values

# Copy over the masks file
cp /users/ksilver/calibration/output/mask/masks_044.nc .

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

cd ..

# Move data to /projects                                                                                                                       
if [ ! -d ${savedir}/"$1" ]; then
    mkdir ${savedir}/"$1"
else
    rm -r ${savedir}/"$1"
    mkdir -p ${savedir}/"$1"

fi


# Move data to /projects
#mkdir -p ${savedir}/"$1"
rsync -auv ${workdir}/"$1"/*mod*_?.nc ${savedir}/"$1"

}
# End of function process_mod

################################################################################################
# This is the main part of the script that calls the function process_mod for all of the runs. #
################################################################################################

# Load the CDO module

module load daint-gpu
module load NCO CDO


data_dir=/scratch/snx3000/ssilje/COSMO-crCLIM_calibration/output
workdir=/scratch/snx3000/ssilje/output_2000-2009/
savedir=/scratch/snx3000/ssilje/DATA_CALIBRATION/data_2000-2009_new


# Call the function for the reference run

echo "Beginning with the reference run"
if [ -e $savedir/reference/clct_mod_8.nc ] && [ -e $savedir/reference/rr_mod_8.nc ] && [ -e $savedir/reference/t2m_mod_8.nc ]; then
    echo " reference "
    echo " already done postprocessed "
else
    cd ${workdir}
    if [ ! -d reference ]; then
	mkdir reference
    fi
    process_mod reference
    echo "Finished with the reference run"
fi



# Now for the one parameter runs

min='n'
max='x'

for param in l f ra rl tk tu u v
do
    
    
    # First the minimum
    
    echo "the minimum run"
    if [ -e $savedir/${param}${min}/clct_mod_8.nc ] && [ -e $savedir/${param}${min}/rr_mod_8.nc ] && [ -e $savedir/${param}${min}/t2m_mod_8.nc ]; then
	echo ${param}${min}
	echo " already done postprocessed "
    else
	cd ${workdir}
	if [ ! -d ${param}${min} ]; then
	    mkdir ${param}${min}
	else
	    rm -r${param}${min}
	    mkdir ${param}${min}
	fi
	process_mod ${param}${min}
	echo "Finished with the ${param}${min} run"
    fi
    
    
    # Then the maximum
    
    echo "the maximum run"
    if [ -e $savedir/${param}${max}/clct_mod_8.nc ] && [ -e $savedir/${param}${max}/rr_mod_8.nc ] && [ -e $savedir/${param}${max}/t2m_mod_8.nc ]; then
	echo ${param}${max}
	echo " already done postprocessed "
    else
	cd ${workdir}
	if [ ! -d ${param}${max} ]; then
	    mkdir ${param}${max}
	else
	    rm- r ${param}${max}
	    mkdir ${param}${max}
	fi
	process_mod ${param}${max}
	echo "Finished with the ${param}${max} run"
    fi
done
    
    # Now for the two parameter runs
    


i1='1'
for param1 in rl v tk u ra f l tu
do
    i2='1'
    for param2 in rl v tk u ra f l tu
    do
	if [ "$i1" -lt "$i2" ]
	then
	    # Both parameters minimum
	    val1=$param1$min
	    val2=$param2$min
	    
	    echo "Both parameters minimum"
	    if [ -e $savedir/${val1}_${val2}/clct_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/rr_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/t2m_mod_8.nc ]; then
		echo ${val1}_${val2}
		echo " already done postprocessed "
	    else
		cd ${workdir}
		if [ ! -d ${val1}_${val2} ]; then
		    mkdir ${val1}_${val2}
		else
		    rm -r ${val1}_${val2}
		    mkdir ${val1}_${val2}
		fi
		process_mod ${val1}_${val2}
		echo "Finished with the ${val1}_${val2} run"
	    fi
	    
	    
	    
	    # param1 min and param2 max
	    val1=$param1$min
	    val2=$param2$max
	    echo "Beginning with the ${val1}_${val2} run"
	    if [ -e $savedir/${val1}_${val2}/clct_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/rr_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/t2m_mod_8.nc ]; then
		echo ${val1}_${val2}
		echo " already done postprocessed "
	    else
		cd ${workdir}
		if [ ! -d ${val1}_${val2} ]; then
		    mkdir ${val1}_${val2}
		else
                    rm -r ${val1}_${val2}
                    mkdir ${val1}_${val2}
		fi
		process_mod ${val1}_${val2}
		echo "Finished with the ${val1}_${val2} run"
	    fi
	    
	    
	    
	    
	    # param1 max and param2 min
	    val1=$param1$max
	    val2=$param2$min
	    
	    echo "Beginning with the ${val1}_${val2} run"
	    if [ -e $savedir/${val1}_${val2}/clct_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/rr_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/t2m_mod_8.nc ]; then
		echo ${val1}_${val2}
		echo " already done postprocessed "
	    else
		cd ${workdir}
		if [ ! -d ${val1}_${val2} ]; then
		    mkdir ${val1}_${val2}
		else
                    rm -r ${val1}_${val2}
                    mkdir ${val1}_${val2}
		fi
		process_mod ${val1}_${val2}
		echo "Finished with the ${val1}_${val2} run"
	    fi
	    
	    
	    
	    
	    # Both parameters maximum
	    val1=$param1$max
	    val2=$param2$max
	    echo "Beginning with the ${val1}_${val2} run"
	    if [ -e $savedir/${val1}_${val2}/clct_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/rr_mod_8.nc ] && [ -e $savedir/${val1}_${val2}/t2m_mod_8.nc ]; then
		echo ${val1}_${val2}
		echo " already done postprocessed "
	    else
		cd ${workdir}
		if [ ! -d ${val1}_${val2} ]; then
		    mkdir ${val1}_${val2}
		else
                    rm -r ${val1}_${val2}
                    mkdir ${val1}_${val2}
		fi
		process_mod ${val1}_${val2}
		echo "Finished with the ${val1}_${val2} run"
	    fi
	    
	    
	    
	fi
	
	i2=$(($i2+1))
    done
    i1=$(($i1+1))
done
