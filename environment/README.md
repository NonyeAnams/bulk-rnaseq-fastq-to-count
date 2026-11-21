# Software Environment

## Environment specification

The RNA-seq processing workflow was developed and tested using Conda on Ubuntu 24.04.1 LTS under WSL2.

The file `environment.yml` specifies the main software dependencies and versions used in the project.

## Main software

| Software | Version | Purpose |
|---|---:|---|
| R | 4.5.3 | Gene-level import and matrix generation |
| tximport | 1.38.2 | Transcript-to-gene summarisation |
| FastQC | 0.13.0 | Raw-read quality control |
| Salmon | 2.9.0 | Transcript quantification |
| SRA Toolkit | 3.4.1 | Retrieval of sequencing reads |

## Recreating the environment

From the project root, create the Conda environment with:

```bash
conda env create -f environment/environment.yml
```

Activate it:

```bash
conda activate rnaseq-processing
```

The pipeline scripts can then be executed in the order described in the main project README.

## Reproducibility notes

- The environment specification records the direct software dependencies and their versions.
- Conda may resolve different compatible transitive dependencies over time.
- The original analysis was performed on Ubuntu 24.04.1 LTS using WSL2.
- The file `sessionInfo.txt` records the R session and package information from the original analysis.
