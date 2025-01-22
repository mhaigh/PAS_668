#!/bin/bash
#SBATCH --time=24:00:00
#SBATCH --nodes=1
#SBATCH --tasks-per-node=1
#SBATCH --cpus-per-task=1
#SBATCH --partition=serial
#SBATCH --qos=serial
#SBATCH --chdir=../run

JOBNO=666

# move to run directory
cd ../run

# make target directory
HOMEDIR=$HOMEROOT/PAS_${JOBNO}/run
ssh -t $HOMEHOST "mkdir -p $HOMEDIR"

# rsync peripheral files
rsync -azvl ../input/data* $HOMEHOST:$HOMEDIR
rsync -avzL hFac* $HOMEHOST:$HOMEDIR
rsync -avzL Depth* $HOMEHOST:$HOMEDIR
rsync -avzL DRF* $HOMEHOST:$HOMEDIR
rsync -avzL DRC* $HOMEHOST:$HOMEDIR
rsync -avzL DXG* $HOMEHOST:$HOMEDIR
rsync -avzL DYG* $HOMEHOST:$HOMEDIR
rsync -avzL RAC* $HOMEHOST:$HOMEDIR
rsync -avzL RC* $HOMEHOST:$HOMEDIR
rsync -avzL RF* $HOMEHOST:$HOMEDIR
rsync -avzL XC* $HOMEHOST:$HOMEDIR
rsync -avzL YC* $HOMEHOST:$HOMEDIR
rsync -avzL XG* $HOMEHOST:$HOMEDIR
rsync -avzL YG* $HOMEHOST:$HOMEDIR
rsync -avzL stdout_* $HOMEHOST:$HOMEDIR

# rsync -avzL state* $HOMEHOST:$HOMEDIR

# for each diagnostic file, make netcdf and rsync
#VARS="
#	state2D
#	stateExf
#	stateTheta
#	stateSalt
#	stateRho
#	stateUvel
#	stateVvel
#	stateWvel
#	"
VARS="
	stateUvel
	stateVvel
	stateExf
	state2D
	stateRho
     "

for VAR in $VARS
do
  rm -rf $VAR.nc
  echo 'seconds since 2012-01-01 00:00:00' > file_list
  ls $VAR.*.data >> file_list
  ./mit2nc
  rsync -avzL $VAR.nc $HOMEHOST:$HOMEDIR
  rm -rf $VAR.nc
done
