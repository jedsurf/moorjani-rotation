#!/bin/sh
#SBATCH --job-name=compress
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --time=12:00:00
#SBATCH --mem 120gb

# This is a script to concatenate and compress all of the vcf files for autosomes from allentoft et al. 
# In order to run admixfrog on all autosomes at once. 
vcf_dir="/global/scratch/p2p3/pl1_moorjani/SHARED_LAB/DATASETS/hg19/ANCIENT/allentoft_2024"
data_dir="/global/scratch/p2p3/pl1_moorjani/jackdemaray/rotation/moorjani-rotation/processed-data"
bcftools concat $vcf_dir/{1..22}.neo_impute_ph.vcf.gz -o $data_dir/all.neo_impute_ph.vcf
bgzip -c $data_dir/all.neo_impute_ph.vcf > $data_dir/all.neo_impute_ph.vcf.gz
tabix -p vcf $data_dir/all.neo_impute_ph.vcf.gz
