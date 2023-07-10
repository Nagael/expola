#!/usr/bin/env bash
# Job name
#SBATCH -J expola
# Asking for one node
#SBATCH -N 1
# Standard output
#SBATCH -o expola-%j.out
# Standard error
#SBATCH -e expola-%j.err
# Diablo nodes
#SBATCH -C diablo
# Duration
#SBATCH --time=04:00:00
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

ARCH=diablo
OTHER="-np"
source ../plafrim_env.sh

if [ $1 == "MGS" ]; then
    python3 ../run_all.py --algo mgs --exec ../../pola/gs_${ARCH}/main_qr__time.exe --mvalues 50000 --nvalues $(seq 1 100) --batch 20 -- ${OTHER:=}
elif [ $1 == "A2V" ]; then
    python3 ../run_all.py --algo a2v --exec ../../pola/hh_${ARCH}_A2V/main_a2v__time.exe  --mvalues 50000 --nvalues $(seq 1 100) --batch 20 -- ${OTHER:=}
elif [ $1 == "V2Q" ]; then
    python3 ../run_all.py --algo v2q --exec ../../pola/hh_${ARCH}_V2Q/main_v2q__time.exe  --mvalues 50000 --nvalues $(seq 1 100) --batch 20 -- ${OTHER:=}
else
    echo "Unknown algorithm" $1
fi

