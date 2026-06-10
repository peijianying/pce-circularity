# =============================================================================
# PCE Circularity Simulation
# Goal: Demonstrate that the Pan-Cancer Equiprevalence (PCE) score used in
#       Dohlman et al. (Cell 2026) systematically misclassifies genuine
#       cross-cancer microbiota as contaminants.
#
# Strategy:
#   1. Build a synthetic 100kGP-like cohort (28 cancer types, n matching real)
#   2. Inject 4 ground-truth species categories:
#        (a) True contaminants  - uniform prevalence in ALL cancers
#        (b) Cancer-specific    - present in 1-2 cancers only (e.g. F. nuc/CRC)
#        (c) Cross-cancer real  - genuinely shared by many cancer types
#        (d) Random null        - Bernoulli noise
#   3. Compute PCE faithfully (Dohlman et al. STAR Methods)
#   4. Show how often each category is falsely classified by PCE > 0.7
#
# Author: (you), 2026-06-09
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  library(patchwork)
})

# Auto-detect repo root and create results/ if missing.
.find_root <- function() {
  for (p in c(getwd(), dirname(getwd()))) {
    if (dir.exists(file.path(p, "code"))) return(p)
  }
  getwd()
}
setwd(.find_root())
dir.create("results", showWarnings = FALSE)

set.seed(20260609)

# -------- 1. Cohort design (mirrors Dohlman et al. Table S4 sample sizes) ----
cancer_sizes <- c(
  Colorectal = 2482, Breast = 2200, Prostate = 1800, Lung = 1500, Brain = 295,
  Ovarian = 750, Renal = 700, Endometrial = 600, Sarcoma = 500, Skin = 500,
  Bladder = 450, HepBili = 400, Pancreatic = 380, Lymphoid = 350,
  Esophageal = 120, Gastric = 79, Oropharyngeal = 251, Sinonasal = 60,
  Testicular = 200, Thyroid = 180, Mesothelioma = 100, Adrenal = 90,
  HeadNeckOther = 250, Myeloid = 300, Cervical = 0,            # excluded in 100kGP
  EyeOcular = 80, ChildhoodSolid = 400, OtherRare = 354
)
cancer_sizes <- cancer_sizes[cancer_sizes > 0]
K <- length(cancer_sizes)
total_n <- sum(cancer_sizes)
cat(sprintf("Synthetic cohort: K = %d cancer types, total n = %d\n", K, total_n))

# -------- 2. PCE function (faithful to Dohlman et al. STAR Methods) ----------
# "coefficient of variation (CV) of species prevalence across cancer types,
#  scaled to [0,1] based on max theoretical CV"
#  Using the sample SD (R's sd(), n-1 denominator) the maximum theoretical CV
#  is achieved when prevalence = (c, 0, ..., 0):
#     mean = c/K,  sample var = c^2 / K,  sample sd = c/sqrt(K)
#     CV_max = sqrt(K)
#  - PCE = 1 - CV / sqrt(K)
#  - PCE = 0  ⇒  fully cancer-specific (one cancer only)
#  - PCE = 1  ⇒  perfectly equiprevalent (declared contaminant)
compute_PCE <- function(prevalence_vec) {
  K <- length(prevalence_vec)
  mu <- mean(prevalence_vec)
  if (mu == 0) return(NA_real_)
  sigma <- sd(prevalence_vec)
  CV <- sigma / mu
  CV_max <- sqrt(K)
  1 - CV / CV_max
}

# Sanity check: spike in only one cancer ⇒ PCE = 0; uniform ⇒ PCE = 1
stopifnot(abs(compute_PCE(c(1, rep(0, K - 1))) - 0) < 1e-9)
stopifnot(abs(compute_PCE(rep(0.3, K)) - 1) < 1e-9)

# -------- 3. Define 4 species categories ------------------------------------
n_per_cat <- 50

# (a) True contaminants: prev ~ Beta(8,8) centered on ~0.5 in every cancer
make_contaminant <- function(K) rbeta(K, 8, 8)

# (b) Cancer-specific real microbiota: high prev in 1-2 cancers, ~0 elsewhere
make_specific <- function(K) {
  prev <- runif(K, 0, 0.005)
  hot <- sample(K, sample(1:2, 1))
  prev[hot] <- runif(length(hot), 0.3, 0.7)
  prev
}

# (c) Cross-cancer REAL microbiota: genuinely present in many cancers,
#     prev varies modestly (skin/blood-borne, gut-axis, immune-axis spread, etc.)
make_crosscancer_real <- function(K, base_low = 0.05, base_high = 0.30) {
  # Real biological variation but truly shared - this is the critical case
  rbeta(K, 5, 7) * (base_high - base_low) + base_low
}

# (d) Null noise: low random prevalence
make_null <- function(K) rbeta(K, 1, 50)

species_table <- bind_rows(
  tibble(category = "True contaminant",
         prev = replicate(n_per_cat, make_contaminant(K), simplify = FALSE)),
  tibble(category = "Cancer-specific real",
         prev = replicate(n_per_cat, make_specific(K), simplify = FALSE)),
  tibble(category = "Cross-cancer REAL",
         prev = replicate(n_per_cat, make_crosscancer_real(K), simplify = FALSE)),
  tibble(category = "Null noise",
         prev = replicate(n_per_cat, make_null(K), simplify = FALSE))
) %>%
  mutate(species_id = sprintf("sp_%04d", row_number()),
         PCE = sapply(prev, compute_PCE),
         pred_contaminant = PCE > 0.7,
         truth_contaminant = category == "True contaminant",
         classification = case_when(
           pred_contaminant &  truth_contaminant ~ "TP (true contam removed)",
           pred_contaminant & !truth_contaminant ~ "FP (real microbe wrongly removed)",
          !pred_contaminant &  truth_contaminant ~ "FN (contam retained)",
          !pred_contaminant & !truth_contaminant ~ "TN (real microbe retained)"
         ))

# -------- 4. Summary statistics ----------------------------------------------
summary_tbl <- species_table %>%
  group_by(category) %>%
  summarise(n            = n(),
            median_PCE   = median(PCE, na.rm = TRUE),
            pct_PCE_gt07 = mean(PCE > 0.7, na.rm = TRUE) * 100,
            .groups = "drop")
print(summary_tbl)

cat("\n--- Confusion at PCE > 0.7 threshold ---\n")
conf <- species_table %>% count(category, classification)
print(conf)

# False discovery rate among "predicted contaminants":
fdr <- species_table %>%
  filter(pred_contaminant) %>%
  summarise(FDR = mean(category != "True contaminant"))
cat(sprintf("\nFDR among predicted contaminants (PCE>0.7): %.1f%%\n", fdr$FDR * 100))

# Among CROSS-CANCER REAL species, what fraction is falsely flagged?
fnr_cross <- species_table %>%
  filter(category == "Cross-cancer REAL") %>%
  summarise(FalseFlag = mean(pred_contaminant))
cat(sprintf("Fraction of CROSS-CANCER REAL microbiota falsely removed by PCE>0.7: %.1f%%\n",
            fnr_cross$FalseFlag * 100))

# -------- 5. PLOTTING --------------------------------------------------------

theme_set(theme_classic(base_size = 11) +
          theme(strip.background = element_blank(),
                strip.text = element_text(face = "bold")))

cat_palette <- c("True contaminant"     = "#D73027",
                 "Cancer-specific real" = "#1A9850",
                 "Cross-cancer REAL"    = "#762A83",
                 "Null noise"           = "grey60")

# Panel A: PCE distribution by ground-truth category
pA <- ggplot(species_table, aes(x = PCE, fill = category)) +
  geom_histogram(binwidth = 0.05, alpha = 0.85, color = "white") +
  geom_vline(xintercept = 0.7, linetype = "dashed", color = "black") +
  annotate("text", x = 0.72, y = Inf, vjust = 1.5, hjust = 0,
           label = "PCE > 0.7\n(contaminant cutoff)", size = 3.2) +
  facet_wrap(~ category, ncol = 1, scales = "free_y") +
  scale_fill_manual(values = cat_palette, guide = "none") +
  labs(title = "A. PCE distribution by ground-truth category",
       x = "Pan-Cancer Equiprevalence (PCE) score",
       y = "Number of synthetic species") +
  theme(plot.title = element_text(face = "bold"))

ggsave("results/Fig_PCE_panelA.pdf",
       pA, width = 6, height = 7)
ggsave("results/Fig_PCE_panelA.png",
       pA, width = 6, height = 7, dpi = 300)
cat("Saved Panel A.\n")

# ---- Panel B: Prevalence heatmap of representative species per category ----
set.seed(42)
example_idx <- species_table %>%
  group_by(category) %>%
  slice_sample(n = 4) %>%
  pull(species_id)

prev_long <- species_table %>%
  filter(species_id %in% example_idx) %>%
  mutate(prev_named = lapply(prev, function(p) {
    setNames(p, names(cancer_sizes))
  })) %>%
  rowwise() %>%
  mutate(prev_df = list(tibble(cancer = names(prev_named),
                               prev   = unname(prev_named)))) %>%
  ungroup() %>%
  select(species_id, category, PCE, prev_df) %>%
  unnest(prev_df) %>%
  mutate(species_lbl = sprintf("%s\nPCE=%.2f", species_id, PCE),
         category    = factor(category,
                              levels = c("True contaminant", "Cross-cancer REAL",
                                         "Cancer-specific real", "Null noise")))

pB <- ggplot(prev_long,
             aes(x = cancer, y = species_lbl, fill = prev)) +
  geom_tile(color = "white", linewidth = 0.2) +
  facet_wrap(~ category, scales = "free_y", ncol = 1) +
  scale_fill_gradient(low = "white", high = "#08306B",
                      name = "Prevalence", limits = c(0, 1)) +
  labs(title = "B. Per-cancer prevalence patterns of example species",
       x = NULL, y = NULL) +
  theme(axis.text.x = element_text(angle = 45, hjust = 1, size = 7),
        axis.text.y = element_text(size = 7),
        plot.title  = element_text(face = "bold"),
        panel.grid  = element_blank())

# ---- Panel C: PCE threshold sensitivity --------------------------------------
thresholds <- seq(0.3, 0.99, by = 0.02)
sens_tbl <- tibble(thresh = thresholds) %>%
  rowwise() %>%
  mutate(
    n_flagged          = sum(species_table$PCE > thresh, na.rm = TRUE),
    FDR                = mean(species_table$category[species_table$PCE > thresh] !=
                              "True contaminant"),
    false_loss_cross   = mean(species_table$PCE[species_table$category ==
                              "Cross-cancer REAL"] > thresh),
    true_contam_caught = mean(species_table$PCE[species_table$category ==
                              "True contaminant"] > thresh)
  ) %>% ungroup()

sens_long <- sens_tbl %>%
  select(thresh, FDR, false_loss_cross, true_contam_caught) %>%
  pivot_longer(-thresh) %>%
  mutate(name = recode(name,
            FDR                = "FDR among 'predicted contaminants'",
            false_loss_cross   = "Cross-cancer REAL species lost",
            true_contam_caught = "True contaminants correctly removed"))

pC <- ggplot(sens_long, aes(x = thresh, y = value, color = name)) +
  geom_line(linewidth = 1) +
  geom_vline(xintercept = 0.7, linetype = "dashed") +
  annotate("text", x = 0.7, y = 0.05, label = "Dohlman et al. cutoff",
           hjust = -0.05, size = 3) +
  scale_color_manual(values = c("FDR among 'predicted contaminants'"   = "#D73027",
                                "Cross-cancer REAL species lost"       = "#762A83",
                                "True contaminants correctly removed"  = "#1A9850"),
                     name = NULL) +
  scale_y_continuous(labels = scales::percent_format(1), limits = c(0, 1)) +
  labs(title = "C. PCE threshold sensitivity",
       x = "PCE threshold", y = "Fraction of species") +
  theme(legend.position = "top",
        legend.text     = element_text(size = 8),
        plot.title      = element_text(face = "bold")) +
  guides(color = guide_legend(ncol = 1))

# ---- Panel D: Confusion summary ---------------------------------------------
conf_tbl <- species_table %>%
  count(category, classification) %>%
  group_by(category) %>%
  mutate(frac = n / sum(n)) %>%
  ungroup() %>%
  mutate(category = factor(category,
                           levels = c("True contaminant", "Cross-cancer REAL",
                                      "Cancer-specific real", "Null noise")))

pD <- ggplot(conf_tbl, aes(x = category, y = frac, fill = classification)) +
  geom_col(width = 0.7) +
  geom_text(aes(label = sprintf("n=%d", n)),
            position = position_stack(vjust = 0.5), size = 3, color = "white") +
  scale_fill_manual(values = c(
    "TP (true contam removed)"          = "#1A9850",
    "FP (real microbe wrongly removed)" = "#D73027",
    "FN (contam retained)"              = "#FDAE61",
    "TN (real microbe retained)"        = "#4575B4"
  ), name = NULL) +
  scale_y_continuous(labels = scales::percent_format(1)) +
  labs(title = "D. Classification outcome at PCE > 0.7",
       x = NULL, y = "Fraction of species in category") +
  theme(legend.position = "right",
        legend.text     = element_text(size = 8),
        axis.text.x     = element_text(angle = 30, hjust = 1),
        plot.title      = element_text(face = "bold"))

# ---- Compose multi-panel figure ---------------------------------------------
fig_full <- (pA | pB) / (pC | pD) +
  plot_layout(heights = c(1.2, 1)) +
  plot_annotation(
    title    = "PCE-based decontamination systematically eliminates genuine cross-cancer microbiota",
    subtitle = sprintf("Synthetic 100kGP-like cohort (K=%d cancer types, n=%d). %d species per ground-truth category.",
                       K, total_n, n_per_cat),
    theme    = theme(plot.title    = element_text(face = "bold", size = 13),
                     plot.subtitle = element_text(size = 10, color = "grey30"))
  )

ggsave("results/Fig_PCE_circularity_full.pdf",
       fig_full, width = 14, height = 12)
ggsave("results/Fig_PCE_circularity_full.png",
       fig_full, width = 14, height = 12, dpi = 300)

cat("\nSaved full multi-panel figure.\n")

# ---- Save summary tables for the manuscript --------------------------------
write.csv(summary_tbl, "results/PCE_summary_by_category.csv",
          row.names = FALSE)
write.csv(sens_tbl,    "results/PCE_threshold_sensitivity.csv",
          row.names = FALSE)
saveRDS(species_table, "results/species_table.rds")

cat("\n=== Key numbers for the Matters Arising ===\n")
cat(sprintf("  PCE > 0.7 falsely flags %.0f%% of cross-cancer REAL microbes as contaminants.\n",
            fnr_cross$FalseFlag * 100))
cat(sprintf("  Among species PCE>0.7 calls 'contaminant', FDR = %.1f%%.\n", fdr$FDR * 100))
cat(sprintf("  Median PCE: true contam = %.3f vs cross-cancer real = %.3f (indistinguishable).\n",
            summary_tbl$median_PCE[summary_tbl$category == "True contaminant"],
            summary_tbl$median_PCE[summary_tbl$category == "Cross-cancer REAL"]))

