#!/bin/bash
#SBATCH --job-name=admixfrog
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --output=../scratch/O-%x.%j.out
#SBATCH --time=2:00:00
#SBATCH --mem 8gb

# Script to run admixfrog on Ust-Ishim on a single chromosome at a time
# conda activate admixfrog2

data_dir=../processed-data
outpath=$data_dir/admixfrog-allentoft/Ust_Ishim
ref_file=$data_dir/Admixfrog_files/Admixfrog_Reference/ref_archaicadmixtureAPX_hs37mMask35to99.csv
in_file="$outpath/Ust_Ishim_$1.in.xz"
mkdir -p $outpath

echo "Running admixfrog on chromosome $1 of sample Ust_Ishim"

admixfrog-bam \
    --vcfgt /global/scratch/p2p3/pl1_moorjani/SHARED_LAB/DATASETS/hg19/ANCIENT/ARCHAIC/Ust_Ishim/chr{$1}_mq25_mapab100.vcf.gz \
    --chroms $1 \
    --ref $ref_file \
    --out "$in_file" \
    --target Ust_Ishim --force-target-file

admixfrog --states AFR NEA DEN --cont-id AFR \
    --ll-tol 0.01 --bin-size 5000 --est-F --est-tau --freq-F 3 --freq-contamination 3 \
    --e0 0.01 --est-error --ancestral PAN --run-penalty 0.1 --max-iter 250 \
    --n-post-replicates 200 --filter-pos 50 --filter-map 0.000 \
    --init-guess AFR `# Probably safe to keep this in` \
    --chroms $1 \
    --infile $in_file \
    --ref $ref_file \
    --out "$outpath/$1" \
    --map-id Shared_Map \
    --force-target-file --dont-est-contamination
