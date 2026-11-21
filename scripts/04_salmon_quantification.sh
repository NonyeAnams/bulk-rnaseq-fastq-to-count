
#!/usr/bin/env bash

# ============================================================
# 04_salmon_quantification.sh
#
# Quantify transcript abundances using Salmon.
#
# Input:
#   data/raw/SRR12352387.fastq.gz
#   reference/gencode19/salmon_index_gencode19/
#
# Output:
#   results/salmon/SRR12352387/
# ============================================================

set -euo pipefail

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

ACCESSION="SRR12352387"
INPUT_FILE="data/raw/${ACCESSION}.fastq.gz"
INDEX_DIR="reference/gencode19/salmon_index_gencode19"
OUTPUT_DIR="results/salmon/${ACCESSION}"

THREADS=4

# Check Salmon installation
if ! command -v salmon >/dev/null 2>&1; then
    echo "ERROR: Salmon is not installed or not in PATH."
    exit 1
fi

# Check input FASTQ
if [[ ! -s "$INPUT_FILE" ]]; then
    echo "ERROR: FASTQ file not found: $INPUT_FILE"
    exit 1
fi

# Check Salmon index
if [[ ! -s "${INDEX_DIR}/info.json" ]]; then
    echo "ERROR: Salmon index not found or incomplete."
    echo "Run scripts/03_prepare_reference.sh first."
    exit 1
fi

# Avoid accidentally overwriting existing results
if [[ -s "${OUTPUT_DIR}/quant.sf" ]]; then
    echo "Salmon quantification already exists."
    echo "Output: ${OUTPUT_DIR}/quant.sf"
    echo "Skipping quantification."
    exit 0
fi

mkdir -p "$OUTPUT_DIR"

# Run Salmon quantification
echo "Starting Salmon quantification for ${ACCESSION}..."

salmon quant \
    -i "$INDEX_DIR" \
    -l A \
    -r "$INPUT_FILE" \
    -p "$THREADS" \
    -o "$OUTPUT_DIR"

# Validate output
if [[ ! -s "${OUTPUT_DIR}/quant.sf" ]]; then
    echo "ERROR: Salmon quant.sf was not generated."
    exit 1
fi

# Extract quantification statistics
echo
echo "Salmon quantification completed."
echo "Output: ${OUTPUT_DIR}/quant.sf"

echo
echo "Quantification summary:"

if command -v python >/dev/null 2>&1; then
    python -c '
import json
with open("'"${OUTPUT_DIR}"'/aux_info/meta_info.json") as f:
    data = json.load(f)

for key in ("num_processed", "num_mapped", "percent_mapped",
            "num_valid_targets", "library_types", "detected_library_type"):
    if key in data:
        print(f"{key}: {data[key]}")
'
fi

