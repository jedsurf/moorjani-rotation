#!/bin/bash
#SBATCH --job-name=admixfrog
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --output=../scratch/O-%x.%j.out
#SBATCH --time=8:00:00
#SBATCH --mem 120gb

# Script to run admixfrog on Ust-Ishim on all chromosomes at once
# conda activate admixfrog2

data_dir=../processed-data
outpath=$data_dir/admixfrog-allentoft/Ust_Ishim
ref_file=$data_dir/Admixfrog_files/Admixfrog_Reference/ref_archaicadmixtureAPX_hs37mMask35to99.csv
in_file="$outpath/Ust_Ishim.in.xz"
mkdir -p $outpath

echo "Running admixfrog on sample Ust_Ishim"

admixfrog-bam \
    --vcfgt ../processed-data/ust_ishim/all_ust_ishim.vcf.gz \
    --ref $ref_file \
    --out "$in_file" \
    --target Ust_Ishim --force-target-file

admixfrog --states AFR NEA DEN --cont-id AFR \
    --ll-tol 0.01 --bin-size 5000 --est-F --est-tau --freq-F 3 --freq-contamination 3 \
    --e0 0.01 --est-error --ancestral PAN --run-penalty 0.1 --max-iter 250 \
    --n-post-replicates 200 --filter-pos 50 --filter-map 0.000 \
    --init-guess AFR `# Probably safe to keep this in` \
    --infile $in_file \
    --ref $ref_file \
    --out "$outpath/Ust_Ishim" \
    --map-id Shared_Map \
    --force-target-file --dont-est-contamination
