#!/bin/bash
#

#
# wrapper script to qsub script to process and transfer all MITgcm results
#

JOBNO=666

# submit jobs

qsub -N PAS_${JOBNO}_rs \
     -A $HECACC \
     -V \
     -v JOBNO=$JOBNO \
     rsync_short.sh

