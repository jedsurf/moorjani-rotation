import pandas as pd
import numpy as np

adf = pd.read_csv("../processed-data/iasi_ages.csv")
# The Stuttgart sample doesn't have a mean age, but does have upper and lower 
# bounds, so I'm just manually calculating from that. 
stuttgart = adf.loc[adf["Sample"]=="Stuttgart_LBK"]
adf.loc[adf["Sample"]=="Stuttgart_LBK", "Most Likely Date Mean"] = (
    stuttgart[
        ["Most Likely Date Lower (95.5 % CI)", 
        "Most Likely Date Upper (95.5 % CU)"]].mean(axis=1))
adf.rename(columns={
    "Sample" : "Individual ID",
    'admixfrog_sample_name' : "Iasi et al. Sample Name",
    "Most Likely Date Mean" : "Age average",
    "Most Likely Date Lower (95.5 % CI)" : "Age (lower)",
    "Most Likely Date Upper (95.5 % CU)" : "Age (upper)"
    }, inplace=True)
ancient_samples_leo = adf["Individual ID"].tolist()
adf.set_index("Individual ID", inplace=True)

mdl = pd.read_csv("../processed-data/iasi_metadata.csv")
mdl.rename(columns={
    "Sample Name in origina publication" : "Individual ID",
    'Sample name this study' : "Iasi et al. Sample Name",
    "Citation" : "Data source"}, inplace=True)
mdl.set_index("Individual ID", inplace=True)

mdl_merge = mdl.join(adf.drop(columns="Iasi et al. Sample Name"))
# Add 0 as age for modern samples
mdl_merge[['Age average', 'Age (lower)', 'Age (upper)']] = (
    mdl_merge[['Age average', 'Age (lower)', 'Age (upper)']]
    .fillna(0))

# Load in allentoft metadata
# Read sample metadata
metadata = pd.read_csv(
    "../processed-data/metadata_allentoft_et_al_2024.csv", index_col=0)

# Convert average ages to ints
ages = metadata["Age average"][~metadata["Age average"].isna()] # one sample doesn't have an age given...
ages = ages.str.replace(",", "_").astype(int)
metadata.loc[ages.index, "Age average"] = ages.values

# Drop samples also in allentoft data
samples_to_drop = [i for i in mdl_merge.index if i in metadata.index]
mdl_merge.drop(samples_to_drop, inplace=True)
# Actually combine the metadatas
md_combined = pd.concat([metadata, mdl_merge])

# Cleaning up the dataframe before saving
# Need to get rid of sample with no age
md_combined.drop("K1", inplace=True)
# Drop the columns not shared between metadatas
md_combined.dropna(axis=1, inplace=True)
md_combined["Sex"] = md_combined["Sex"].replace({"XY" : "male", "XX" : "female"})
# Save the results
md_combined.to_csv("../processed-data/metadata_combined.csv.gz")
# print(md_combined)
