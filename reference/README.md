# Reference Transcriptome

## Reference

This project uses **GENCODE release 19**, corresponding to the GRCh37.p13 / hg19 reference context.

[Official GENCODE release 19](https://www.gencodegenes.org/human/release_19.html)

The following files are used:

| File | Purpose |
|---|---|
| `gencode.v19.pc_transcripts.fa.gz` | Protein-coding transcripts |
| `gencode.v19.lncRNA_transcripts.fa.gz` | Long non-coding RNA transcripts |
| `gencode.v19.annotation.gtf.gz` | Gene and transcript annotation |

These reference files are downloaded by the preparation script and excluded from Git version control.

## Transcriptome preparation

Protein-coding and lncRNA transcript sequences are combined into one FASTA reference.

A transcript-to-gene mapping file, `gencode.v19.tx2gene.tsv`, is generated from the FASTA headers. It contains two columns:

- `TXNAME`: Ensembl transcript ID
- `GENEID`: Ensembl gene ID

The mapping contains 119,207 transcript entries.

## Salmon index

Salmon 2.9.0 was used to build the transcriptome index with a k-mer length of 31 and four threads.

The resulting index contains 118,149 transcript targets. Genomic decoy sequences were not included.

The index is excluded from Git because of its size (approximately 2.4 GB) and can be regenerated.

## Rebuilding the reference

From the project root, run:

```bash
bash scripts/03_prepare_reference.sh
```

This downloads the required files, prepares the combined transcriptome and mapping table, and builds the Salmon index.

## Resources

- [GENCODE release 19](https://www.gencodegenes.org/human/release_19.html)
- [Salmon documentation](https://salmon.readthedocs.io/)
