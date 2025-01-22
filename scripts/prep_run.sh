#!/bin/bash

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
cp -f ../input/data.exf_ERA5 data.exf

#aecho 'Using default monthly diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_monthly data.diagnostics

#echo 'Using seaice-focussed diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_seaice data.diagnostics

echo 'Using vertical temp-focussed diagnostics. Comment out if not wanted'
cp -f ../input/data.diagnostics_temp data.diagnostics

#echo 'Using snapshot diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_snaps data.diagnostics

#echo 'Using daily mixing diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_mixing data.diagnostics

#echo 'Using daily snapahot diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_daily_snaps data.diagnostics

#echo 'Using exf2wind diagnostics. Comment out if not wanted'
#cp -f ../input/data.diagnostics_2winds data.diagnostics

# Deep copy of any pickups (so they don't get overwritten in input/)
rm -f pickup*
cp -f ../input/restart_c68r/pickup* . 

# Link forcing files
ln -s /work/n02/n02/shared/baspog/ERA5/* .
../scripts/dummy_link.sh ERA5 1955 1978 1979 2002

pwd
# Link executables
ln -s ../build/mitgcmuv .
ln -s ../../../utilities/mit2nc/mit2nc .
