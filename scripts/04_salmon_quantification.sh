
#!/usr/bin/env bash

# ============================================================
# 04_salmon_quantification.sh
#
# Quantify transcript abundances for six RNA-seq samples
# using Salmon.
#
# Input:
#   data/raw/SRR12352385.fastq.gz
#   ...
#   data/raw/SRR12352390.fastq.gz
#
# Reference:
#   reference/gencode19/salmon_index_gencode19/
#
# Output:
#   results/salmon/<ACCESSION>/
# ============================================================

set -euo pipefail

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Sample accessions
ACCESSIONS=(
    SRR12352385
    SRR12352386
    SRR12352387
    SRR12352388
    SRR12352389
    SRR12352390
)

INDEX_DIR="reference/gencode19/salmon_index_gencode19"
OUTPUT_BASE="results/salmon"

THREADS=4

# ------------------------------------------------------------
# 1. Check Salmon installation
# ------------------------------------------------------------

if ! command -v salmon >/dev/null 2>&1; then
    echo "ERROR: Salmon is not installed or not in PATH."
    exit 1
fi

echo "Salmon version:"
salmon --version

# ------------------------------------------------------------
# 2. Check reference index
# ------------------------------------------------------------

if [[ ! -s "${INDEX_DIR}/info.json" ]]; then
    echo "ERROR: Salmon index not found or incomplete."
    echo "Run scripts/03_prepare_reference.sh first."
    exit 1
fi

# ------------------------------------------------------------
# 3. Check all input FASTQ files before starting
# ------------------------------------------------------------

echo
echo "Checking input FASTQ files..."

for ACCESSION in "${ACCESSIONS[@]}"; do

    INPUT_FILE="data/raw/${ACCESSION}.fastq.gz"

    if [[ ! -s "$INPUT_FILE" ]]; then
        echo "ERROR: FASTQ file not found: $INPUT_FILE"
        exit 1
    fi

    echo "Found: $INPUT_FILE"

done

# ------------------------------------------------------------
# 4. Quantify each sample
# ------------------------------------------------------------

mkdir -p "$OUTPUT_BASE"

for ACCESSION in "${ACCESSIONS[@]}"; do

    INPUT_FILE="data/raw/${ACCESSION}.fastq.gz"
    OUTPUT_DIR="${OUTPUT_BASE}/${ACCESSION}"

    QUANT_FILE="${OUTPUT_DIR}/quant.sf"
    META_FILE="${OUTPUT_DIR}/aux_info/meta_info.json"

    echo
    echo "============================================================"
    echo "Sample: ${ACCESSION}"
    echo "============================================================"

    # Skip samples with complete existing results
    if [[ -s "$QUANT_FILE" && -s "$META_FILE" ]]; then

        echo "Existing Salmon results found."
        echo "Skipping quantification."

    elif [[ -e "$QUANT_FILE" || -e "$META_FILE" ]]; then

        echo "ERROR: Incomplete existing Salmon output for ${ACCESSION}."
        echo "Inspect: ${OUTPUT_DIR}"
        echo "Resolve the incomplete output before rerunning."
        exit 1

    else

        mkdir -p "$OUTPUT_DIR"

        echo "Starting Salmon quantification..."

        salmon quant \
            -i "$INDEX_DIR" \
            -l A \
            -r "$INPUT_FILE" \
            -p "$THREADS" \
            -o "$OUTPUT_DIR"

    fi

    # Validate output
    if [[ ! -s "$QUANT_FILE" || ! -s "$META_FILE" ]]; then
        echo "ERROR: Salmon output is missing or incomplete for ${ACCESSION}."
        exit 1
    fi

    echo
    echo "Quantification summary for ${ACCESSION}:"

    if command -v python >/dev/null 2>&1; then

        python - "$META_FILE" <<'PY'
import json
import sys

with open(sys.argv[1]) as f:
    data = json.load(f)

for key in (
    "num_processed",
    "num_mapped",
    "percent_mapped",
    "num_valid_targets",
    "library_types",
    "detected_library_type"
):
    if key in data:
        print(f"{key}: {data[key]}")
PY

    else
        echo "Python not found; skipping metadata summary."
    fi

    echo "Output: ${QUANT_FILE}"

done

# ------------------------------------------------------------
# 5. Final summary
# ------------------------------------------------------------

echo
echo "============================================================"
echo "All six Salmon quantification outputs are available."
echo "============================================================"

for ACCESSION in "${ACCESSIONS[@]}"; do

    QUANT_FILE="${OUTPUT_BASE}/${ACCESSION}/quant.sf"

    if [[ -s "$QUANT_FILE" ]]; then
        echo "OK: ${ACCESSION}"
    else
        echo "MISSING: ${ACCESSION}"
        exit 1
    fi

done

echo
echo "Results directory: ${OUTPUT_BASE}"

