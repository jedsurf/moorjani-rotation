#!/bin/bash
#SBATCH --job-name=ustishim
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --time=1:00:00
#SBATCH --mem 10gb

data_dir="../../../../SHARED_LAB/DATASETS/hg19/ANCIENT/EMH+ARCHAIC/updated"
output_dir="../processed-data/ust_ishim"
mkdir -p $output_dir
bcftools view -s "Ust_Ishim" -o $output_dir/ust_ishim_chr$1.vcf -O v "$data_dir/merged_var_nosing_sites_arch_apes_g1000_chr$1.vcf.gz"

