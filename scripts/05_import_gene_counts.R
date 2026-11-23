
# ============================================================
# 05_import_gene_counts.R
#
# Import Salmon transcript quantification and summarise
# transcript-level estimates into gene-level matrices.
#
# Samples:
#   SRR12352385, SRR12352386, SRR12352387
#   SRR12352388, SRR12352389, SRR12352390
#
# Inputs:
#   results/salmon/<sample>/quant.sf
#   reference/gencode19/gencode.v19.tx2gene.tsv
#
# Outputs:
#   results/gene_counts/gene_estimated_counts.csv
#   results/gene_counts/gene_abundance_tpm.csv
#   results/gene_counts/gene_effective_lengths.csv
# ============================================================


# ------------------------------------------------------------
# 1. Load required package
# ------------------------------------------------------------

library(tximport)


# ------------------------------------------------------------
# 2. Define samples and input files
# ------------------------------------------------------------

samples <- c(
    "SRR12352385",
    "SRR12352386",
    "SRR12352387",
    "SRR12352388",
    "SRR12352389",
    "SRR12352390"
)

quant_files <- file.path(
    "results/salmon",
    samples,
    "quant.sf"
)

# Assign sample IDs as names.
# These will become the column names of the output matrices.
names(quant_files) <- samples

tx2gene_file <- "reference/gencode19/gencode.v19.tx2gene.tsv"


# ------------------------------------------------------------
# 3. Validate input files
# ------------------------------------------------------------

if (!all(file.exists(quant_files))) {
    stop("One or more Salmon quant.sf files are missing.")
}

if (!file.exists(tx2gene_file)) {
    stop("Transcript-to-gene mapping file is missing.")
}

cat("All six Salmon quantification files found.\n")


# ------------------------------------------------------------
# 4. Read transcript-to-gene mapping
# ------------------------------------------------------------

tx2gene <- read.delim(
    tx2gene_file,
    header = TRUE,
    stringsAsFactors = FALSE
)

# Confirm expected mapping columns exist.
if (!all(c("TXNAME", "GENEID") %in% colnames(tx2gene))) {
    stop("tx2gene file must contain TXNAME and GENEID columns.")
}

tx2gene <- tx2gene[, c("TXNAME", "GENEID")]

# Check for missing or duplicated transcript identifiers.
if (anyNA(tx2gene$TXNAME) || anyNA(tx2gene$GENEID)) {
    stop("Missing transcript or gene identifiers in tx2gene.")
}

if (anyDuplicated(tx2gene$TXNAME)) {
    stop("Duplicated transcript identifiers in tx2gene.")
}

cat("Transcript-to-gene mapping loaded.\n")
cat("Mapping records:", nrow(tx2gene), "\n")
cat("Unique genes:", length(unique(tx2gene$GENEID)), "\n")


# ------------------------------------------------------------
# 5. Validate transcript ID compatibility
# ------------------------------------------------------------

mapping_ids <- tx2gene$TXNAME

for (sample in samples) {

    quant <- read.delim(
        quant_files[[sample]],
        header = TRUE,
        stringsAsFactors = FALSE
    )

    missing_ids <- setdiff(quant$Name, mapping_ids)

    if (length(missing_ids) > 0) {
        stop(
            sample,
            ": ",
            length(missing_ids),
            " Salmon transcript IDs have no gene mapping."
        )
    }

    cat(
        sample,
        ":",
        nrow(quant),
        "transcript targets; all IDs mapped.\n"
    )
}


# ------------------------------------------------------------
# 6. Import Salmon estimates and summarise to gene level
# ------------------------------------------------------------

cat("\nImporting Salmon quantification files...\n")

txi <- tximport(
    quant_files,
    type = "salmon",
    tx2gene = tx2gene,
    dropInfReps = TRUE
)

cat("Gene-level summarisation complete.\n")


# ------------------------------------------------------------
# 7. Validate imported matrices
# ------------------------------------------------------------

if (!identical(colnames(txi$counts), samples)) {
    stop("Unexpected sample names in gene count matrix.")
}

if (!all(dim(txi$counts) == dim(txi$abundance))) {
    stop("Counts and abundance matrices have different dimensions.")
}

if (!all(dim(txi$counts) == dim(txi$length))) {
    stop("Counts and length matrices have different dimensions.")
}

if (any(!is.finite(txi$counts)) ||
    any(!is.finite(txi$abundance)) ||
    any(!is.finite(txi$length))) {
    stop("Non-finite values detected in imported matrices.")
}


# ------------------------------------------------------------
# 8. Save gene-level matrices
# ------------------------------------------------------------

output_dir <- "results/gene_counts"

dir.create(
    output_dir,
    recursive = TRUE,
    showWarnings = FALSE
)

write.csv(
    txi$counts,
    file.path(output_dir, "gene_estimated_counts.csv")
)

write.csv(
    txi$abundance,
    file.path(output_dir, "gene_abundance_tpm.csv")
)

write.csv(
    txi$length,
    file.path(output_dir, "gene_effective_lengths.csv")
)


# ------------------------------------------------------------
# 9. Summarise results
# ------------------------------------------------------------

cat("\nGene-level matrix dimensions:\n")
print(dim(txi$counts))

cat("\nGenes with non-zero estimated counts per sample:\n")
print(colSums(txi$counts > 0))

cat("\nTotal gene-level estimated counts per sample:\n")
print(colSums(txi$counts))

cat("\nOutput files saved in:", output_dir, "\n")


# ------------------------------------------------------------
# 10. Record software and package versions
# ------------------------------------------------------------

cat("\nSession information:\n")
print(sessionInfo())

