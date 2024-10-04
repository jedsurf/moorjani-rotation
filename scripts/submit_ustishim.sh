#!/bin/bash

for i in {1..22}; do
    sbatch ustishim.sh $i
done