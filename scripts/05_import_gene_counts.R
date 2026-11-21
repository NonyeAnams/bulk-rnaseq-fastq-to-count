
# ============================================================
# 05_import_gene_counts.R
#
# Import Salmon transcript quantification and summarise
# transcript-level estimates into gene-level matrices.
#
# Input:
#   results/salmon/SRR12352387/quant.sf
#   reference/gencode19/gencode.v19.tx2gene.tsv
#
# Outputs:
#   results/gene_counts/gene_estimated_counts.csv
#   results/gene_counts/gene_abundance_tpm.csv
#   results/gene_counts/gene_effective_lengths.csv
# ============================================================

library(tximport)

# ------------------------------------------------------------
# 1. Define input files
# ------------------------------------------------------------

quant_files <- c(
    SRR12352387 = "results/salmon/SRR12352387/quant.sf"
)

tx2gene_file <- "reference/gencode19/gencode.v19.tx2gene.tsv"

# Check that input files exist
stopifnot(all(file.exists(quant_files)))
stopifnot(file.exists(tx2gene_file))

# ------------------------------------------------------------
# 2. Read transcript-to-gene mapping
# ------------------------------------------------------------

tx2gene <- read.delim(
    tx2gene_file,
    header = TRUE,
    stringsAsFactors = FALSE
)

# ------------------------------------------------------------
# 3. Import Salmon estimates and summarise to gene level
# ------------------------------------------------------------

txi <- tximport(
    quant_files,
    type = "salmon",
    tx2gene = tx2gene,
    dropInfReps = TRUE
)

# ------------------------------------------------------------
# 4. Save gene-level matrices
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
# 5. Summarise results
# ------------------------------------------------------------

cat("\nGene-level matrix dimensions:\n")
print(dim(txi$counts))

cat("\nGenes with non-zero estimated counts:\n")
print(sum(txi$counts[, 1] > 0))

cat("\nTotal gene-level estimated counts:\n")
print(sum(txi$counts[, 1]))

cat("\nOutput files saved in:", output_dir, "\n")

# ------------------------------------------------------------
# 6. Record software and package versions
# ------------------------------------------------------------

cat("\nSession information:\n")
print(sessionInfo())

