#!/bin/bash
#SBATCH --job-name=admixfrog
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --output=../scratch/O-%x.%j.out
#SBATCH --time=12:00:00
#SBATCH --mem 120gb

# Script to run admixfrog on ancient samples from allentoft et al.
# this relies on a concatenated vcf file for all autosomes and 
# calculates introgression for all chromosomes at once

data_dir=../processed-data
outpath=$data_dir/admixfrog-allentoft/$1
ref_file=$data_dir/Admixfrog_files/Admixfrog_Reference/ref_archaicadmixtureAPX_hs37mMask35to99.csv
in_file="$outpath/$1.in.xz"
mkdir -p $outpath

echo "Running admixfrog on sample $1"

# admixfrog-bam \
#     --vcfgt $data_dir/all.neo_impute_ph.vcf.gz \
#     --ref $ref_file \
#     --out "$in_file" \
#     --target $1 --force-target-file

admixfrog --states AFR NEA DEN --cont-id AFR \
    --ll-tol 0.01 --bin-size 5000 --est-F --est-tau --freq-F 3 --freq-contamination 3 \
    --e0 0.01 --est-error --ancestral PAN --run-penalty 0.1 --max-iter 250 \
    --n-post-replicates 200 --filter-pos 50 --filter-map 0.000 \
    --init-guess AFR \
    --infile $in_file \
    --ref $ref_file \
    --out "$outpath/$1" \
    --map-id Shared_Map \
    --force-target-file --dont-est-contamination