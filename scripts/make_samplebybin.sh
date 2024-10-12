#!/bin/bash
#SBATCH --job-name=samplebybin
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --output=../scratch/O-%x.%j.out
#SBATCH --time=6:00:00
#SBATCH --mem 120gb

# Script to make sample by bin matrix for a given chromosome using 
# make_samplebybin.py
# Run with:
# conda activate admixfrog2 
# for i in {1..22}; do sbatch make_samplebybin.sh $i; done
python make_samplebybin.py $1
