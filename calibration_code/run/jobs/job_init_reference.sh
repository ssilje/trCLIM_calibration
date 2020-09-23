#!/bin/bash
#SBATCH --account=pr04
#SBATCH --nodes=6
#SBATCH --ntasks-per-node=1
#SBATCH --gres=gpu:1
#SBATCH --time=15:00:00
#SBATCH --constraint=gpu
#SBATCH --output=log/CCLM_calib_reference_init.out
#SBATCH --error=log/CCLM_calib_reference_init.err
#SBATCH --job-name=calib_reference

export MALLOC_MMAP_MAX_=0
export MALLOC_TRIM_THRESHOLD_=536870912
export OMP_NUM_THREADS=1
export MV2_ENABLE_AFFINITY=0
export MV2_USE_CUDA=1
export MPICH_RDMA_ENABLED_CUDA=1
export MPICH_G2G_PIPELINE=256
export MPICH_GNI_LMT_PATH=disabled 

# Set this to avoid segmentation faults
 ulimit -s unlimited
 ulimit -c unlimited
 ulimit -a

run_dir='/scratch/snx3000/ssilje/COSMO-crCLIM_calibration'

/bin/rm YU*

for f in $run_dir/INPUT_*
do
  ln -s $f .
done

ln -s $run_dir/cclm .
source $run_dir/modules_fortran.env
# Run CLM in working directory
srun -u -n 6 cclm

for f  in ./YU*
do
  mv $f log/$f.reference
done


 if [ -e ./restart/lrfd2005010100o ]; then
    sbatch job_restart.sh
else 
     sbatch job_init.sh
 fi
