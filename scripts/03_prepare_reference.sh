
#!/usr/bin/env bash

# ============================================================
# 03_prepare_reference.sh
#
# Prepare the GENCODE v19 transcript reference and build
# a Salmon index.
#
# Reference assembly:
#   GRCh37 / hg19
#
# Outputs:
#   reference/gencode19/gencode.v19.transcripts.fa.gz
#   reference/gencode19/gencode.v19.tx2gene.tsv
#   reference/gencode19/salmon_index_gencode19/
# ============================================================

set -euo pipefail

# Locate project root
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

REFERENCE_DIR="reference/gencode19"
INDEX_DIR="${REFERENCE_DIR}/salmon_index_gencode19"

# Reference download base URL
BASE_URL="https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_19"

PC_FASTA="${REFERENCE_DIR}/gencode.v19.pc_transcripts.fa.gz"
LNCRNA_FASTA="${REFERENCE_DIR}/gencode.v19.lncRNA_transcripts.fa.gz"
ANNOTATION_GTF="${REFERENCE_DIR}/gencode.v19.annotation.gtf.gz"

COMBINED_FASTA="${REFERENCE_DIR}/gencode.v19.transcripts.fa.gz"
TX2GENE="${REFERENCE_DIR}/gencode.v19.tx2gene.tsv"

# Number of CPU threads
THREADS=4

# Check required software
for tool in curl gzip awk salmon; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: Required tool not found: $tool"
        exit 1
    fi
done

mkdir -p "$REFERENCE_DIR"

# ------------------------------------------------------------
# 1. Download reference files if they do not already exist
# ------------------------------------------------------------

download_reference() {
    local url="$1"
    local output="$2"

    if [[ -s "$output" ]]; then
        echo "Already present: $output"
    else
        echo "Downloading: $output"

        curl -fL --retry 3 "$url" -o "$output"

        if [[ ! -s "$output" ]]; then
            echo "ERROR: Download failed: $output"
            exit 1
        fi
    fi

    gzip -t "$output"
}

download_reference \
    "${BASE_URL}/gencode.v19.pc_transcripts.fa.gz" \
    "$PC_FASTA"

download_reference \
    "${BASE_URL}/gencode.v19.lncRNA_transcripts.fa.gz" \
    "$LNCRNA_FASTA"

download_reference \
    "${BASE_URL}/gencode.v19.annotation.gtf.gz" \
    "$ANNOTATION_GTF"

# ------------------------------------------------------------
# 2. Combine protein-coding and lncRNA transcript FASTAs
# ------------------------------------------------------------

if [[ -s "$COMBINED_FASTA" ]]; then
    echo "Combined transcript FASTA already exists."
else
    echo "Combining transcript FASTA files..."

    zcat "$PC_FASTA" "$LNCRNA_FASTA" | gzip -c > "$COMBINED_FASTA"
fi

gzip -t "$COMBINED_FASTA"

# ------------------------------------------------------------
# 3. Generate transcript-to-gene mapping
# ------------------------------------------------------------

if [[ -s "$TX2GENE" ]]; then
    echo "Transcript-to-gene mapping already exists."
else
    echo "Generating transcript-to-gene mapping..."

    {
        printf "TXNAME\tGENEID\n"

        zcat "$COMBINED_FASTA" |
        awk '/^>/ {
            split(substr($0, 2), fields, "|")

            if (fields[1] != "" && fields[2] != "" && fields[2] != "-")
                print fields[1] "\t" fields[2]
        }'
    } > "$TX2GENE"
fi

# ------------------------------------------------------------
# 4. Build Salmon index
# ------------------------------------------------------------

if [[ -s "${INDEX_DIR}/info.json" ]]; then
    echo "Salmon index already exists. Skipping index construction."
else
    echo "Building Salmon index..."

    salmon index \
        -t "$COMBINED_FASTA" \
        -i "$INDEX_DIR" \
        --gencode \
        -k 31 \
        -p "$THREADS"
fi

# ------------------------------------------------------------
# 5. Report reference statistics
# ------------------------------------------------------------

TRANSCRIPT_COUNT=$(zcat "$COMBINED_FASTA" | grep -c '^>')
MAPPING_COUNT=$(awk 'NR > 1 {count++} END {print count+0}' "$TX2GENE")

echo
echo "Reference preparation completed."
echo "Transcript sequences: $TRANSCRIPT_COUNT"
echo "Transcript-to-gene mappings: $MAPPING_COUNT"
echo "Combined FASTA: $COMBINED_FASTA"
echo "Mapping file: $TX2GENE"
echo "Salmon index: $INDEX_DIR"

