#!/usr/bin/env bash

sbatch job_focus_miriel.sh MGS
sbatch job_focus_miriel.sh A2V
sbatch job_focus_miriel.sh V2Q

sbatch job_focus_bora.sh MGS
sbatch job_focus_bora.sh A2V
sbatch job_focus_bora.sh V2Q

sbatch job_focus_diablo.sh MGS
sbatch job_focus_diablo.sh A2V
sbatch job_focus_diablo.sh V2Q
