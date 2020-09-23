#!/bin/bash

#SBATCH --account=pr04
#SBATCH --nodes=1
##SBATCH --partition=prepost
#SBATCH --time=0:30:00
#SBATCH --constraint=gpu
#SBATCH --output=postpro_ERA-I.out
#SBATCH --error=postpro_ERA-I.err
#SBATCH --job-name="postpro_ERA-I"

#####################################################################################
#  This script extracts the monthly mean 2m temperature, precipitation, cloud cover,#
#  and daily temperature range for the period 1994-1998.  The data is taken from    #
#  the E-obs and CRU datasets and also averaged over the PRUDENCE regions.          #
#  Written 4/9/15 by Katie Osterried                                                #
#####################################################################################

module load daint-gpu
module load CDO NCO

# Do the time subset and the monthly mean all in one command

# Start with 2m mean temperature
cdo monmean -seldate,2000-01-01,2009-12-30 /project/pr04/observations/eobs_0.44deg_rot_v16.0/tg_0.44deg_rot_v16.0.nc \t2m_mm.nc

# Now precipitation

cdo monmean -seldate,2000-01-01,2009-12-30 /project/pr04/observations/eobs_0.44deg_rot_v16.0/rr_0.44deg_rot_v16.0.nc \rr_mm.nc

# Now the CRU (cloud cover data)

# Get the observational grid from the EOBS data
cdo griddes /project/pr04/observations/eobs_0.44deg_rot_v10.0/tx_0.44deg_rot_v10.0.nc > grid_model.txt
#cp  /project/pr04/ssilje/GRIDINFO/fgrid grid_model.txt
# Select the date range, map to the EOBS data grid, and take the monthly mean of the CRU data

cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/clct/cru_ts4.01.1901.2016.cld.dat.nc clct_mm.nc

# Get TOA fluxes from CERES

cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/toa/CERES_EBAF-TOA_Edition4.0_200003-201701.nc toa_mm.nc


# Get altnerative datasets of each of the variables

cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/clct/ceres_ebaf_200003-201701_clct.nc clct_mm_2.nc
cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/clct/eri_clct_1989-2009.nc clct_mm_3.nc

cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/t2m/cru_ts4.01.1901.2016.tmp.dat.nc t2m_mm_2.nc
cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/t2m/air.mon.mean.v401.nc t2m_mm_3.nc

cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/pr/cru_ts4.01.1901.2016.pre.dat.nc rr_mm_2.nc
cdo monmean -remapbil,grid_model.txt -seldate,2000-01-01,2009-12-30 /project/pr04/observations/pr/precip.mon.total.v401.nc rr_mm_3.nc


# Remove the grid file

rm grid_model.txt

# Now do the averaging over the PRUDENCE regions
# 2m Temperature
cdo fldmean -sellonlatbox,-10,2,50,59 t2m_mm.nc t2m_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 t2m_mm.nc t2m_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 t2m_mm.nc t2m_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 t2m_mm.nc t2m_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 t2m_mm.nc t2m_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 t2m_mm.nc t2m_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 t2m_mm.nc t2m_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 t2m_mm.nc t2m_8.nc

#Precipitation
cdo fldmean -sellonlatbox,-10,2,50,59 rr_mm.nc rr_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 rr_mm.nc rr_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 rr_mm.nc rr_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 rr_mm.nc rr_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 rr_mm.nc rr_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 rr_mm.nc rr_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 rr_mm.nc rr_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 rr_mm.nc rr_8.nc

# Cloud cover
cdo fldmean -sellonlatbox,-10,2,50,59 clct_mm.nc clct_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 clct_mm.nc clct_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 clct_mm.nc clct_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 clct_mm.nc clct_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 clct_mm.nc clct_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 clct_mm.nc clct_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 clct_mm.nc clct_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 clct_mm.nc clct_8.nc

# TOA
cdo fldmean -sellonlatbox,-10,2,50,59 toa_mm.nc toa_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 toa_mm.nc toa_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 toa_mm.nc toa_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 toa_mm.nc toa_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 toa_mm.nc toa_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 toa_mm.nc toa_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 toa_mm.nc toa_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 toa_mm.nc toa_8.nc



# Now do the averaging over the PRUDENCE regions
# 2m Temperature
cdo fldmean -sellonlatbox,-10,2,50,59 t2m_mm_2.nc t2m2_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 t2m_mm_2.nc t2m2_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 t2m_mm_2.nc t2m2_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 t2m_mm_2.nc t2m2_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 t2m_mm_2.nc t2m2_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 t2m_mm_2.nc t2m2_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 t2m_mm_2.nc t2m2_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 t2m_mm_2.nc t2m2_8.nc

#Precipitation
cdo fldmean -sellonlatbox,-10,2,50,59 rr_mm_2.nc rr2_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 rr_mm_2.nc rr2_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 rr_mm_2.nc rr2_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 rr_mm_2.nc rr2_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 rr_mm_2.nc rr2_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 rr_mm_2.nc rr2_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 rr_mm_2.nc rr2_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 rr_mm_2.nc rr2_8.nc

# Cloud cover
cdo fldmean -sellonlatbox,-10,2,50,59 clct_mm_2.nc clct2_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 clct_mm_2.nc clct2_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 clct_mm_2.nc clct2_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 clct_mm_2.nc clct2_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 clct_mm_2.nc clct2_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 clct_mm_2.nc clct2_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 clct_mm_2.nc clct2_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 clct_mm_2.nc clct2_8.nc

# Now do the averaging over the PRUDENCE regions
# 2m Temperature
cdo sellonlatbox,-10,2,50,59 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_1.nc
cdo sellonlatbox,-10,3,36,44 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_2.nc
cdo sellonlatbox,-5,5,44,50 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_3.nc
cdo sellonlatbox,2,16,48,55 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_4.nc
cdo sellonlatbox,5,30,55,70 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_5.nc
cdo sellonlatbox,5,15,44,48 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_6.nc
cdo sellonlatbox,3,25,36,44 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_7.nc
cdo sellonlatbox,16,30,44,55 t2m_mm_3.nc tmp.nc; cdo fldmean tmp.nc t2m3_8.nc

#Precipitation
cdo sellonlatbox,-10,2,50,59 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_1.nc
cdo sellonlatbox,-10,3,36,44 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_2.nc
cdo sellonlatbox,-5,5,44,50 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_3.nc
cdo sellonlatbox,2,16,48,55 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_4.nc
cdo sellonlatbox,5,30,55,70 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_5.nc
cdo sellonlatbox,5,15,44,48 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_6.nc
cdo sellonlatbox,3,25,36,44 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_7.nc
cdo sellonlatbox,16,30,44,55 rr_mm_3.nc tmp.nc; cdo fldmean tmp.nc rr3_8.nc

# Cloud cover
cdo fldmean -sellonlatbox,-10,2,50,59 clct_mm_3.nc clct3_1.nc
cdo fldmean -sellonlatbox,-10,3,36,44 clct_mm_3.nc clct3_2.nc
cdo fldmean -sellonlatbox,-5,5,44,50 clct_mm_3.nc clct3_3.nc
cdo fldmean -sellonlatbox,2,16,48,55 clct_mm_3.nc clct3_4.nc
cdo fldmean -sellonlatbox,5,30,55,70 clct_mm_3.nc clct3_5.nc
cdo fldmean -sellonlatbox,5,15,44,48 clct_mm_3.nc clct3_6.nc
cdo fldmean -sellonlatbox,3,25,36,44 clct_mm_3.nc clct3_7.nc
cdo fldmean -sellonlatbox,16,30,44,55 clct_mm_3.nc clct3_8.nc

