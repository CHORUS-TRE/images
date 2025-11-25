#!/bin/bash
set -euo pipefail

BLOCK_SIZE="1M"
FILE_SIZE_MB=5120  # 5 GiB
MID_OFFSET_MB=$((FILE_SIZE_MB / 2))

generate_file() {
  local filename="./stream_test_$(date +%s%N).img"
  echo "Generating fresh test file: $filename"
  dd if=/dev/urandom of="$filename" bs=$BLOCK_SIZE count=$FILE_SIZE_MB status=none
  sync
  REPLY="$filename"
}

measure_read_time() {
  local file="$1"
  local skip_blocks="$2"
  local count_blocks="$3"

  local start=$(date +%s.%N)
  dd if="$file" of=/dev/null bs=$BLOCK_SIZE skip=$skip_blocks count=$count_blocks status=none
  local end=$(date +%s.%N)
  echo "$(echo "$end - $start" | bc -l)"
}

echo "==> Starting benchmark"

# --- Middle Read ---
generate_file
file1="$REPLY"
echo "Middle read test (100 MiB from middle of $file1)..."
duration_mid=$(measure_read_time "$file1" "$MID_OFFSET_MB" 100)
echo "Middle read duration: ${duration_mid}s"
rm -f "$file1"
echo

# --- Full Read ---
generate_file
file2="$REPLY"
echo "Full read test (entire $file2)..."
duration_full=$(measure_read_time "$file2" 0 "$FILE_SIZE_MB")
echo "Full read duration: ${duration_full}s"
rm -f "$file2"
echo

# --- Analysis ---
echo "==> Evaluation:"
percent=$(echo "$duration_mid / $duration_full * 100" | bc -l)
printf "Partial read is %.2f%% of full read time\n" "$percent"

if (( $(echo "$percent < 60" | bc -l) )); then
  echo "Filesystem likely supports streaming (partial reads are efficient)"
else
  echo "Filesystem likely does NOT support streaming (entire file may be fetched)"
fi
