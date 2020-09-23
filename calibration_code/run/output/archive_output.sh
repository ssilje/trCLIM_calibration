#!/bin/bash

################################################################
#  This script tars the output files from the calibration runs.#  
#  The output files are saved in the project file system.      # 
#  Written 6/15/2015 by Katie Osterried.                       #
################################################################
#SBATCH --job-name="arch_calib"
#SBATCH --account=ch4
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --output=arch_output_2.txt
#SBATCH --error=arch_error_2.txt
#SBATCH --time=20:00:00

counter=90
# Start with the reference run
runpath='/scratch/daint/ksilver/calibration/run'

#cd /scratch/daint/ksilver/calibration/run/reference/output

# Make the directory in project
#mkdir /project/ch4/ksilver/cosmo5_calibration/output/reference

#for year in 1994 1995 1996 1997 1998
#do 
#  tar -cf reference_out01_$year.tar ./out01/lffd$year*
#  tar -cf reference_out02_$year.tar ./out02/lffd$year* 
#done

#rsync -a *.tar /project/ch4/ksilver/cosmo5_calibration/output/reference 
#echo Finished with $counter of 129
#counter=$((counter+1))
min='n'
max='x'

#for param in rl e q u f t ra s
#for param in ra s
#do

# First the minimum
#  cd /scratch/daint/ksilver/calibration/run/$param$min/output
  
#  mkdir /project/ch4/ksilver/cosmo5_calibration/output/$param$min
  
#  for year in 1994 1995 1996 1997 1998
#  do
#    tar -cvf $runpath/$param$min/output/"$param$min"_out01_$year.tar $runpath/$param$min/output/out01/lffd$year*
#    tar -cvf $runpath/$param$min/output/"$param$min"_out02_$year.tar $runpath/$param$min/output/out02/lffd$year*
#  done

#  rsync -av $runpath/$param$min/output/*.tar /project/ch4/ksilver/cosmo5_calibration/output/$param$min
#  echo Finished with $counter of 129
#  counter=$((counter+1))
# Then the maximum

#  cd /scratch/daint/ksilver/calibration/run/$param$max/output

#  mkdir /project/ch4/ksilver/cosmo5_calibration/output/$param$max
  
#  for year in 1994 1995 1996 1997 1998
#  do
#    tar -cvf $runpath/$param$max/output/"$param$max"_out01_$year.tar $runpath/$param$max/output/out01/lffd$year*
#    tar -cvf $runpath/$param$max/output/"$param$max"_out02_$year.tar $runpath/$param$max/output/out02/lffd$year*
#  done

#  rsync -av $runpath/$param$max/output/*.tar /project/ch4/ksilver/cosmo5_calibration/output/$param$max
#  echo Finished with $counter of 129
#  counter=$((counter+1))
#  done

# Finally, the two parameter runs
i1='1'
#for param1 in rl e q u f t ra s
for param1 in u f t ra s
  do
  i2='1'
#  for param2 in rl e q u f t ra s
for param2 in u f t ra s
    do
    if [ "$i1" -lt "$i2" ]
      then
      # Both parameters minimum
      val1=$param1$min
      val2=$param2$min

#      cd /scratch/daint/ksilver/calibration/run/${val1}_${val2}/output

      mkdir /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}

      for year in 1994 1995 1996 1997 1998
      do
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out01_$year.tar $runpath/${val1}_${val2}/output/out01/lffd$year*
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out02_$year.tar $runpath/${val1}_${val2}/output/out02/lffd$year*
      done

      rsync -av  $runpath/${val1}_${val2}/output/*.tar /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}
      echo Finished with $counter of 129
      counter=$((counter+1))

      # param1 min and param2 max
      val1=$param1$min
      val2=$param2$max

#      cd /scratch/daint/ksilver/calibration/run/${val1}_${val2}/output
 
      mkdir /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}

      for year in 1994 1995 1996 1997 1998
      do
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out01_$year.tar $runpath/${val1}_${val2}/output/out01/lffd$year*
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out02_$year.tar $runpath/${val1}_${val2}/output/out02/lffd$year*
      done

      rsync -av  $runpath/${val1}_${val2}/output/*.tar /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}

      echo Finished with $counter of 129
      counter=$((counter+1))

      # param1 max and param2 min
      val1=$param1$max
      val2=$param2$min

    #  cd /scratch/daint/ksilver/calibration/run/${val1}_${val2}/output

      mkdir /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}

      for year in 1994 1995 1996 1997 1998
      do
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out01_$year.tar $runpath/${val1}_${val2}/output/out01/lffd$year*
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out02_$year.tar $runpath/${val1}_${val2}/output/out02/lffd$year*
      done
 
      rsync -av  $runpath/${val1}_${val2}/output/*.tar /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}
      
      echo Finished with $counter of 129
      counter=$((counter+1))

      # Both parameters maximum
      val1=$param1$max
      val2=$param2$max

    #  cd /scratch/daint/ksilver/calibration/run/${val1}_${val2}/output

      mkdir /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}

      for year in 1994 1995 1996 1997 1998
      do
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out01_$year.tar $runpath/${val1}_${val2}/output/out01/lffd$year*
        tar -cvf $runpath/${val1}_${val2}/output/${val1}_${val2}_out02_$year.tar $runpath/${val1}_${val2}/output/out02/lffd$year*
      done

      rsync -av  $runpath/${val1}_${val2}/output/*.tar /project/ch4/ksilver/cosmo5_calibration/output/${val1}_${val2}
      
      echo Finished with $counter of 129
      counter=$((counter+1))

    fi

    i2=$(($i2+1))
  done
    i1=$(($i1+1))
done

