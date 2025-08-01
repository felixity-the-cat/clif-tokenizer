#!/bin/bash

#SBATCH --job-name=xfer-rep-preds
#SBATCH --output=./output/%A_%a-%x.stdout
#SBATCH --partition=tier2q
#SBATCH --mem=10GB
#SBATCH --time=1:00:00
#SBATCH --array=0-15

source preamble.sh

ni=4
nj=4
i=$((SLURM_ARRAY_TASK_ID % ni))
j=$((SLURM_ARRAY_TASK_ID / ni))

if ((SLURM_ARRAY_TASK_COUNT != ni * nj)); then
    echo "Warning:"
    echo "SLURM_ARRAY_TASK_COUNT=$SLURM_ARRAY_TASK_COUNT"
    echo "ni*nj=$((ni * nj))"
fi

methods=(
    none
    top
    bottom
    random
)
pct=(
    10
    20
    30
    40
)
model=llama-med-60358922_1-hp-W++

python3 ../fms_ehrs/scripts/transfer_rep_based_preds.py \
    --data_dir_orig "${hm}/data-mimic" \
    --data_dir_new "${hm}/data-ucmc" \
    --data_version "W++_first_24h_${model}_${methods[$i]}_${pct[$j]}pct_ppy" \
    --model_loc "${hm}/mdls-archive/${model}" \
    --classifier logistic_regression \
    --drop_icu_adm \
    --save_preds

#models=(
#    llama-original-60358922_0-hp-W++
#    llama-med-60358922_1-hp-W++
#    llama-small-60358922_2-hp-W++
#    llama-smol-60358922_3-hp-W++
#)
#
#python3 ../fms_ehrs/scripts/transfer_rep_based_preds.py \
#    --data_dir_orig "${hm}/data-mimic" \
#    --data_dir_new "${hm}/data-ucmc" \
#    --data_version "W++_first_24h_${models[$j]}_${methods[$i]}_20pct" \
#    --model_loc "${hm}/mdls-archive/${models[$j]}" \
#    --classifier logistic_regression \
#    --drop_icu_adm \
#    --save_preds
