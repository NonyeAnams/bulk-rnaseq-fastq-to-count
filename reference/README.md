# Reference Transcriptome

## Reference source

The human transcript reference used in this project was obtained from **GENCODE release 19**.

GENCODE release 19 corresponds to the GRCh37.p13 human genome assembly, commonly associated with the hg19 reference context.

Release 19 was selected to maintain consistency with the reference assembly context of the original study.

Official release page:

https://www.gencodegenes.org/human/release_19.html

## Reference files

The following files were used:

| File | Description |
|---|---|
| `gencode.v19.pc_transcripts.fa.gz` | Protein-coding transcript sequences |
| `gencode.v19.lncRNA_transcripts.fa.gz` | Long non-coding RNA transcript sequences |
| `gencode.v19.annotation.gtf.gz` | Gene and transcript annotation |

These files are not included in the Git repository because they can be retrieved from the official GENCODE release.

## Transcriptome construction

The protein-coding and lncRNA transcript FASTA files were combined into a single transcriptome reference.

Command:

```bash
zcat gencode.v19.pc_transcripts.fa.gz \
     gencode.v19.lncRNA_transcripts.fa.gz \
     | gzip -c > gencode.v19.transcripts.fa.gz
```

The resulting combined FASTA contained 119,207 transcript records.

## Transcript-to-gene mapping

A transcript-to-gene mapping table was generated directly from the combined FASTA headers.

GENCODE FASTA headers contain transcript and gene identifiers separated by vertical bars.

The first field contains the transcript identifier, while the second field contains the corresponding gene identifier.

The resulting mapping file:

`gencode.v19.tx2gene.tsv`

contains two columns:

| Column | Description |
|---|---|
| TXNAME | Ensembl transcript identifier |
| GENEID | Ensembl gene identifier |

The mapping contains 119,207 transcript-to-gene entries.

This file is retained in the Git repository because it is required by the downstream tximport script and is relatively small compared with the original reference files.

## Salmon index construction

Salmon was used to construct an index from the combined transcriptome FASTA.

The index was generated with the following command:

```bash
salmon index \
    -t gencode.v19.transcripts.fa.gz \
    -i salmon_index_gencode19 \
    --gencode \
    -k 31 \
    -p 4
```

Index configuration:

| Parameter | Setting |
|---|---|
| Software | Salmon 2.9.0 |
| Reference | GENCODE v19 combined transcriptome |
| k-mer length | 31 |
| Threads | 4 |
| GENCODE identifiers | Enabled |
| Genomic decoys | Not included |

The index contained 118,149 indexed transcript references after Salmon processed duplicate transcript sequences.

The Salmon index directory is excluded from Git version control because it occupies approximately 2.4 GB and can be regenerated using the reference files and command above.

## Rebuilding the reference

From the project root, execute:

```bash
./scripts/03_prepare_reference.sh
```

This script downloads the required GENCODE files if they are missing, constructs the combined transcriptome, generates the transcript-to-gene mapping and builds the Salmon index.

## Important considerations

- GENCODE release 19 is an older annotation release.
- The reference was selected to maintain compatibility with the GRCh37/hg19 context.
- The Salmon index is transcriptome-only and does not contain genomic decoy sequences.
- The transcript-to-gene mapping was extracted from the FASTA headers rather than generated from the GTF annotation.
- The original reference files and Salmon index are excluded from GitHub to avoid unnecessarily large repository size.

## Reference resources

- GENCODE release 19: https://www.gencodegenes.org/human/release_19.html
- GENCODE data access: https://www.gencodegenes.org/pages/data_access
- Salmon documentation: https://salmon.readthedocs.io/
