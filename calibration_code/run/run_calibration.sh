#!/bin/bash

##############################################################################
# This script (run_calibration.sh) submits all of the Slurm scripts for the  #
# 129 calibration runs.                                                      #
# Written 4/27/15 by Katie Osterried           
# Modified 23/07/2018 by Silje Soerland                                      #
##############################################################################


check_jobs ()
{
run_dir='/scratch/snx3000/ssilje/COSMO-crCLIM_calibration/'
save_dir='/project/pr04/ssilje/COSMO-crCLIM_calibration/output/'

if [ -e $run_dir/$1/YUSPECIF ]
then
    echo "#######################"
    echo "                       "
    echo "SIMULATION ongoing - exit"
    echo "                       "
    echo "#######################"
else

    if [ -e $save_dir/$1/$1_out02_2010.tar ]
    then
	echo "#######################"
	echo "                       "
	echo "SIMULATION COMPLEATED and all files tar-ed!"
	echo "                       "
	echo "#######################"
	if [ -d $run_dir/$1 ]
	then
	    rm -r  $run_dir/$1 
	fi
    else
	cd $run_dir/$1
	pwd

	echo "                       "
	echo "No tar-files in save dir"
	echo "Checking the run_dir..."
	echo "                       "
	echo "                       "

	
	if [  -e $run_dir/$1/output/out02/lffd2010010100.nc ]
	then
	    echo "#######################"
	    echo "                       "
	    echo "simulation is compleated - submitting tar-script"
	    echo "                       "
	    echo "#######################"
	    sbatch calibration.tar
	elif  [  -e $run_dir/$1/restart/lrfd2005010100o ]
	then
	    echo "#######################"
	    echo "                       "
	    echo "restart file exist - submitting job_restart.sh"
	    echo "                       "
	    echo "#######################"
	    sbatch job_restart.sh
	    if [ $? -ne 0 ]
	    then 
		echo "ERROR restart not submitted" 
	    else
		
		echo "SUCCESS restart submitted!!" 
	    fi
	else
	    
	    echo "#######################"
	    echo "                       "
	    echo "no restart file exist - submitting job_init.sh"
	    echo "                       "
	    echo "#######################"
	    
	    sbatch job_init.sh    
	    if [ $? -ne 0 ] 
	    then 
		echo "ERROR not submitted" 
	    else
		echo "SUCCESS submitted!!" 
	    fi
	fi
    fi
fi
} #end function check_jobs




# First, run the reference 
echo "#######################"
echo "                       "
echo " Reference"
echo "                       "
echo "#######################"
check_jobs reference


# Next, the one parameter runs

min='n'
max='x'

for param in rl v tk u ra f l tu 

do
    
    # First the minimum
    echo "#######################"
    echo "                       "
    echo " the minimum           "
    echo "                       "
    echo "#######################"
    
    echo "                       "
    echo ${param}${min}
    echo "                       "
    check_jobs ${param}${min}

    
    # Then the maximum
    echo "#######################"
    echo "                       "
    echo " the maximum"
    echo "                       "
    echo "#######################"
    echo "                       "
    echo ${param}${max}
    echo "                       "
    check_jobs ${param}${max}
    
done



# Finally, the two parameter runs
i1='1'
for param1 in rl v tk u ra f l tu

do
    i2='1'
    for param2 in rl v tk u ra f l tu
    
    do
	if [ "$i1" -lt "$i2" ]
	then
	    echo "#######################"
	    echo "                       "
	    echo " Both parameters minimum"
	    echo "                       "
	    echo "#######################"
	    # Both parameters minimum
	    val1=$param1$min
	    val2=$param2$min
	    echo "                       "
	    echo ${val1}_${val2}
	    echo "                       "
	    check_jobs ${val1}_${val2}
	   
	    echo "########################"
	    echo "                        "
	    echo "param1 min and param2 max"
	    echo "                       "
	    echo "########################"
	    
	    # param1 min and param2 max
	    val1=$param1$min
	    val2=$param2$max
	    echo "      "
	    echo ${val1}_${val2}
	    echo "                       "
	    check_jobs ${val1}_${val2}


	    echo "########################"
	    echo "                        "
	    echo "param1 max and param2 min"
	    echo "                       "
	    echo "########################"
	    
	    
	    val1=$param1$max
	    val2=$param2$min
	    echo "                       "
	    echo ${val1}_${val2}
	    echo "                       "
	    check_jobs ${val1}_${val2}

	    
	    echo "########################"
	    echo "                        "
	    echo "Both parameters maximum"
	    echo "                       "
	    echo "########################"
	 
	    # Both parameters maximum
	    val1=$param1$max
	    val2=$param2$max
	    echo "                       "
	    echo ${val1}_${val2}
	    echo "                       "
	    check_jobs ${val1}_${val2}

	    
	fi
	
	i2=$(($i2+1))
    done
    i1=$(($i1+1))
done
