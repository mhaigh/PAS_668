#!/bin/bash
################################################
# Clean out old results and link input files.
################################################

# Empty the run directory - but first make sure it exists!
if [ -d "../run" ]; then
  cd ../run
  rm -rf *
else
  echo 'There is no run directory'
  exit 1
fi

# Link everything from the input directory
ln -s ../input/* . 

# Deep copy of the master namelist (so it doesn't get overwritten in input/)
rm -f data
cp -f ../input/data .

# Deep copy of any pickups (so they don't get overwritten in input/)
rm -f pickup*
cp -f ../input/pickup* . 2>/dev/null

# Link forcing files stored elsewhere

#echo 'linking ERAI'
#ln -s /work/n02/n02/shared/baspog/MITgcm/reanalysis/ERAI_075/* .
#../scripts/dummy_link.sh ERAI 1955 1978 1979 2002

echo 'linking ERA5'
ln -s /work/n02/n02/shared/baspog/MITgcm/reanalysis/ERA5/* .
../scripts/dummy_link.sh ERA5 1955 1978 1979 2002

#echo 'linking PACE'
#ln -s /work/n02/n02/pahol/CESM/PACE/* .
#../scripts/dummy_link.sh PACE 1919 1919 1920 1920

# Link executables
ln -s ../build/mitgcmuv .
ln -s ../../../utilities/mit2nc/mit2nc .
