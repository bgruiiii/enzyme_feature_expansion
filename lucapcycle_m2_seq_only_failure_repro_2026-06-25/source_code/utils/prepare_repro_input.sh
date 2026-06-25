#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <training_unique_uniprot_sequences_107731.csv.gz> <output_csv>" >&2
  exit 2
fi

INPUT_GZ="$1"
OUTPUT_CSV="$2"

if [ ! -f "$INPUT_GZ" ]; then
  echo "Missing input gzip: $INPUT_GZ" >&2
  exit 3
fi

mkdir -p "$(dirname "$OUTPUT_CSV")"
gzip -dc "$INPUT_GZ" > "$OUTPUT_CSV"

echo "WROTE=$OUTPUT_CSV"
echo "ROWS_WITH_HEADER=$(wc -l < "$OUTPUT_CSV")"
