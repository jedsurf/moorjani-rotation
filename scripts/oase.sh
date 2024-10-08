#!/bin/bash
# Script to run admixfrog on Oase as + ctrl
data_dir=../processed-data
outpath=$data_dir/admixfrog-allentoft/$1
ref_file=$data_dir/Admixfrog_files/Admixfrog_Reference/ref_archaicadmixtureAPX_hs37mMask35to99.csv
in_file="$outpath/$1.in.xz"
mkdir -p $outpath

echo "Running admixfrog on chromosome $2 of sample $1"


admixfrog-bam \
    --vcfgt /global/scratch/p2p3/pl1_moorjani/SHARED_LAB/DATASETS/hg19/ANCIENT/EMH+ARCHAIC/updated/merged_var_nosing_sites_arch_apes_g1000_chr$2.vcf.gz \
    --chroms $2 \
    --ref $ref_file \
    --out "$in_file" \
    --target $1 --force-target-file

# admixfrog --states AFR NEA DEN --cont-id AFR \
#     --ll-tol 0.01 --bin-size 5000 --est-F --est-tau --freq-F 3 --freq-contamination 3 \
#     --e0 0.01 --est-error --ancestral PAN --run-penalty 0.1 --max-iter 250 \
#     --n-post-replicates 200 --filter-pos 50 --filter-map 0.000 --init-guess AFR \
#     --chroms $2 \
#     --infile $in_file \
#     --ref $ref_file \
#     --out "$outpath/$2" \
#     --force-target-file 
