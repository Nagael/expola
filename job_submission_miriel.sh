#!/usr/bin/env bash
# Job name
#SBATCH -J expola
# Asking for one node
#SBATCH -N 1
# Standard output
#SBATCH -o expola-%j.out
# Standard error
#SBATCH -e expola-%j.err
# Miriel nodes
#SBATCH -C miriel
# Duration
#SBATCH --time=03:00:00
#Exclusive access (no disturbing my cache)
#SBATCH --exclusive


>&2 echo "=====my job information ===="
>&2 echo "Node List: " $SLURM_NODELIST
>&2 echo "my jobID: " $SLURM_JOB_ID
>&2 echo "Partition: " $SLURM_JOB_PARTITION
>&2 echo "submit directory:" $SLURM_SUBMIT_DIR
>&2 echo "submit host:" $SLURM_SUBMIT_HOST
>&2 echo "In the directory:" $PWD
>&2 echo "As the user:" $USER

ARCH=miriel
source ./job_submission_common.sh
