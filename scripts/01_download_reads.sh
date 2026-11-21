
#!/usr/bin/env bash

# ============================================================
# 01_download_reads.sh
#
# Download a subset of SRR12352387 from the NCBI SRA.
# The first 50,000 spots are retrieved for this demonstration.
#
# Output:
#   data/raw/SRR12352387.fastq.gz
# ============================================================

set -euo pipefail

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

ACCESSION="SRR12352387"
OUTPUT_DIR="data/raw"
OUTPUT_FILE="${OUTPUT_DIR}/${ACCESSION}.fastq.gz"

# Check that SRA Toolkit is installed
if ! command -v fastq-dump >/dev/null 2>&1; then
    echo "ERROR: fastq-dump was not found."
    echo "Install the NCBI SRA Toolkit before continuing."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Avoid downloading again if the FASTQ already exists
if [[ -s "$OUTPUT_FILE" ]]; then
    echo "FASTQ file already exists: $OUTPUT_FILE"
    echo "Skipping download."
else
    echo "Downloading the first 50,000 spots from $ACCESSION..."

    fastq-dump \
        --accession "$ACCESSION" \
        --minSpotId 1 \
        --maxSpotId 50000 \
        --gzip \
        --outdir "$OUTPUT_DIR"
fi

# Validate compressed FASTQ file
if [[ ! -s "$OUTPUT_FILE" ]]; then
    echo "ERROR: Expected FASTQ output was not created."
    exit 1
fi

gzip -t "$OUTPUT_FILE"

# Count FASTQ reads
READ_COUNT=$(zcat "$OUTPUT_FILE" | awk 'END {print NR/4}')

if [[ "$READ_COUNT" -ne 50000 ]]; then
    echo "ERROR: Expected 50,000 reads but found $READ_COUNT."
    exit 1
fi

echo "Download and validation completed."
echo "Accession: $ACCESSION"
echo "Reads: $READ_COUNT"
echo "Output: $OUTPUT_FILE"

