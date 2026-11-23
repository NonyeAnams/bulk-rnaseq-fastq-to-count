# Input Data

## Dataset

Sequencing data were obtained from [GEO: GSE155432](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE155432), a study of neuronal differentiation in human SH-SY5Y neuroblastoma cells.

Six single-end RNA-seq runs were used:

| Condition | SRA accessions |
|---|---|
| Undifferentiated | SRR12352385, SRR12352386, SRR12352387 |
| Differentiated | SRR12352388, SRR12352389, SRR12352390 |

The libraries are poly(A)-selected and were sequenced using Illumina NextSeq 500.

## Subsampling

The first **50,000 reads** from each run were retrieved using the NCBI SRA Toolkit.

These are sequential subsets, not random samples of the original sequencing libraries. They are intended for demonstrating the processing workflow, not for biological inference.

## Downloading

From the project root, run:

```bash
bash scripts/01_download_reads.sh
```

FASTQ files are saved in `data/raw/` and excluded from Git version control.

## Data resources

- [GEO dataset GSE155432](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE155432)
- [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra)
- [SRA Toolkit](https://github.com/ncbi/sra-tools)
