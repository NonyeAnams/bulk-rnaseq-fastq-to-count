
#!/usr/bin/env bash

# ============================================================
# 01_download_reads.sh
#
# Download the first 50,000 spots from six SRA runs.
#
# Biological groups:
#   Undifferentiated: SRR12352385, SRR12352386, SRR12352387
#   Differentiated:   SRR12352388, SRR12352389, SRR12352390
#
# Output:
#   data/raw/<ACCESSION>.fastq.gz
# ============================================================

set -euo pipefail

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

# Download settings
ACCESSIONS=(
    SRR12352385
    SRR12352386
    SRR12352387
    SRR12352388
    SRR12352389
    SRR12352390
)

EXPECTED_READS=50000
OUTPUT_DIR="data/raw"

# Temporary directory used during downloads
TMP_DIR=""

# Clean up temporary files if the script exits
cleanup() {
    if [[ -n "$TMP_DIR" && -d "$TMP_DIR" ]]; then
        rm -rf "$TMP_DIR"
    fi
}
trap cleanup EXIT

# Check that SRA Toolkit is installed
if ! command -v fastq-dump >/dev/null 2>&1; then
    echo "ERROR: fastq-dump was not found."
    echo "Install the NCBI SRA Toolkit before continuing."
    exit 1
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Validate a FASTQ file and return its read count
validate_fastq() {
    local file="$1"
    local read_count

    gzip -t "$file"

    read_count=$(zcat "$file" | awk '
        END {
            if (NR % 4 != 0) {
                exit 1
            }
            print NR / 4
        }
    ')

    if [[ "$read_count" -ne "$EXPECTED_READS" ]]; then
        echo "ERROR: Expected $EXPECTED_READS reads but found $read_count in $file" >&2
        return 1
    fi

    printf '%s\n' "$read_count"
}

# Process each accession
for ACCESSION in "${ACCESSIONS[@]}"; do

    OUTPUT_FILE="${OUTPUT_DIR}/${ACCESSION}.fastq.gz"

    echo ""
    echo "============================================================"
    echo "Processing ${ACCESSION}"
    echo "============================================================"

    # Check whether a valid FASTQ already exists
    if [[ -s "$OUTPUT_FILE" ]]; then
        if READ_COUNT=$(validate_fastq "$OUTPUT_FILE"); then
            echo "Valid FASTQ already exists. Skipping download."
            echo "Reads: $READ_COUNT"
            continue
        else
            echo "Existing FASTQ is invalid. Removing it before redownloading."
            rm -f "$OUTPUT_FILE"
        fi
    fi

    # Download into a temporary directory
    TMP_DIR=$(mktemp -d "${OUTPUT_DIR}/.${ACCESSION}.XXXXXX")

    echo "Downloading the first ${EXPECTED_READS} spots..."

    fastq-dump \
        --accession "$ACCESSION" \
        --minSpotId 1 \
        --maxSpotId "$EXPECTED_READS" \
        --gzip \
        --outdir "$TMP_DIR"

    TEMP_FILE="${TMP_DIR}/${ACCESSION}.fastq.gz"

    # Check that the expected output was created
    if [[ ! -s "$TEMP_FILE" ]]; then
        echo "ERROR: Expected FASTQ output was not created for $ACCESSION."
        exit 1
    fi

    # Validate before moving into the final output directory
    READ_COUNT=$(validate_fastq "$TEMP_FILE")

    # Move validated file into its final location
    mv "$TEMP_FILE" "$OUTPUT_FILE"

    # Remove the now-empty temporary directory
    rmdir "$TMP_DIR"
    TMP_DIR=""

    echo "Download and validation completed."
    echo "Accession: $ACCESSION"
    echo "Reads: $READ_COUNT"
    echo "Output: $OUTPUT_FILE"

done

echo ""
echo "============================================================"
echo "All six FASTQ files have been processed successfully."
echo "============================================================"

