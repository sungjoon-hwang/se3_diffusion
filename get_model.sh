#!/bin/bash

base_dir=$(pwd)
exp_dir=$1

chk_dir="${base_dir}/logs/${exp_dir}/checkpoints"
sum_dir="${base_dir}/logs/${exp_dir}/summaries"
to_dir="${base_dir}/data/models/${exp_dir}"

# Sort filenames by the integer after "model_epoch"
models=($(ls -1 "$chk_dir"))
sorted=($(
    for file in "${models[@]}"; do
        echo "$file"
    done | sed -r 's/model_epoch_([0-9]+)_.*$/\1 \0/' | sort -n | cut -d' ' -f2-
))

# Get the last file in the sorted list
latest_model="${sorted[-1]}"

# Construct the full path to the latest model file
model_path="${chk_dir}/${latest_model}"

# Check if the latest model file exists
if [ -f "$model_path" ]; then
    if [ ! -d "$to_dir" ]; then
        # Create the directory
        mkdir "$to_dir"
        echo "Directory created: $to_dir"

        # necessary parameter to load checkpoint
        cp "${base_dir}/data/models/params.json" "$to_dir"
    fi

    # metadata
    fname="${to_dir}/model.txt"
    echo "$latest_model" > "$fname"

    # Copy the latest model file to the destination directory
    cp "$model_path" "$to_dir/model.pth"
    echo "Copied $model_path to $to_dir/$latest_model"
else
    echo "Error: Latest model file $model_path not found."
    exit 1
fi
