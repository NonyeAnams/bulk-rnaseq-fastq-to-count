# Bulk RNA-seq Processing: From Raw FASTQ Reads to Gene-Level Count Matrix

## 1. Project Overview

This project demonstrates an end-to-end upstream bulk RNA-seq processing workflow, starting with raw sequencing reads in FASTQ format and ending with a gene-level estimated count matrix.

The workflow covers:

- Retrieval of public RNA-seq sequencing data from the NCBI Sequence Read Archive (SRA).
- Raw-read quality assessment using FastQC.
- Preparation of a human transcriptome reference using GENCODE.
- Transcript-level abundance quantification using Salmon.
- Summarisation of transcript-level estimates into gene-level matrices using tximport.

The primary objective is to demonstrate practical competence in processing RNA-seq data from raw sequencing reads to gene-level quantification.

This is a computational demonstration using a small subset of a public dataset, rather than a complete biological reanalysis.

## 2. Dataset and Biological Context

The data were obtained from the Gene Expression Omnibus (GEO) dataset **GSE155432**.

The study investigates changes in mRNA poly(A) tails and 3′ untranslated regions during neuronal differentiation, using human SH-SY5Y neuroblastoma cells.

| Attribute | Description |
|---|---|
| Organism | Homo sapiens |
| Cell line | SH-SY5Y neuroblastoma |
| Sequencing platform | Illumina NextSeq 500 |
| Library strategy | RNA-Seq |
| Library selection | Poly(A)-selected mRNA |
| Library layout | Single-end |
| Selected condition | Undifferentiated |
| GEO accession | GSE155432 |
| Selected SRA run | SRR12352387 |
| SRA experiment | SRX8851834 |

The original dataset contains six sequencing runs:

- Undifferentiated: SRR12352385, SRR12352386, SRR12352387
- Differentiated: SRR12352388, SRR12352389, SRR12352390

Only SRR12352387 was processed in this demonstration.

### Subsampling strategy

The original sequencing run contains approximately 25.8 million spots. Due to computational and storage considerations, the first 50,000 spots were retrieved using the NCBI SRA Toolkit.

Consequently, the analysis represents a technical demonstration of the processing workflow and should not be interpreted as a comprehensive expression profile of the original biological sample.

## 3. Computational Workflow

### Step 1: Retrieval of raw sequencing reads

Raw sequencing data were retrieved from the SRA using `fastq-dump`.

The first 50,000 spots were extracted from SRR12352387 and saved in compressed FASTQ format.

Output:

`data/raw/SRR12352387.fastq.gz`

### Step 2: Raw-read quality assessment

FastQC was used to assess sequencing quality before quantification.

The assessment included:

- Per-base sequence quality.
- Per-sequence quality scores.
- Per-base sequence composition.
- GC content distribution.
- Sequence length distribution.
- Sequence duplication levels.
- Adapter content.
- Ambiguous nucleotide (N) content.

The FastQC report showed generally good base quality, with warnings for per-base sequence content and sequence length distribution.

No adapter contamination or overrepresented sequences were detected.

No additional trimming was performed as part of this workflow.

Outputs:

- `results/qc/SRR12352387_fastqc.html`
- `results/qc/SRR12352387_fastqc.zip`

### Step 3: Reference transcriptome preparation

GENCODE release 19 was selected as the human reference annotation, compatible with the GRCh37/hg19 assembly context.

The following reference files were obtained:

- Protein-coding transcript sequences.
- Long non-coding RNA transcript sequences.
- GENCODE gene annotation (GTF).

The protein-coding and lncRNA transcript FASTA files were combined to create a transcriptome reference.

A transcript-to-gene mapping table was generated from the FASTA headers. This mapping links Ensembl transcript identifiers to their corresponding gene identifiers.

The resulting reference contained 119,207 transcript records and 119,207 transcript-to-gene mapping entries.

### Step 4: Salmon index construction

A Salmon index was constructed from the combined transcriptome FASTA.

The index was generated using:

- Salmon 2.9.0.
- k-mer length of 31.
- Four computational threads.
- GENCODE-compatible transcript identifiers.

A transcriptome-only index was used; genomic decoy sequences were not included.

### Step 5: Transcript-level quantification

Salmon was used to estimate transcript abundance from the raw FASTQ reads.

Automatic library-type detection was enabled using `-l A`.

Salmon identified the library type as `SR` (single-end reverse-stranded).

The quantification generated transcript-level estimates, including:

- Transcript abundance (TPM).
- Estimated counts (`NumReads`).
- Effective transcript lengths.

The final quantification reported 38,637 quantified fragments from 50,000 input reads, corresponding to approximately 77.27%.

Primary output:

`results/salmon/SRR12352387/quant.sf`

### Step 6: Gene-level summarisation

The R/Bioconductor package `tximport` was used to summarise transcript-level estimates into gene-level matrices.

The transcript-to-gene mapping generated during reference preparation was supplied to tximport.

Inferential replicates were not imported (`dropInfReps = TRUE`).

Three gene-level matrices were generated:

| Output | Description |
|---|---|
| `gene_estimated_counts.csv` | Gene-level estimated counts |
| `gene_abundance_tpm.csv` | Gene-level abundance estimates (TPM) |
| `gene_effective_lengths.csv` | Gene-level effective lengths |

The primary output is the gene-level estimated count matrix.

## 4. Results

The processing workflow successfully generated gene-level quantification estimates.

### Summary of processing results

| Measurement | Result |
|---|---:|
| Input reads | 50,000 |
| Quantified fragments | 38,637 |
| Quantification rate | 77.27% |
| Indexed transcript references | 118,149 |
| Gene-level rows | 34,460 |
| Samples | 1 |
| Genes with non-zero estimated counts | 8,636 |

The resulting gene-level estimated count matrix contains 34,460 genes and one sample.

The sum of the gene-level estimated counts is 38,637, consistent with the final number of quantified fragments reported by Salmon.

These results demonstrate successful progression from raw sequencing reads through transcript-level quantification to gene-level summarisation.

The values are estimates generated by Salmon and tximport, not direct integer counts obtained from a conventional genome-alignment and read-counting workflow.

## 5. Repository Structure

```text
bulk-rnaseq-fastq-to-counts/
│
├── README.md
│
├── data/
│   ├── raw/
│   └── README.md
│
├── reference/
│   ├── gencode19/
│   └── README.md
│
├── scripts/
│   ├── 01_download_reads.sh
│   ├── 02_quality_control.sh
│   ├── 03_prepare_reference.sh
│   ├── 04_salmon_quantification.sh
│   └── 05_import_gene_counts.R
│
├── results/
│   ├── qc/
│   ├── salmon/
│   └── gene_counts/
│
├── figures/
│
├── docs/
│
├── environment/
│
└── .gitignore
```

Large raw sequencing files, downloaded reference FASTA/GTF files and the Salmon index are excluded from version control. Instructions for obtaining or regenerating these files are provided in the accompanying documentation.

## 6. Reproducibility

### Requirements

The workflow was developed and executed in Ubuntu 24.04.1 LTS under WSL2.

The principal software and packages used include:

| Software | Version |
|---|---|
| R | 4.5.3 |
| FastQC | 0.13.0 |
| Salmon | 2.9.0 |
| tximport | 1.38.2 |
| SRA Toolkit | 3.4.1 |
| seqtk | 1.5-r133 |

Additional dependencies include Bash, curl, gzip and standard Linux command-line utilities.

### Running the workflow

Clone the repository and navigate to its root directory.

Execute the scripts in the following order:

```bash
# 1. Retrieve raw sequencing reads
./scripts/01_download_reads.sh

# 2. Assess raw-read quality
./scripts/02_quality_control.sh

# 3. Prepare reference and build Salmon index
./scripts/03_prepare_reference.sh

# 4. Quantify transcript abundance
./scripts/04_salmon_quantification.sh

# 5. Generate gene-level matrices
Rscript scripts/05_import_gene_counts.R
```

The required reference files and computational environment must be available before executing the workflow. See the `data/`, `reference/` and `environment/` documentation.

## 7. Limitations

Several limitations should be considered when interpreting the results:

1. **Subsampled sequencing data:** Only the first 50,000 spots from the original sequencing run were processed. This is not a random or representative subsample.

2. **Single sample:** Only one undifferentiated sample was analysed. No biological comparisons or differential expression analysis were performed.

3. **Transcriptome-only reference index:** The Salmon index did not include genomic decoy sequences. A decoy-aware index would generally be preferable for more robust quantification.

4. **Single-end sequencing:** Salmon used a fragment-length prior for single-end quantification rather than directly observing paired-end fragment lengths.

5. **Reference annotation:** GENCODE v19 is an older annotation release, selected to maintain compatibility with the GRCh37/hg19 reference context.

6. **Inferential replicates:** Inferential replicates were not imported during tximport summarisation.

7. **No additional trimming:** The workflow assessed raw-read quality but did not perform additional adapter or quality trimming.

The results should therefore be interpreted as evidence of a functioning upstream RNA-seq processing workflow, not as a definitive biological expression analysis.

## 8. Conclusion

This project demonstrates an upstream bulk RNA-seq processing workflow, beginning with public raw FASTQ data and ending with gene-level estimated count matrices.

The workflow integrates Linux command-line tools, reference preparation, transcript-level quantification and R/Bioconductor summarisation.

It provides a reproducible foundation for subsequent downstream RNA-seq analyses, including normalisation, exploratory data analysis and differential expression testing.

## 9. Data and Reference Resources

- GEO dataset: https://www.ncbi.nlm.nih.gov/geo/query/acc.cgi?acc=GSE155432
- SRA run: https://www.ncbi.nlm.nih.gov/sra/?term=SRR12352387
- GENCODE release 19: https://www.gencodegenes.org/human/release_19.html
- Salmon documentation: https://salmon.readthedocs.io/
- tximport documentation: https://bioconductor.org/packages/tximport/
- FastQC: https://www.bioinformatics.babraham.ac.uk/projects/fastqc/
