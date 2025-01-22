#!/bin/bash
#

#
# wrapper script to qsub script to process and transfer all MITgcm results
#

JOBNO=666

# submit jobs

qsub -N PAS_${JOBNO}_s \
     -A $HECACC \
     -V \
     -v JOBNO=$JOBNO \
     scp_results.sh

