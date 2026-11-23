# Software Environment

## Environment

The workflow was developed using Conda on Ubuntu 24.04.1 LTS under WSL2.

The `environment.yml` file specifies the main software dependencies.

| Software | Version | Purpose |
|---|---:|---|
| R | 4.5.3 | Gene-level matrix generation |
| tximport | 1.38.2 | Transcript-to-gene summarisation |
| Salmon | 2.9.0 | Transcript quantification |
| FastQC | 0.13.0 | Read quality control |
| SRA Toolkit | 3.4.1 | FASTQ retrieval |

MultiQC 1.35 is installed in a separate Conda environment.

## Setup

Create and activate the main environment:

```bash
conda env create -f environment/environment.yml
conda activate rnaseq-processing
```

Create the separate MultiQC environment:

```bash
conda create -n multiqc-env -c conda-forge -c bioconda multiqc=1.35
```

Run MultiQC with:

```bash
conda run -n multiqc-env multiqc results/qc/ -o results/qc/
```

## Reproducibility

The file `sessionInfo.txt` records the R version, platform and package information from the analysis.

Conda dependency resolution may produce different compatible transitive package versions over time.
