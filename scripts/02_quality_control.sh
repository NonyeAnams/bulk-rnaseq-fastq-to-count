
#!/usr/bin/env bash

# ============================================================
# 02_quality_control.sh
#
# Perform quality control on six FASTQ files using FastQC.
# Summarise all FastQC results using MultiQC.
#
# Input:
#   data/raw/<ACCESSION>.fastq.gz
#
# Output:
#   results/qc/<ACCESSION>_fastqc.html
#   results/qc/<ACCESSION>_fastqc.zip
#   results/qc/multiqc_report.html
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

INPUT_DIR="data/raw"
OUTPUT_DIR="results/qc"

# Check required software
if ! command -v fastqc >/dev/null 2>&1; then
    echo "ERROR: FastQC is not installed or not in PATH."
    exit 1
fi

if ! command -v conda >/dev/null 2>&1; then
    echo "ERROR: Conda was not found."
    exit 1
fi

# Confirm MultiQC environment exists
if ! conda env list | awk '{print $1}' | grep -qx "multiqc-env"; then
    echo "ERROR: Conda environment 'multiqc-env' was not found."
    echo "Create it before running this script."
    exit 1
fi

# Confirm MultiQC is available in its environment
if ! conda run -n multiqc-env multiqc --version >/dev/null 2>&1; then
    echo "ERROR: MultiQC could not be executed."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Check all input FASTQ files before starting
for ACCESSION in "${ACCESSIONS[@]}"; do
    INPUT_FILE="${INPUT_DIR}/${ACCESSION}.fastq.gz"

    if [[ ! -s "$INPUT_FILE" ]]; then
        echo "ERROR: FASTQ input file not found: $INPUT_FILE"
        echo "Run scripts/01_download_reads.sh first."
        exit 1
    fi
done

echo "All six FASTQ input files found."

# Run FastQC on all six samples
for ACCESSION in "${ACCESSIONS[@]}"; do

    INPUT_FILE="${INPUT_DIR}/${ACCESSION}.fastq.gz"

    echo ""
    echo "Running FastQC on ${ACCESSION}..."

    fastqc \
        "$INPUT_FILE" \
        --outdir "$OUTPUT_DIR"

    HTML_REPORT="${OUTPUT_DIR}/${ACCESSION}_fastqc.html"
    ZIP_REPORT="${OUTPUT_DIR}/${ACCESSION}_fastqc.zip"

    # Confirm individual reports were generated
    if [[ ! -s "$HTML_REPORT" || ! -s "$ZIP_REPORT" ]]; then
        echo "ERROR: FastQC reports were not generated for $ACCESSION."
        exit 1
    fi

    echo "FastQC completed for ${ACCESSION}."

done

# Generate consolidated MultiQC report
echo ""
echo "Generating consolidated MultiQC report..."

conda run -n multiqc-env multiqc \
    "$OUTPUT_DIR" \
    --outdir "$OUTPUT_DIR" \
    --filename multiqc_report.html \
    --force

MULTIQC_REPORT="${OUTPUT_DIR}/multiqc_report.html"

if [[ ! -s "$MULTIQC_REPORT" ]]; then
    echo "ERROR: MultiQC report was not generated."
    exit 1
fi

echo ""
echo "============================================================"
echo "Quality control completed successfully."
echo "============================================================"
echo "Samples processed: ${#ACCESSIONS[@]}"
echo "Individual FastQC reports: $OUTPUT_DIR"
echo "Combined MultiQC report: $MULTIQC_REPORT"

