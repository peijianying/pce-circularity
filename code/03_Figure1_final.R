# =============================================================================
# Figure 1 — Cell-style production figure
# Two methodological concerns regarding Dohlman et al. (Cell 2026)
#
# Cell visual conventions:
#   - sans-serif (Helvetica/Nimbus Sans), all text 6-8pt
#   - panel labels A, B, C... in bold, top-left, no period
#   - thin axis lines (~0.4pt), tick marks inward
#   - no chart-junk; minimal grid; no panel borders unless heatmap
#   - colour palette: muted, colorblind-safe, max 5 hues
#   - figure prepared at column width 8.5cm (single) or 17.4cm (double)
#   - export: 300dpi PNG + vector PDF (Cairo)
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr)
  library(ggplot2); library(patchwork); library(scales); library(grid)
  library(showtext)
})
Sys.setenv("VROOM_CONNECTION_SIZE" = 5e6)

# Auto-detect repository root (folder containing results/).
.find_root <- function() {
  for (p in c(getwd(), dirname(getwd()))) {
    if (dir.exists(file.path(p, "results"))) return(p)
  }
  getwd()
}
setwd(.find_root())
dir.create("results/Figure1_final", showWarnings = FALSE, recursive = TRUE)

# ---------- Fonts -----------------------------------------------------------
# Try Helvetica first (Cell house style); fall back to Nimbus Sans (free Helvetica
# clone shipped with most Linux distros) if Helvetica is not installed.
.try_font <- function() {
  helv_paths <- list(
    list(reg = "/Library/Fonts/Helvetica.ttc",
         bold = "/Library/Fonts/Helvetica.ttc",
         italic = "/Library/Fonts/Helvetica.ttc"),
    list(reg = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Regular.otf",
         bold = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Bold.otf",
         italic = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Italic.otf"),
    list(reg = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
         bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
         italic = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf")
  )
  for (h in helv_paths) {
    if (all(file.exists(unlist(h)))) {
      font_add("Helvetica", regular = h$reg, bold = h$bold, italic = h$italic)
      return(invisible(TRUE))
    }
  }
  message("No Helvetica-equivalent font found; using R default sans.")
}
.try_font()
showtext_auto()
showtext_opts(dpi = 300)

# ---------- Cell-style theme ------------------------------------------------
BASE <- 7      # body text pt
LARGE <- 8     # panel titles
LINE <- 0.35   # axis line size in pt
PANEL_TAG_SIZE <- 9

cell_theme <- function() {
  theme_classic(base_size = BASE, base_family = "Helvetica") +
    theme(
      text             = element_text(family = "Helvetica", colour = "black"),
      axis.text        = element_text(size = BASE, colour = "black"),
      axis.title       = element_text(size = BASE, colour = "black"),
      axis.line        = element_line(linewidth = LINE, colour = "black"),
      axis.ticks       = element_line(linewidth = LINE, colour = "black"),
      axis.ticks.length = unit(2, "pt"),
      plot.title       = element_text(size = LARGE, face = "bold", hjust = 0,
                                      margin = margin(b = 4)),
      plot.title.position = "plot",
      legend.title     = element_text(size = BASE),
      legend.text      = element_text(size = BASE - 0.5),
      legend.key.size  = unit(7, "pt"),
      legend.box.spacing = unit(2, "pt"),
      legend.margin    = margin(0, 0, 0, 0),
      legend.background = element_blank(),
      strip.background = element_blank(),
      strip.text       = element_text(size = BASE, face = "bold"),
      plot.tag         = element_text(size = PANEL_TAG_SIZE, face = "bold",
                                      family = "Helvetica"),
      plot.margin      = margin(2, 4, 2, 2)
    )
}

# Cell-friendly muted palette (colorblind safe — Okabe-Ito derived)
COL <- list(
  contam        = "#D55E00",   # vermillion
  cancer_spec   = "#009E73",   # bluish green
  crosscancer   = "#56B4E9",   # sky blue
  null          = "#999999",   # grey
  raw           = "#D55E00",
  adjusted      = "#0072B2",   # blue
  cancer_codes  = c(COAD = "#E69F00", READ = "#F0C674",
                    STAD = "#56B4E9", ESCA = "#009E73",
                    HNSC = "#CC79A7"),
  bar           = "#56B4E9"
)

# ============================================================================
# Re-run the simulation (compact, deterministic) so the figure is self-contained
# ============================================================================
set.seed(20260609)

cancer_sizes <- c(
  Colorectal=2482, Breast=2200, Prostate=1800, Lung=1500, Brain=295,
  Ovarian=750, Renal=700, Endometrial=600, Sarcoma=500, Skin=500,
  Bladder=450, HepBili=400, Pancreatic=380, Lymphoid=350,
  Esophageal=120, Gastric=79, Oropharyngeal=251, Sinonasal=60,
  Testicular=200, Thyroid=180, Mesothelioma=100, Adrenal=90,
  HeadNeckOther=250, Myeloid=300, EyeOcular=80,
  ChildhoodSolid=400, OtherRare=354
)
K <- length(cancer_sizes)

compute_PCE <- function(p) {
  K <- length(p); mu <- mean(p)
  if (mu == 0) return(NA_real_)
  1 - (sd(p) / mu) / sqrt(K)
}
make_contaminant      <- function(K) rbeta(K, 8, 8)
make_specific         <- function(K) { v <- runif(K, 0, .005); h <- sample(K, sample(1:2,1)); v[h] <- runif(length(h), .3, .7); v }
make_crosscancer_real <- function(K) rbeta(K, 5, 7) * 0.25 + 0.05
make_null             <- function(K) rbeta(K, 1, 50)

n_per_cat <- 50
species_table <- bind_rows(
  tibble(category = "True contaminant",     prev = replicate(n_per_cat, make_contaminant(K),       simplify = FALSE)),
  tibble(category = "Cancer-specific real", prev = replicate(n_per_cat, make_specific(K),          simplify = FALSE)),
  tibble(category = "Cross-cancer real",    prev = replicate(n_per_cat, make_crosscancer_real(K),  simplify = FALSE)),
  tibble(category = "Null noise",           prev = replicate(n_per_cat, make_null(K),              simplify = FALSE))
) %>%
  mutate(species_id = sprintf("sp_%04d", row_number()),
         PCE = sapply(prev, compute_PCE))

cat_levels <- c("True contaminant", "Cross-cancer real",
                "Cancer-specific real", "Null noise")
cat_palette <- c("True contaminant"     = COL$contam,
                 "Cross-cancer real"    = COL$crosscancer,
                 "Cancer-specific real" = COL$cancer_spec,
                 "Null noise"           = COL$null)
species_table$category <- factor(species_table$category, levels = cat_levels)

# ============================================================================
# PANEL A — PCE distribution by ground-truth category
# ============================================================================
pA <- ggplot(species_table, aes(PCE, fill = category)) +
  geom_histogram(binwidth = 0.05, color = "white", linewidth = 0.2,
                 alpha = 0.95, boundary = 0) +
  geom_vline(xintercept = 0.7, linetype = "dashed",
             linewidth = LINE, colour = "black") +
  facet_wrap(~category, ncol = 1, strip.position = "right",
             scales = "free_y") +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(breaks = c(0, .25, .5, .7, 1),
                     labels = c("0", "0.25", "0.5", "0.7", "1"),
                     limits = c(0, 1.02), expand = c(0,0)) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.10))) +
  labs(title = "PCE distribution by ground-truth class",
       x = "PCE score", y = "Species (n)") +
  cell_theme() +
  theme(strip.text.y       = element_text(angle = 0, hjust = 0,
                                          size = BASE - 0.5,
                                          face = "bold"),
        strip.placement    = "outside",
        panel.spacing.y    = unit(2, "pt"),
        plot.title         = element_text(size = LARGE, face = "bold"))

# ============================================================================
# PANEL B — Per-cancer prevalence heatmap of representative species
# ============================================================================
set.seed(7)
example_idx <- species_table %>%
  group_by(category) %>%
  slice_sample(n = 4) %>%
  pull(species_id)

prev_long <- species_table %>%
  filter(species_id %in% example_idx) %>%
  rowwise() %>%
  mutate(prev_df = list(tibble(cancer = names(cancer_sizes),
                               prev = unlist(prev)))) %>%
  ungroup() %>%
  select(species_id, category, PCE, prev_df) %>%
  unnest(prev_df) %>%
  # use species_id (unique) as the row key but display label is PCE-based
  mutate(species_lbl = sprintf("PCE %.2f  ", PCE),
         row_key     = species_id)

# order species rows: true contam top, then cross-cancer, etc; within group by PCE
ord_tbl <- species_table %>%
  filter(species_id %in% example_idx) %>%
  arrange(category, desc(PCE)) %>%
  mutate(species_lbl = sprintf("PCE %.2f  ", PCE))
ord <- ord_tbl$species_id
prev_long$row_key <- factor(prev_long$row_key, levels = rev(ord))
prev_long$cancer  <- factor(prev_long$cancer, levels = names(cancer_sizes))

# Cancer category strips on right
cat_text <- species_table %>%
  filter(species_id %in% example_idx) %>%
  mutate(species_lbl = sprintf("PCE %.2f  ", PCE))

# label vector for the y-axis (display) — same order as row_key levels
y_lab_map <- ord_tbl %>%
  arrange(match(species_id, rev(ord))) %>%
  pull(species_lbl)

pB <- ggplot(prev_long, aes(cancer, row_key, fill = prev)) +
  geom_tile(colour = "white", linewidth = 0.25) +
  scale_fill_gradientn(colours = c("white", "#DEEBF7", "#9ECAE1", "#3182BD", "#08306B"),
                       values  = c(0, 0.05, 0.20, 0.5, 1),
                       limits  = c(0, 1),
                       breaks  = c(0, 0.25, 0.5, 0.75, 1),
                       name    = "Prev.",
                       guide   = guide_colorbar(barwidth = unit(0.3, "lines"),
                                                barheight = unit(3.5, "lines"),
                                                ticks.colour = "black",
                                                frame.colour = "black")) +
  scale_y_discrete(labels = y_lab_map) +
  labs(title = "Example species: per-cancer prevalence",
       x = NULL, y = NULL) +
  cell_theme() +
  theme(axis.text.x = element_text(angle = 60, hjust = 1, size = BASE - 1.5),
        axis.text.y = element_text(size = BASE, family = "Helvetica",
                                   face = "bold"),
        axis.line   = element_blank(),
        axis.ticks  = element_blank(),
        legend.position = "right",
        legend.title = element_text(size = BASE - 1))

# Manual category color stripes on left of pB rows
# Add a faint category color via theme axis.text.y colors
row_colours <- cat_text %>%
  arrange(category, desc(PCE)) %>%
  mutate(color = recode(as.character(category),
                        "True contaminant"     = COL$contam,
                        "Cross-cancer real"    = COL$crosscancer,
                        "Cancer-specific real" = COL$cancer_spec,
                        "Null noise"           = COL$null))
# Order matches row_key factor levels (rev(ord)) — i.e. species_id ascending in display
row_colours <- row_colours[match(rev(ord), row_colours$species_id), ]
pB <- pB + theme(axis.text.y = element_text(colour = row_colours$color,
                                            size = BASE,
                                            face = "bold"))

# ============================================================================
# PANEL C — PCE threshold sensitivity
# ============================================================================
thresholds <- seq(0.30, 0.99, by = 0.01)
sens_tbl <- tibble(thresh = thresholds) %>%
  rowwise() %>%
  mutate(
    fdr            = mean(species_table$category[species_table$PCE > thresh] !=
                          "True contaminant"),
    cross_lost     = mean(species_table$PCE[species_table$category ==
                          "Cross-cancer real"] > thresh),
    contam_caught  = mean(species_table$PCE[species_table$category ==
                          "True contaminant"] > thresh)
  ) %>% ungroup() %>%
  pivot_longer(-thresh, names_to = "metric", values_to = "value") %>%
  mutate(metric = recode(metric,
            fdr           = "FDR among 'predicted contaminants'",
            cross_lost    = "Cross-cancer real lost",
            contam_caught = "True contaminants removed"))

pC <- ggplot(sens_tbl, aes(thresh, value, colour = metric)) +
  geom_vline(xintercept = 0.7, linetype = "dashed",
             linewidth = LINE, colour = "black") +
  # plot contaminants-removed first (becomes background line)
  geom_line(data = subset(sens_tbl, metric == "True contaminants removed"),
            linewidth = 2.0, alpha = 0.40) +
  # then cross-cancer-lost ON TOP, dashed, narrow — proves overlap
  geom_line(data = subset(sens_tbl, metric == "Cross-cancer real lost"),
            linewidth = 0.6, linetype = "31") +
  # FDR — its own pattern
  geom_line(data = subset(sens_tbl, metric == "FDR among 'predicted contaminants'"),
            linewidth = 0.7) +
  scale_colour_manual(values = c(
      "Cross-cancer real lost"             = "#762A83",   # purple, contrast with green
      "True contaminants removed"          = COL$cancer_spec,
      "FDR among 'predicted contaminants'" = COL$contam),
      name = NULL,
      breaks = c("True contaminants removed",
                 "Cross-cancer real lost",
                 "FDR among 'predicted contaminants'"),
      guide = guide_legend(override.aes = list(
          linewidth = c(2.0, 0.6, 0.7),
          alpha     = c(0.40, 1, 1),
          linetype  = c("solid", "31", "solid")))) +
  scale_y_continuous(labels = percent_format(1), limits = c(0, 1.02),
                     expand = c(0, 0)) +
  scale_x_continuous(breaks = c(0.3, 0.5, 0.7, 0.9), limits = c(0.30, 0.99),
                     expand = c(0, 0)) +
  annotate("text", x = 0.71, y = 0.04, label = "0.7 cutoff",
           hjust = 0, size = BASE * 0.30, family = "Helvetica") +
  annotate("segment", x = 0.55, xend = 0.62, y = 1.00, yend = 0.99,
           linewidth = LINE, colour = "grey30") +
  annotate("text", x = 0.40, y = 1.00,
           label = "curves overlap exactly",
           hjust = 0, size = BASE * 0.30, family = "Helvetica",
           colour = "grey30", fontface = "italic") +
  labs(title = "PCE threshold sensitivity",
       x = "PCE threshold", y = "Fraction of species") +
  cell_theme() +
  theme(legend.position      = c(0.02, 0.55),
        legend.justification  = c(0, 1),
        legend.background     = element_rect(fill = alpha("white", 0.85),
                                             colour = NA),
        legend.key.height     = unit(8, "pt"),
        legend.key.width      = unit(16, "pt"),
        legend.spacing.y      = unit(0, "pt"),
        legend.text           = element_text(size = BASE - 1.5))

# ============================================================================
# Load merged TMB×purity table from script 02 (saved to results/)
# ============================================================================
merged    <- readRDS("results/TMB_purity_merged.rds")
corr_tbl  <- read_csv("results/TMB_purity_correlation_table.csv", show_col_types = FALSE)
quint_corr <- read_csv("results/TMB_purity_within_quintile.csv", show_col_types = FALSE)
oro_codes <- c("COAD", "READ", "STAD", "ESCA", "HNSC")
oro <- merged %>% filter(project %in% oro_codes)
oro <- oro %>%
  mutate(r_RPM = residuals(lm(log_RPM ~ purity, data = oro)),
         r_TMB = residuals(lm(log_TMB ~ purity, data = oro)))
val <- function(tag, col) corr_tbl[[col]][corr_tbl$subset == tag][1]

# ============================================================================
# PANEL D — Raw scatter (Dohlman-style replication)
# ============================================================================
pD <- ggplot(oro, aes(log_TMB, log_RPM)) +
  geom_point(aes(colour = project), alpha = 0.65, size = 0.95,
             stroke = 0, shape = 16) +
  geom_smooth(method = "lm", se = TRUE, colour = "black",
              linewidth = 0.6, fill = "grey60", alpha = 0.4) +
  scale_colour_manual(values = COL$cancer_codes, name = NULL,
                      guide = guide_legend(override.aes = list(alpha = 1, size = 1.6))) +
  annotate("text", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.4,
           label = sprintf("r = %.3f\np = %.1e\nn = %d",
                           val("Orodigestive pooled", "r_raw"),
                           val("Orodigestive pooled", "p_raw"),
                           val("Orodigestive pooled", "n")),
           size = BASE * 0.32, family = "Helvetica", lineheight = 0.95) +
  labs(title = "Raw correlation (TCGA replication)",
       x = expression(log[10]~"TMB (mut/Mb)"),
       y = expression(log[10]~"microbial load (RPM)")) +
  cell_theme() +
  theme(legend.position    = c(0.99, 0.02),
        legend.justification = c(1, 0),
        legend.key.height  = unit(8, "pt"),
        legend.spacing.y   = unit(0, "pt"),
        legend.text        = element_text(size = BASE - 1),
        legend.background  = element_rect(fill = alpha("white", 0.85),
                                          colour = NA))

# ============================================================================
# PANEL E — Forest plot: raw vs purity-adjusted r per site
# ============================================================================
plot_tbl <- corr_tbl %>%
  pivot_longer(cols = c(r_raw, r_partial), names_to = "type", values_to = "r") %>%
  mutate(type   = factor(type, levels = c("r_raw", "r_partial"),
                         labels = c("Raw", "Purity-adjusted")),
         subset = factor(subset, levels = rev(corr_tbl$subset)))

pE <- ggplot(plot_tbl, aes(r, subset, colour = type, shape = type)) +
  geom_vline(xintercept = 0, linetype = "dashed",
             linewidth = LINE, colour = "grey60") +
  geom_point(size = 1.7, position = position_dodge(width = 0.5),
             stroke = 0.6, fill = NA) +
  scale_colour_manual(values = c("Raw" = COL$raw, "Purity-adjusted" = COL$adjusted),
                      name = NULL) +
  scale_shape_manual(values = c("Raw" = 16, "Purity-adjusted" = 17),
                     name = NULL) +
  scale_x_continuous(breaks = c(-0.1, 0, 0.1, 0.2)) +
  labs(title = "Site heterogeneity in TMB-microbe correlation",
       x = "Pearson r", y = NULL) +
  cell_theme() +
  theme(legend.position = "top",
        legend.box.spacing = unit(0, "pt"),
        legend.margin = margin(0, 0, 0, 0),
        legend.key.height = unit(7, "pt"))

# ============================================================================
# PANEL F — Within-purity-quintile r
# ============================================================================
ymax <- max(c(0, quint_corr$r)) + 0.10
ymin <- min(c(0, quint_corr$r)) - 0.02

# combine n + p into one label, place above bar with controlled offset
quint_corr <- quint_corr %>%
  mutate(label = sprintf("n=%d\np=%.2g", n, p),
         lbl_y = pmax(r, 0) + 0.01)

pF <- ggplot(quint_corr, aes(factor(purity_quintile), r)) +
  geom_col(fill = COL$bar, width = 0.65, colour = NA) +
  geom_hline(yintercept = 0, linewidth = LINE, colour = "black") +
  geom_text(aes(label = label, y = lbl_y), vjust = 0,
            size = BASE * 0.32, family = "Helvetica",
            lineheight = 0.85) +
  scale_x_discrete(labels = sprintf("Q%d\n[%.2f-%.2f]",
                                    quint_corr$purity_quintile,
                                    quint_corr$pur_min,
                                    quint_corr$pur_max)) +
  scale_y_continuous(limits = c(ymin, ymax), expand = c(0, 0)) +
  labs(title = "Within-purity-quintile correlation",
       x = "ABSOLUTE purity quintile",
       y = "Pearson r (log TMB vs log RPM)") +
  cell_theme() +
  theme(axis.text.x = element_text(size = BASE - 1, lineheight = 0.9))

# ============================================================================
# COMPOSE — 2-row x 3-col layout, double-column width 17.4 cm
# ============================================================================
fig <- (pA | pB | pC) /
       (pD | pE | pF) +
  plot_layout(widths = c(1, 1.5, 1.1)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(size = PANEL_TAG_SIZE, face = "bold",
                                family = "Helvetica"),
        plot.tag.position = c(0, 1.02),
        plot.margin = margin(t = 8, r = 4, b = 2, l = 12))

# ---------- Export ----------------------------------------------------------
out_pdf <- "results/Figure1_final/Figure1.pdf"
out_png <- "results/Figure1_final/Figure1.png"

# Cell double-column = 17.4 cm wide. Slightly taller so panels breathe.
ggsave(out_pdf, fig,
       width = 17.4, height = 12.0, units = "cm",
       device = cairo_pdf)
ggsave(out_png, fig,
       width = 17.4, height = 12.0, units = "cm",
       dpi = 600, bg = "white")

cat("Saved:\n  ", out_pdf, "\n  ", out_png, "\n")

# Also a single-column tall version (one column = 8.5 cm) for option
fig_tall <- pA / pB / pC / pD / pE / pF +
  plot_layout(heights = c(1, 1.2, 1, 1, 0.6, 1)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(size = PANEL_TAG_SIZE, face = "bold",
                                family = "Helvetica"))

ggsave("results/Figure1_final/Figure1_singlecol.pdf", fig_tall,
       width = 8.5, height = 22, units = "cm", device = cairo_pdf)
cat("Also saved single-column version.\n")


