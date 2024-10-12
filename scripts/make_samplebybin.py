# Script to make sample by bin matrix for a given chromosome
import numpy as np
import pandas as pd
import sys

chrom = int(sys.argv[1])

print(f"Generating sample x bin for chromosome {chrom}")
# Read sample metadata
metadata = pd.read_csv(
    "../processed-data/metadata_allentoft_et_al_2024.csv", index_col=0)

# Convert average ages to ints
ages = metadata["Age average"][~metadata["Age average"].isna()] # one sample doesn't have an age given...
ages = ages.str.replace(",", "_").astype(int)
metadata.loc[ages.index, "Age average"] = ages.values
# Get allentoft samples with no flags
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
print("Reading bins...")
sample_by_bin = pd.DataFrame()
ctr = 0
for sample in sample_order:
    bins = pd.read_csv(f"{data_dir}/{sample}/{sample}.bin.xz")
    bins = bins[bins["chrom"] == chrom]
    sample_by_bin.loc[sample, bins["map"].unique()] = (
        bins["NEA"] + bins["AFRNEA"]).values
    ctr += 1
    print(f"\tFiles read: {ctr}", end="\r")
print("Reading Iasi et al. data...")
# WE NEED LEO AGES TO SORT FINAL MATRIX
ages_leo = pd.read_csv("../processed-data/iasi_ages.csv")
# The Stuttgart sample doesn't have a mean age, but does have upper and lower 
# bounds, so I'm just manually calculating from that. 
stuttgart = ages_leo.loc[ages_leo["Sample"]=="Stuttgart_LBK"]
ages_leo.loc[ages_leo["Sample"]=="Stuttgart_LBK", "Most Likely Date Mean"] = (
    stuttgart[
        ["Most Likely Date Lower (95.5 % CI)", 
        "Most Likely Date Upper (95.5 % CU)"]].mean(axis=1))
# Reformat age df
ages_leo = (ages_leo
    # .drop(columns="Sample")
    # .set_index("admixfrog_sample_name")
    .rename(columns={
        "Most Likely Date Mean" : "Age average",
        # "admixfrog_sample_name" : "Sample"
        })
    # .set_index("Sample")
    .loc[:, ["Sample", "Age average"]])
ancient_samples_leo = ages_leo["Sample"].tolist()
ages_leo["Age average"] = ages_leo["Age average"].astype(int)

# Remove the samples present in the Allentoft data from Leo's bin file
repeated_samples = [i for i in ancient_samples_leo if i in samples]
# Drop repeated samples from age df
ages_leo = ages_leo.loc[[i not in repeated_samples for i in ages_leo["Sample"]]]
# Concatenate with ages from Allentoft to order by age
ages_ancient = pd.concat(
    [
        metadata.loc[samples, "Age average"],
        ages_leo.set_index("Sample")
        # .copy()
        # .rename(columns={"Most Likely Date Mean" : "Age average"})
        # .set_index("Sample")
        ]).sort_values(by="Age average", ascending=False)


# Now let's read in Leo's bin data
leo_dir = "/global/scratch/p2p3/pl1_moorjani/jackdemaray/rotation/moorjani-rotation/processed-data/Admixfrog_files/Admixfrog_merged_bin_files/Shared_Map/Admixfrog_merged_bin_files"
leo_binfile = 'All_merged_bins_NEAarchaicadmixtureAPX.bin_called_map_Shared_Map_penatly_0.25_min_len0.2_0.05_min_len_pos0_0_min_n_all_SNP0_0_min_n_SNP0_0.csv'
bins_leo = pd.read_csv(f"{leo_dir}/{leo_binfile}")#, index_col=0)
# Read in Leo metadata
metadata_leo = pd.read_csv("../processed-data/iasi_metadata.csv")
# Rename samples in Leo's bin file to original study names
translator = dict(metadata_leo[
    ["Sample name this study", "Sample Name in origina publication"]].values)
bins_leo = bins_leo.rename(columns=translator)
# Get modern samples
modern_samples = [i for i in bins_leo.iloc[:, 4:].columns if i not in ancient_samples_leo]
age_order = ages_ancient.index.tolist() + modern_samples
# Remove repeated ancient samples
bins_leo.drop(columns=repeated_samples, inplace=True)
# Prune to selected chromosome
bins_leo = bins_leo[bins_leo["chrom"] == chrom]
# Reformat to sample x bins
bins_leo = bins_leo.set_index("map").iloc[:, 3:].T
print("Aggregating results...")
# Aggregate samples by bins
pd.set_option('future.no_silent_downcasting', True)
sample_by_bin = pd.concat([sample_by_bin, bins_leo]).fillna(0.0).infer_objects(copy=False)
# Order the samples
sample_by_bin = sample_by_bin.loc[[i for i in sample_by_bin.index if i in age_order]]
# Finally, save the results
print("Saving results...")
# # I'm gonna write a csv and csv.gz for now because last time I ran it, the 
# # csv.gz files had only the sample index and nothing else...
# print("\tuncompressed:")
# sample_by_bin.to_csv(f"../processed-data/sample_by_bin/chr{chrom}.csv")
# print("\tgzipped:")
sample_by_bin.to_csv(f"../processed-data/sample_by_bin/chr{chrom}.csv.gz")

