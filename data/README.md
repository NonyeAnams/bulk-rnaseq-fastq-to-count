# Input Data

## Dataset

The sequencing data used in this project were obtained from the NCBI Sequence Read Archive (SRA), associated with GEO dataset **GSE155432**.

The study investigates changes in mRNA poly(A) tails and 3′ untranslated regions during neuronal differentiation using human SH-SY5Y neuroblastoma cells.

### Selected sample

| Attribute | Information |
|---|---|
| GEO accession | GSE155432 |
| GEO sample | GSM4704322 |
| SRA experiment | SRX8851834 |
| SRA run | SRR12352387 |
| Organism | Homo sapiens |
| Cell line | SH-SY5Y |
| Condition | Undifferentiated |
| Sequencing platform | Illumina NextSeq 500 |
| Library layout | Single-end |
| Library selection | Poly(A)-selected mRNA |

## Subsampling

The original SRA run contains approximately 25.8 million spots.

For this computational demonstration, only the first 50,000 spots were retrieved using the NCBI SRA Toolkit.

This was a sequential subset, not random sampling.

The resulting compressed FASTQ file is:

`data/raw/SRR12352387.fastq.gz`

The FASTQ file is excluded from Git version control because raw sequencing data should be retrieved from the original public repository when reproducing the workflow.

## Downloading the data

The FASTQ subset can be retrieved using:

```bash
fastq-dump \
    --accession SRR12352387 \
    --minSpotId 1 \
    --maxSpotId 50000 \
    --gzip \
    --outdir data/raw
```

Alternatively, execute the project script:

```bash
./scripts/01_download_reads.sh
```

## Important considerations

- Only one sequencing run was processed.
- Only the first 50,000 spots were retrieved.
- The subset is intended to demonstrate the processing workflow, not to provide a representative expression profile.
- The original sequencing run contains substantially more reads than the subset analysed here.

## Data access

- GEO dataset: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE155432
- SRA run: https://www.ncbi.nlm.nih.gov/sra/?term=SRR12352387
- SRA Toolkit: https://github.com/ncbi/sra-tools
