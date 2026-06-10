# =============================================================================
# Reanalysis of the TMB-microbial-load correlation with tumor purity adjustment
#
# Goal: Test whether the TMB-microbial-load correlation reported by Dohlman
#       et al. (Cell 2026, Fig 5E/F) survives adjustment for tumor purity.
#
# Rationale (the "shared denominator" issue):
#       RPM = microbial reads / total sequencing reads (mostly host)
#       TMB = somatic mutations / Mb of analyzable genome
#       Both quantities co-scale with tumor purity / host DNA fraction.
#       Hypermutated subtypes (MSI/POLE) tend to have heavier immune
#       infiltration -> lower tumor purity -> potentially inflated RPM
#       through the shared denominator alone.
#
# Data:
#   data/WXS/sample/bacteria.unambiguous.decontam.tissue.sample.rpm.txt
#     - TCMA decontaminated WXS microbiome (Dohlman et al. 2021 Cell Host & Microbe)
#     - Columns are TCGA aliquot barcodes (e.g. TCGA-XX-XXXX-01A)
#   data/metadata/metadata.TCMA.case.txt
#   data/TCGA_ABSOLUTE_purity.tsv      - Aran 2015 purity & ploidy
#   data/mc3.nonsilent.gene.matrix.gz  - per-sample non-silent mutation counts
#                                         (UCSC Xena mirror of MC3 v0.2.8 PUBLIC MAF)
# Output:
#   results/Fig_TMB_purity_reanalysis.pdf
#   results/TMB_purity_correlation_table.csv
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(readr)
  library(ggplot2)
  library(patchwork)
})

# MC3 has ~9k columns -> default vroom buffer is too small.
Sys.setenv("VROOM_CONNECTION_SIZE" = 5e6)

# Project root: directory containing data/ and results/.
# Auto-detected so the script runs unchanged whether invoked from the repo root
# (e.g. `Rscript code/02_TMB_purity_reanalysis.R`) or from inside code/.
.find_root <- function() {
  for (p in c(getwd(), dirname(getwd()))) {
    if (dir.exists(file.path(p, "data"))) return(p)
  }
  stop("Could not locate `data/` directory. Run from the repository root.")
}
ROOT <- .find_root()
setwd(ROOT)
dir.create("results", showWarnings = FALSE)

# ---------- 1. Load TCMA microbiome (sample-level RPM, decontaminated) ------
rpm_file <- "data/WXS/sample/bacteria.unambiguous.decontam.tissue.sample.rpm.txt"
stopifnot(file.exists(rpm_file))
rpm_raw <- read_tsv(rpm_file, show_col_types = FALSE)
cat(sprintf("TCMA WXS rpm matrix: %d taxa x %d samples\n",
            nrow(rpm_raw), ncol(rpm_raw) - 1))

# Sum over all (decontaminated) microbial taxa to get total microbial load
sample_cols <- setdiff(names(rpm_raw), names(rpm_raw)[1])
load_tbl <- tibble(
  sample_aliquot = sample_cols,
  total_rpm      = colSums(rpm_raw[, sample_cols], na.rm = TRUE)
) %>%
  mutate(
    sample_short  = substr(sample_aliquot, 1, 15),     # TCGA-XX-XXXX-01
    case_id       = substr(sample_aliquot, 1, 12),     # TCGA-XX-XXXX
    sample_type   = substr(sample_aliquot, 14, 15)
  ) %>%
  filter(sample_type %in% c("01", "02", "03", "06"))   # primary tumors only

cat(sprintf("Tumor-only TCMA samples: %d (median RPM = %.2f)\n",
            nrow(load_tbl), median(load_tbl$total_rpm)))

# ---------- 2. Cancer-type assignment from TCMA case metadata ---------------
case_meta <- read_tsv("data/metadata/metadata.TCMA.case.txt",
                      show_col_types = FALSE, guess_max = 5000) %>%
  select(case_id = bcr_patient_barcode, project = acronym)

load_tbl <- load_tbl %>%
  inner_join(case_meta, by = "case_id")
cat(sprintf("Annotated %d samples with cancer type. Top 10:\n", nrow(load_tbl)))
print(sort(table(load_tbl$project), decreasing = TRUE)[1:10])

# ---------- 3. Load ABSOLUTE purity ------------------------------------------
purity <- read_tsv("data/TCGA_ABSOLUTE_purity.tsv", show_col_types = FALSE) %>%
  rename(absolute_aliquot = sample, purity = purity, ploidy = ploidy) %>%
  mutate(sample_short = substr(absolute_aliquot, 1, 15)) %>%
  select(sample_short, purity, ploidy) %>%
  filter(!is.na(purity)) %>%
  distinct(sample_short, .keep_all = TRUE)
cat(sprintf("ABSOLUTE purity: %d unique samples\n", nrow(purity)))

# ---------- 4. Compute per-sample TMB from MC3 non-silent matrix ------------
mc3 <- read_tsv("data/mc3.nonsilent.gene.matrix.gz", show_col_types = FALSE)
gene_col <- names(mc3)[1]
mc3_samples <- setdiff(names(mc3), gene_col)
muts <- tibble(
  sample_short = mc3_samples,
  n_nonsilent  = colSums(mc3[, mc3_samples], na.rm = TRUE)
) %>%
  mutate(TMB_per_Mb = n_nonsilent / 38)   # ~38 Mb of analyzable exome
cat(sprintf("MC3 mutation counts: %d samples; median nonsilent = %.0f\n",
            nrow(muts), median(muts$n_nonsilent)))

# Note: mc3 has 15-char barcodes (TCGA-XX-XXXX-01); load_tbl too. Merge on sample_short.

# ---------- 5. Merge ---------------------------------------------------------
merged <- load_tbl %>%
  inner_join(purity, by = "sample_short") %>%
  inner_join(muts,   by = "sample_short") %>%
  filter(total_rpm > 0, TMB_per_Mb > 0, !is.na(purity)) %>%
  mutate(log_RPM = log10(total_rpm),
         log_TMB = log10(TMB_per_Mb))
cat(sprintf("\n=== Final merged table: %d samples in %d cancer types ===\n",
            nrow(merged), length(unique(merged$project))))

# ---------- 6. Correlation analyses, faithful to Dohlman et al. -------------
oro_codes <- c("COAD", "READ", "STAD", "ESCA", "HNSC")

run_corr <- function(df, label) {
  if (nrow(df) < 30) return(NULL)
  raw  <- cor.test(df$log_TMB, df$log_RPM, method = "pearson")
  # Partial: regress both on purity, correlate residuals
  r_R <- residuals(lm(log_RPM ~ purity, data = df))
  r_T <- residuals(lm(log_TMB ~ purity, data = df))
  part <- cor.test(r_T, r_R, method = "pearson")
  # Multiple regression: log_RPM ~ log_TMB + purity
  m1 <- lm(log_RPM ~ log_TMB + purity, data = df)
  s1 <- summary(m1)$coefficients
  tibble(
    subset             = label,
    n                  = nrow(df),
    r_raw              = unname(raw$estimate),
    p_raw              = raw$p.value,
    r_partial          = unname(part$estimate),
    p_partial          = part$p.value,
    pct_change_in_r    = (part$estimate - raw$estimate) / abs(raw$estimate) * 100,
    beta_TMB_unadj     = coef(lm(log_RPM ~ log_TMB, data = df))["log_TMB"],
    beta_TMB_purityadj = s1["log_TMB", "Estimate"],
    p_TMB_purityadj    = s1["log_TMB", "Pr(>|t|)"],
    beta_purity        = s1["purity", "Estimate"],
    p_purity           = s1["purity", "Pr(>|t|)"]
  )
}

corr_tbl <- bind_rows(
  run_corr(merged,                                         "All TCGA"),
  run_corr(merged %>% filter(project %in% c("COAD","READ")),"CRC (COAD+READ)"),
  run_corr(merged %>% filter(project == "STAD"),           "Gastric (STAD)"),
  run_corr(merged %>% filter(project == "ESCA"),           "Esophageal (ESCA)"),
  run_corr(merged %>% filter(project == "HNSC"),           "Head/Neck (HNSC)"),
  run_corr(merged %>% filter(project %in% oro_codes),      "Orodigestive pooled")
)
print(corr_tbl, n = Inf, width = Inf)
write_csv(corr_tbl, "results/TMB_purity_correlation_table.csv")

# ---------- 7. Within-purity-quintile correlation (orodigestive) ------------
quint <- merged %>%
  filter(project %in% oro_codes) %>%
  mutate(purity_quintile = ntile(purity, 5))
quint_corr <- quint %>%
  group_by(purity_quintile) %>%
  summarise(
    n        = n(),
    pur_min  = round(min(purity), 2),
    pur_max  = round(max(purity), 2),
    r        = cor(log_TMB, log_RPM),
    p        = cor.test(log_TMB, log_RPM)$p.value,
    .groups  = "drop"
  )
print(quint_corr)
write_csv(quint_corr, "results/TMB_purity_within_quintile.csv")

# ---------- 8. Plotting ------------------------------------------------------
theme_set(theme_classic(base_size = 11) +
          theme(strip.background = element_blank(),
                strip.text = element_text(face = "bold")))

oro <- merged %>% filter(project %in% oro_codes)
oro <- oro %>%
  mutate(r_RPM = residuals(lm(log_RPM ~ purity, data = oro)),
         r_TMB = residuals(lm(log_TMB ~ purity, data = oro)))

# Helper: pull a value from corr_tbl
val <- function(tag, col) corr_tbl[[col]][corr_tbl$subset == tag][1]

# Panel A: raw scatter (Dohlman style)
pA <- ggplot(oro, aes(x = log_TMB, y = log_RPM)) +
  geom_point(aes(color = project), alpha = 0.55, size = 1.4) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 0.7) +
  annotate("text", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.5, size = 3.2,
           label = sprintf("Raw r = %.3f\np = %.1e\nn = %d",
                           val("Orodigestive pooled", "r_raw"),
                           val("Orodigestive pooled", "p_raw"),
                           val("Orodigestive pooled", "n"))) +
  scale_color_brewer(palette = "Set1", name = "Cancer") +
  labs(title = "A. Raw correlation (Dohlman-style)",
       x = "log10 TMB (mut / Mb)", y = "log10 microbial load (RPM)") +
  theme(plot.title = element_text(face = "bold"))

# Panel B: purity-adjusted (residualized) scatter
pB <- ggplot(oro, aes(x = r_TMB, y = r_RPM)) +
  geom_point(aes(color = project), alpha = 0.55, size = 1.4) +
  geom_smooth(method = "lm", se = TRUE, color = "black", linewidth = 0.7) +
  annotate("text", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.5, size = 3.2,
           label = sprintf("Purity-adjusted r = %.3f\np = %.1e",
                           val("Orodigestive pooled", "r_partial"),
                           val("Orodigestive pooled", "p_partial"))) +
  scale_color_brewer(palette = "Set1", name = "Cancer") +
  labs(title = "B. After tumor-purity adjustment",
       x = "TMB residual (purity-removed)",
       y = "Microbial-load residual (purity-removed)") +
  theme(plot.title = element_text(face = "bold"))

# Panel C: forest of raw vs purity-adjusted r
plot_tbl <- corr_tbl %>%
  pivot_longer(cols = c(r_raw, r_partial), names_to = "type", values_to = "r") %>%
  mutate(type = factor(type,
                       levels = c("r_raw", "r_partial"),
                       labels = c("Raw", "Purity-adjusted")),
         subset = factor(subset, levels = rev(corr_tbl$subset)))
pC <- ggplot(plot_tbl, aes(x = r, y = subset, color = type)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey60") +
  geom_point(size = 3.2, position = position_dodge(width = 0.55)) +
  scale_color_manual(values = c("Raw" = "#D73027", "Purity-adjusted" = "#1A9850"),
                     name = NULL) +
  labs(title = "C. TMB-microbe correlation: raw vs purity-adjusted",
       x = "Pearson r", y = NULL) +
  theme(plot.title = element_text(face = "bold"),
        legend.position = "top")

# Panel D: within-purity-quintile r
pD <- ggplot(quint_corr, aes(x = factor(purity_quintile), y = r)) +
  geom_col(fill = "#4575B4", width = 0.6) +
  geom_text(aes(label = sprintf("n=%d\np=%.2g", n, p)),
            vjust = -0.3, size = 3) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  scale_x_discrete(labels = sprintf("Q%d\n[%.2f-%.2f]",
                                    quint_corr$purity_quintile,
                                    quint_corr$pur_min,
                                    quint_corr$pur_max)) +
  ylim(c(min(c(0, quint_corr$r)) - 0.05,
         max(c(0, quint_corr$r)) + 0.20)) +
  labs(title = "D. Within-purity-quintile r (orodigestive)",
       x = "Purity quintile", y = "Pearson r (log_TMB vs log_RPM)") +
  theme(plot.title = element_text(face = "bold"))

# Compose
fig <- (pA | pB) / (pC | pD) +
  plot_layout(heights = c(1, 1)) +
  plot_annotation(
    title = "Tumor purity confounds the TMB-microbial-load correlation in orodigestive cancers",
    subtitle = sprintf(
      "TCMA-decontaminated TCGA-WXS microbiomes (n=%d) merged with ABSOLUTE purity and MC3 TMB.",
      sum(oro$project %in% oro_codes)),
    theme = theme(plot.title    = element_text(face = "bold", size = 13),
                  plot.subtitle = element_text(size = 10, color = "grey30"))
  )

ggsave("results/Fig_TMB_purity_reanalysis.pdf", fig, width = 13, height = 10)
ggsave("results/Fig_TMB_purity_reanalysis.png", fig, width = 13, height = 10, dpi = 300)
cat("\nSaved Fig_TMB_purity_reanalysis.{pdf,png}\n")

# ---------- 9. Headline numbers ---------------------------------------------
cat("\n=== HEADLINE NUMBERS for the Matters Arising ===\n")
print(corr_tbl %>%
        select(subset, n, r_raw, p_raw, r_partial, p_partial,
               pct_change_in_r, p_TMB_purityadj, p_purity), n = Inf, width = Inf)
saveRDS(merged, "results/TMB_purity_merged.rds")
cat("\nDone.\n")
