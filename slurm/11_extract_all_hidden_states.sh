#!/bin/bash

#SBATCH --job-name=all-states
#SBATCH --output=./output/%A_%a-%x.stdout
#SBATCH --partition=gpuq
#SBATCH --gres=gpu:2
#SBATCH --time=24:00:00
#SBATCH --array=0-1

source preamble.sh

div=2
quo=$((SLURM_ARRAY_TASK_ID / div))
rem=$((SLURM_ARRAY_TASK_ID % div))

data_dirs=(
    "${hm}/data-mimic"
    "${hm}/data-ucmc"
)
out_dirs=(
    "/scratch/burkh4rt/data-mimic"
    "/scratch/burkh4rt/data-ucmc"
)

torchrun --nproc_per_node=2 \
    --rdzv_backend c10d \
    --rdzv-id "$SLURM_ARRAY_TASK_ID" \
    --rdzv-endpoint=localhost:0 \
    ../fms_ehrs/scripts/extract_all_hidden_states.py \
    --data_dir "${data_dirs[$rem]}" \
    --out_dir "${out_dirs[$rem]}" \
    --data_version "QC_day_stays_first_24h" \
    --model_loc "${hm}/mdls-archive/llama1b-57928921-run1" \
    --small_batch_sz $((2 ** 4)) \
    --big_batch_sz $((2 ** 12))
