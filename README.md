# Bulk RNA-seq Processing: FASTQ to Gene-Level Counts

## Overview

This project implements an upstream bulk RNA-seq processing workflow, starting with raw FASTQ reads and ending with gene-level expression matrices.

The workflow uses Linux command-line tools, Salmon and R/Bioconductor to demonstrate:

- Retrieval of public sequencing data from the NCBI Sequence Read Archive (SRA).
- Raw-read quality control using FastQC and MultiQC.
- Human transcriptome reference preparation using GENCODE.
- Transcript-level quantification using Salmon.
- Gene-level summarisation using tximport.

**This is a technical pipeline demonstration, not a complete biological reanalysis.**

## Dataset

Data were obtained from [GEO: GSE155432](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE155432), a study involving neuronal differentiation in human SH-SY5Y neuroblastoma cells.

| Feature | Description |
|---|---|
| Organism | Human (*Homo sapiens*) |
| Cell line | SH-SY5Y |
| Platform | Illumina NextSeq 500 |
| Library | Poly(A)-selected, single-end RNA-seq |
| Samples | 6 sequencing runs |
| Reference | GENCODE v19 (GRCh37/hg19 context) |

The six runs comprise three undifferentiated and three differentiated samples:

- **Undifferentiated:** SRR12352385, SRR12352386, SRR12352387
- **Differentiated:** SRR12352388, SRR12352389, SRR12352390

For computational efficiency, the first 50,000 reads from each run were processed. These are sequential subsets, not random samples of the original libraries.

## Workflow

| Step | Script | Purpose |
|---|---|---|
| 1 | `01_download_reads.sh` | Retrieve 50,000 reads per SRA run |
| 2 | `02_quality_control.sh` | Run FastQC and generate a MultiQC report |
| 3 | `03_prepare_reference.sh` | Prepare the transcript reference and Salmon index |
| 4 | `04_salmon_quantification.sh` | Quantify transcript abundance for all six samples |
| 5 | `05_import_gene_counts.R` | Import Salmon estimates and summarise to gene level with tximport |

All six samples were processed using the same reference index and quantification settings.

## Key Results

| Measurement | Result |
|---|---:|
| Samples processed | 6 |
| Reads processed per sample | 50,000 |
| Salmon mapping/quantification rate | 75.4–80.1% |
| Transcript targets in Salmon index | 118,149 |
| Genes in output matrices | 34,460 |
| Non-zero genes per sample | 8,329–8,673 |

The workflow generated three gene-level matrices:

| Output file | Contents |
|---|---|
| `gene_estimated_counts.csv` | Gene-level estimated counts |
| `gene_abundance_tpm.csv` | Gene-level TPM estimates |
| `gene_effective_lengths.csv` | Gene-level effective lengths |

The estimated count matrix is intended as the starting point for subsequent count-based RNA-seq analysis. TPM and effective-length matrices provide complementary abundance and transcript-length information.

## Repository Structure

```text
bulk-rnaseq-fastq-to-count/
├── data/
│   └── README.md
├── environment/
│   ├── environment.yml
│   ├── sessionInfo.txt
│   └── README.md
├── reference/
│   ├── gencode19/
│   │   └── gencode.v19.tx2gene.tsv
│   └── README.md
├── results/
│   ├── qc/
│   ├── salmon/
│   └── gene_counts/
├── scripts/
│   ├── 01_download_reads.sh
│   ├── 02_quality_control.sh
│   ├── 03_prepare_reference.sh
│   ├── 04_salmon_quantification.sh
│   └── 05_import_gene_counts.R
├── .gitignore
└── README.md
```

Large raw FASTQ files, reference files and the Salmon index are excluded from version control. The relevant README files explain how to obtain or prepare these inputs.

## Running the Workflow

Clone the repository:

```bash
git clone https://github.com/NonyeAnams/bulk-rnaseq-fastq-to-count.git
cd bulk-rnaseq-fastq-to-count
```

After setting up the required software and reference files, run:

```bash
bash scripts/01_download_reads.sh
bash scripts/02_quality_control.sh
bash scripts/03_prepare_reference.sh
bash scripts/04_salmon_quantification.sh
Rscript scripts/05_import_gene_counts.R
```

See the `data/`, `reference/` and `environment/` directories for the corresponding setup instructions.

## Limitations

- Only the first 50,000 sequential reads per sample were processed. Results are not representative of the complete sequencing libraries.
- The Salmon index uses transcript sequences without genomic decoy sequences.
- GENCODE v19 is an older reference annotation.
- The workflow does not include additional read trimming.
- Salmon produces estimated counts, which may be fractional.
- No normalisation, exploratory biological analysis or differential expression testing has been performed.

Consequently, the resulting matrices demonstrate successful upstream processing but should not be used to draw biological conclusions about neuronal differentiation.

## Software

The workflow was developed in Ubuntu 24.04.1 LTS under WSL2.

| Software | Version |
|---|---|
| R | 4.5.3 |
| Salmon | 2.9.0 |
| FastQC | 0.13.0 |
| MultiQC | 1.35 |
| tximport | 1.38.2 |
| SRA Toolkit | 3.4.1 |

## Resources

- [GEO: GSE155432](https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE155432)
- [NCBI SRA](https://www.ncbi.nlm.nih.gov/sra)
- [GENCODE Release 19](https://www.gencodegenes.org/human/release_19.html)
- [Salmon documentation](https://salmon.readthedocs.io/)
- [tximport documentation](https://bioconductor.org/packages/tximport/)
- [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
- [MultiQC](https://multiqc.info/)
