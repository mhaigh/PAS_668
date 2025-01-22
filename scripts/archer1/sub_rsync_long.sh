#!/bin/bash
#

#
# wrapper script to qsub script to process and transfer all MITgcm results
#

JOBNO=666

# submit jobs

qsub -N PAS_${JOBNO}_rl \
     -A $HECACC \
     -V \
     -v JOBNO=$JOBNO \
     rsync_long.sh

