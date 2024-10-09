# Script to make sample by bin matrix for a given chromosome
import numpy
import pandas as pd
import sys

chrom = sys.argv[1]

# Read sample metadata
metadata = pd.read_csv(
    "../processed-data/metadata_allentoft_et_al_2024.csv", index_col=0)

# Convert average ages to ints
ages = metadata["Age average"][~metadata["Age average"].isna()] # one sample doesn't have an age given...
ages = ages.str.replace(",", "_").astype(int)
metadata.loc[ages.index, "Age average"] = ages.values
# Get samples with no flags
samples = pd.read_csv(
    "../processed-data/noflag.inds.txt", header=None, index_col=0)
samples = samples.index.tolist()
sample_order = (
    metadata.loc[samples]
    .dropna(subset="Age average") # Need to get rid of the one ageless sample
    .sort_values(by="Age average", ascending=False)
    .index.tolist())

# Now, let's start reading in the bin files
data_dir = "../processed-data/admixfrog-allentoft"

sample_by_bin = pd.DataFrame()
for sample in sample_order:
    bins = pd.read_csv(f"{data_dir}/{sample}/{sample}.bin.xz")
    bins = bins[bins["chrom"] == chrom]
    sample_by_bin.loc[sample, bins["map"].unique()] = (
        bins["NEA"] + bins["AFRNEA"]).values
sample_by_bin.to_csv(f"../processed-data/sample_by_bin/chr{chrom}.csv.gz")
# TODO: Incorporate Leo's additional samples
