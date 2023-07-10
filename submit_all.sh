#!/usr/bin/env bash

sbatch job_submission_miriel.sh MGS
sbatch job_submission_miriel.sh A2V
sbatch job_submission_miriel.sh V2Q

sbatch job_submission_bora.sh MGS
sbatch job_submission_bora.sh A2V
sbatch job_submission_bora.sh V2Q

sbatch job_submission_diablo.sh MGS
sbatch job_submission_diablo.sh A2V
sbatch job_submission_diablo.sh V2Q
