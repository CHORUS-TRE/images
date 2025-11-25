#!/bin/bash
set -e

# Copy scripts to home
cp -r /apps/"${APP_NAME}"/benchmark* "$HOME"

# Copy scripts to all data mounts
for ws in "$HOME"/workspace-*; do
  if [ -d "$ws" ]; then
    cp -r /apps/"${APP_NAME}"/benchmark* "$ws"
  fi
done

# Run benchmarks in node storage
echo "=== Running benchmark(s) in node storage ==="
for script in "$HOME"/benchmark*; do
  echo "--- Running: $script ---"
  bash "$script"
done

# Run benchmarks in workspace storages
for ws in "$HOME"/workspace-*; do
  if [ -d "$ws" ]; then
    echo "=== Running benchmark(s) in $ws storage ==="
    for script in "$ws"/benchmark*; do
      echo "--- Running: $script ---"
      bash "$script"
    done
  fi
done
