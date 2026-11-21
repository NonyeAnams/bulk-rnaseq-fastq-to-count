
#!/usr/bin/env bash

# ============================================================
# 02_quality_control.sh
#
# Perform quality control on raw FASTQ reads using FastQC.
#
# Input:
#   data/raw/SRR12352387.fastq.gz
#
# Output:
#   results/qc/SRR12352387_fastqc.html
#   results/qc/SRR12352387_fastqc.zip
# ============================================================

set -euo pipefail

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

ACCESSION="SRR12352387"
INPUT_FILE="data/raw/${ACCESSION}.fastq.gz"
OUTPUT_DIR="results/qc"

# Check required software
if ! command -v fastqc >/dev/null 2>&1; then
    echo "ERROR: FastQC is not installed or not in PATH."
    exit 1
fi

# Check input file
if [[ ! -s "$INPUT_FILE" ]]; then
    echo "ERROR: FASTQ input file not found: $INPUT_FILE"
    echo "Run scripts/01_download_reads.sh first."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Run FastQC
echo "Running FastQC on ${ACCESSION}..."

fastqc "$INPUT_FILE" --outdir "$OUTPUT_DIR"

# Confirm output files
HTML_REPORT="${OUTPUT_DIR}/${ACCESSION}_fastqc.html"
ZIP_REPORT="${OUTPUT_DIR}/${ACCESSION}_fastqc.zip"

if [[ ! -s "$HTML_REPORT" || ! -s "$ZIP_REPORT" ]]; then
    echo "ERROR: Expected FastQC reports were not generated."
    exit 1
fi

echo "Quality control completed."
echo "HTML report: $HTML_REPORT"
echo "ZIP report: $ZIP_REPORT"

