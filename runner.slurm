#!/bin/bash

# the above bin/bash line is required to be at the top of your bash script

## Set slurm options and flags
#SBATCH -A shakeri_ds6050               # your allocation
#SBATCH -p gpu                          # use standard for cpu, gpu for gpu
#SBATCH --gres=gpu:1                    # required if using gpu. Can optionally choose a desired gpu
#SBATCH --ntasks=1                      # number of tasks
#SBATCH --nodes=1                       # number of nodes
#SBATCH --mem=64G                       # Amount of memory to allocate for the job
#SBATCH -c 1                            # cpus per task
#SBATCH -t 72:00:00                     # max wall clock time. 3 days is the limit for gpus. 7 days for cpus.
#SBATCH -o ./slurmlogs/train_%A_%a.out  # stdout output file
#SBATCH -e ./slurmlogs/train_%A_%a.err  # stderr output file

# For the output files, %A refers to the job id (assigned by slurm)
#                       %a refers to the array index (applicable if you submit an array job)
# If the job id is 1234 and there is no array index
# the outfile should be saved to <current directory>/slurmlogs/train_1234_.out
# Just to be safe, make sure the path to the output files exist
# which in this case means that the directory <current directory>/slurmlogs/ should exist.

## set up environment and python executable
CONDA_ENV_PATH="/path/to/dsvenv"
PIP_EX="$CONDA_ENV_PATH/bin/pip"
PYTHON_EX="$CONDA_ENV_PATH/bin/python"

## Gather current slurm job info
now=$(date -Iseconds)
wallclock=$(squeue -h -j $SLURM_ARRAY_JOB_ID -o %l)
gpuname=$(nvidia-smi --query-gpu=name --format=csv,noheader)

## print current slurm job info to stdout (and therefore train.out)
printf "\n\n======================================\n"
printf "[ JOB ID ]     : $SLURM_ARRAY_JOB_ID\n"
printf "[ ARRAY ID ]   : $SLURM_ARRAY_TASK_ID\n"
printf "[ WALLCLOCK  ] : $wallclock\n"
printf "[ START TIME ] : $now\n"
printf "[ GPU ]        : $gpuname\n\n"

## print current slurm job info to stderr (and therefore train.err)
printf "\n\n======================================\n" >&2
printf "[ JOB ID ]     : $SLURM_ARRAY_JOB_ID\n" >&2
printf "[ ARRAY ID ]   : $SLURM_ARRAY_TASK_ID\n" >&2
printf "[ WALLCLOCK  ] : $wallclock\n" >&2
printf "[ START TIME ] : $now\n" >&2
printf "[ GPU ]        : $gpuname\n\n" >&2


# script to run your python script here

# For example, suppose I had a python script called trainmodel.py
$PYTHON_EX trainmodel.py

# $PYTHON_EX gets the value stored in the variable PYTHON_EX
# which in this case will expand to /path/to/dsvenv/bin/python
# so the full command that gets executed is:
# /path/to/dsvenv/bin/python trainmodel.py
