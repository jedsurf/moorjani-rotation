#!/bin/bash
#SBATCH --job-name=admixfrog
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --output=../scratch/O-%x.%j.out
#SBATCH --time=1:00:00
#SBATCH --mem 8gb

for i in {1..22}; do
    sbatch admixfrog_chrom.sh $1 $i
done