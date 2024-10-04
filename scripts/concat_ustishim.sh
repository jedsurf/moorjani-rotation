#!/bin/sh
#SBATCH --job-name=compress
#SBATCH --account=co_moorjani
#SBATCH --partition=savio3_htc
#SBATCH --ntasks-per-core=1
#SBATCH --cores=1
#SBATCH --time=12:00:00
#SBATCH --mem 120gb
#SBATCH --output=../scratch/O-%x.%j.out

# This is a script to concatenate and compress all of the vcf files for autosomes for ust-ishim
# In order to run admixfrog on all autosomes at once. 
data_dir="../processed-data/ust_ishim"
bcftools concat $data_dir/ust_ishim_chr{1..22}.vcf -o $data_dir/all_ust_ishim.vcf
bgzip -c $data_dir/all_ust_ishim.vcf > $data_dir/all_ust_ishim.vcf.gz
tabix -p vcf $data_dir/all_ust_ishim.vcf.gz