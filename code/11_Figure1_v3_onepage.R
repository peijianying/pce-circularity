# =============================================================================
# Figure 1 v3 — One-page, 3 rows × 2 columns, larger text
# =============================================================================
# A4 portrait minus 1.8 cm side margins ≈ 17.4 × 24.0 cm usable area.
# Each panel ≈ 8.4 × 7.6 cm.  Base font 9 pt (was 7 in v2).
# Output: results/Figure1_v3/Figure1_v3.{pdf,png}
# =============================================================================

suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr); library(ggplot2)
  library(scales); library(patchwork); library(cowplot); library(showtext)
  library(grid)
})

# ---- repo root ------------------------------------------------------------
.find_root <- function() {
  for (p in c(getwd(), dirname(getwd()), dirname(dirname(getwd())))) {
    if (dir.exists(file.path(p, "results"))) return(p)
  }; getwd()
}
setwd(.find_root())

# ---- font -----------------------------------------------------------------
.try_font <- function() {
  paths <- list(
    list(reg  = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Regular.otf",
         bold = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Bold.otf",
         italic = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Italic.otf"),
    list(reg = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
         bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
         italic = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf"))
  for (h in paths) if (all(file.exists(unlist(h)))) {
    font_add("Helvetica", regular = h$reg, bold = h$bold, italic = h$italic)
    return(invisible(TRUE))
  }
}
.try_font(); showtext_auto(); showtext_opts(dpi = 300)

# ---- typography knobs (everything scales from these) ----------------------
BASE  <- 8   # body axis text
LARGE <- 9   # panel title
TAG   <- 13  # A/B/C panel tags
LINE  <- 0.4

cell_theme <- function() {
  theme_classic(base_size = BASE, base_family = "Helvetica") +
    theme(text             = element_text(family = "Helvetica", colour = "black"),
          axis.text        = element_text(size = BASE, colour = "black"),
          axis.title       = element_text(size = BASE, colour = "black"),
          axis.line        = element_line(linewidth = LINE, colour = "black"),
          axis.ticks       = element_line(linewidth = LINE, colour = "black"),
          axis.ticks.length= unit(2.5, "pt"),
          plot.title       = element_text(size = LARGE, face = "bold",
                                          hjust = 0.5,
                                          margin = margin(b = 4)),
          plot.title.position = "panel",
          legend.title     = element_text(size = BASE),
          legend.text      = element_text(size = BASE - 0.5),
          legend.key.size  = unit(8, "pt"),
          legend.background= element_blank(),
          strip.background = element_blank(),
          strip.text       = element_text(size = BASE, face = "bold"),
          plot.margin      = margin(3, 5, 3, 3))
}

COL <- list(contam = "#D55E00", cancer_spec = "#009E73",
            crosscancer = "#56B4E9", null = "#999999",
            raw = "#D55E00", adjusted = "#0072B2",
            cancer_codes = c(COAD="#E69F00", READ="#F0C674", STAD="#56B4E9",
                             ESCA="#009E73", HNSC="#CC79A7"))

# ---- shared data ----------------------------------------------------------
species_table <- readRDS("results/species_table.rds")
species_table$category <- gsub("Cross-cancer REAL", "Cross-cancer real",
                               species_table$category, fixed = TRUE)
cat_levels  <- c("True contaminant","Cross-cancer real",
                 "Cancer-specific real","Null noise")
cat_palette <- c("True contaminant"=COL$contam,
                 "Cross-cancer real"=COL$crosscancer,
                 "Cancer-specific real"=COL$cancer_spec,
                 "Null noise"=COL$null)
species_table$category <- factor(species_table$category, levels = cat_levels)
species_table <- species_table %>%
  mutate(cat_lab = recode(as.character(category),
            "True contaminant"     = "True\ncontaminant",
            "Cross-cancer real"    = "Cross-cancer\nreal",
            "Cancer-specific real" = "Cancer-\nspecific real",
            "Null noise"           = "Null\nnoise"),
         cat_lab = factor(cat_lab,
            levels = c("True\ncontaminant","Cross-cancer\nreal",
                       "Cancer-\nspecific real","Null\nnoise")))

merged    <- readRDS("results/TMB_purity_merged.rds")
corr_tbl  <- read_csv("results/TMB_purity_correlation_table.csv",
                      show_col_types = FALSE)
quint_corr<- read_csv("results/TMB_purity_within_quintile.csv",
                      show_col_types = FALSE)
oro_codes <- c("COAD","READ","STAD","ESCA","HNSC")
oro       <- merged %>% filter(project %in% oro_codes)

cat("Loaded inputs.\n")

# ===========================================================================
# Panel A — PCE distribution by ground-truth class (4-row faceted histogram)
# ===========================================================================
shadeA <- data.frame(xmin = 0.7, xmax = 1.02, ymin = -Inf, ymax = Inf)
annA <- data.frame(
  cat_lab = factor("True\ncontaminant",
                   levels = levels(species_table$cat_lab)),
  x = 0.71, y = 47, lab = "PCE > 0.7\nremoved as 'contaminant'")

pA <- ggplot(species_table, aes(PCE, fill = category)) +
  geom_rect(data = shadeA, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "grey90", alpha = 0.6) +
  geom_histogram(binwidth = 0.05, color = "white",
                 linewidth = 0.25, alpha = 0.95, boundary = 0) +
  geom_vline(xintercept = 0.7, linetype = "dashed",
             linewidth = LINE, colour = "black") +
  geom_text(data = annA, inherit.aes = FALSE,
            aes(x = x, y = y, label = lab),
            hjust = 0, vjust = 1, size = BASE * 0.32,
            family = "Helvetica", colour = "grey25",
            lineheight = 0.95, fontface = "italic") +
  facet_wrap(~ cat_lab, ncol = 1, strip.position = "right") +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(breaks = c(0,.25,.5,.7,1),
                     labels = c("0","0.25","0.5","0.7","1"),
                     limits = c(0, 1.02), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0, 50), breaks = c(0, 25, 50),
                     expand = expansion(mult = c(0, 0.05))) +
  labs(title = "PCE distribution by ground-truth class",
       x = "PCE score", y = "Species (n)") +
  cell_theme() +
  theme(strip.text.y    = element_text(angle = 0, hjust = 0,
                                       size = BASE, face = "bold",
                                       lineheight = 0.9,
                                       margin = margin(l = 5, r = 2)),
        strip.placement = "outside",
        panel.spacing.y = unit(3, "pt"),
        plot.margin     = margin(3, 8, 3, 3))

# ===========================================================================
# Panel B — Per-cancer prevalence heatmap
# ===========================================================================
cancer_sizes <- c(
  Colorectal=2482, Breast=2200, Prostate=1800, Lung=1500, Brain=295,
  Ovarian=750, Renal=700, Endometrial=600, Sarcoma=500, Skin=500,
  Bladder=450, HepBili=400, Pancreatic=380, Lymphoid=350,
  Esophageal=120, Gastric=79, Oropharyngeal=251, Sinonasal=60,
  Testicular=200, Thyroid=180, Mesothelioma=100, Adrenal=90,
  HeadNeckOther=250, Myeloid=300, EyeOcular=80,
  ChildhoodSolid=400, OtherRare=354)

set.seed(7)
example_idx <- species_table %>% group_by(category) %>%
  slice_sample(n = 4) %>% pull(species_id)

prev_long <- species_table %>%
  filter(species_id %in% example_idx) %>%
  rowwise() %>%
  mutate(prev_df = list(tibble(cancer = names(cancer_sizes),
                               prev = unlist(prev)))) %>%
  ungroup() %>%
  select(species_id, category, PCE, prev_df) %>%
  unnest(prev_df)

ord_tbl <- species_table %>%
  filter(species_id %in% example_idx) %>%
  arrange(category, desc(PCE))
ord <- ord_tbl$species_id
prev_long$species_id <- factor(prev_long$species_id, levels = rev(ord))
prev_long$cancer     <- factor(prev_long$cancer, levels = names(cancer_sizes))

y_labels <- ord_tbl %>%
  arrange(match(species_id, rev(ord))) %>%
  mutate(lab = sprintf("%.2f", PCE)) %>%
  pull(lab)

# Heatmap main
pB_main <- ggplot(prev_long, aes(cancer, species_id, fill = prev)) +
  geom_tile(colour = "white", linewidth = 0.2) +
  scale_fill_gradientn(
    colours = c("white", "#DEEBF7", "#9ECAE1", "#3182BD", "#08306B"),
    values  = c(0, 0.05, 0.20, 0.5, 1),
    limits  = c(0, 1),
    breaks  = c(0, 0.25, 0.5, 0.75, 1),
    name    = "Prev.",
    guide   = guide_colorbar(barwidth = unit(0.5, "lines"),
                             barheight = unit(3.2, "lines"),
                             ticks.colour = "black",
                             frame.colour = "black",
                             title.position = "top",
                             title.hjust = 0)) +
  scale_y_discrete(labels = y_labels, position = "left") +
  scale_x_discrete(labels = names(cancer_sizes), expand = c(0, 0)) +
  labs(title = "Example species: per-cancer prevalence",
       x = NULL, y = "PCE") +
  cell_theme() +
  theme(axis.text.x  = element_text(angle = 45, hjust = 1,
                                    size = BASE - 2, colour = "black"),
        axis.text.y  = element_text(size = BASE - 1, colour = "black"),
        axis.title.y = element_text(size = BASE, face = "bold",
                                    margin = margin(r = 2)),
        axis.line    = element_blank(),
        axis.ticks   = element_blank(),
        legend.position = "right",
        legend.title    = element_text(size = BASE - 1),
        legend.box.spacing = unit(2, "pt"),
        plot.margin     = margin(3, 5, 3, 3))

# Left-side category strip
strip_df <- ord_tbl %>%
  arrange(match(species_id, rev(ord))) %>%
  mutate(species_id = factor(species_id, levels = rev(ord)), x = 1)
pB_strip <- ggplot(strip_df, aes(x = x, y = species_id, fill = category)) +
  geom_tile(width = 1, height = 1) +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  theme_void(base_family = "Helvetica") +
  theme(plot.margin = margin(0, 1, 0, 0))

# Right-side category legend
leg_df <- tibble(category = factor(cat_levels, levels = rev(cat_levels)),
                 x = 1, y = rev(seq_along(cat_levels)))
pB_legend <- ggplot(leg_df, aes(x = x, y = y, fill = category)) +
  geom_tile(width = 0.25, height = 0.6) +
  geom_text(aes(label = category), nudge_x = 0.20, hjust = 0,
            size = BASE * 0.34, family = "Helvetica") +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(limits = c(0.85, 4.5), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0.4, 5.0), expand = c(0, 0)) +
  annotate("text", x = 0.85, y = 4.7, label = "Category",
           hjust = 0, fontface = "bold",
           size = BASE * 0.40, family = "Helvetica") +
  theme_void() + theme(plot.margin = margin(0, 0, 0, 0))

pB <- (pB_strip + pB_main + pB_legend +
       plot_layout(widths = c(0.05, 1, 0.40))) &
       theme(plot.margin = margin(3, 5, 3, 3))
pB <- wrap_elements(full = pB)

# ===========================================================================
# Panel C — PCE threshold sensitivity
# ===========================================================================
thresholds <- seq(0.30, 0.99, by = 0.01)
sens_tbl <- tibble(thresh = thresholds) %>%
  rowwise() %>%
  mutate(
    fdr           = mean(species_table$category[species_table$PCE > thresh] !=
                         "True contaminant"),
    cross_lost    = mean(species_table$PCE[species_table$category ==
                         "Cross-cancer real"] > thresh),
    contam_caught = mean(species_table$PCE[species_table$category ==
                         "True contaminant"] > thresh)
  ) %>% ungroup() %>%
  pivot_longer(-thresh, names_to = "metric", values_to = "value") %>%
  mutate(metric = recode(metric,
            fdr           = "FDR among 'predicted contaminants'",
            cross_lost    = "Cross-cancer real lost",
            contam_caught = "True contaminants removed"))

shadeC <- data.frame(xmin = 0.7, xmax = 0.99, ymin = 0, ymax = 1.02)

pC <- ggplot(sens_tbl, aes(thresh, value, colour = metric)) +
  geom_rect(data = shadeC, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "grey92") +
  geom_vline(xintercept = 0.7, linetype = "dashed",
             linewidth = LINE, colour = "black") +
  geom_line(data = subset(sens_tbl, metric == "True contaminants removed"),
            linewidth = 2.8, alpha = 0.35) +
  geom_line(data = subset(sens_tbl, metric == "Cross-cancer real lost"),
            linewidth = 0.9, linetype = "31") +
  geom_line(data = subset(sens_tbl, metric == "FDR among 'predicted contaminants'"),
            linewidth = 0.9) +
  scale_colour_manual(
    values = c(
      "Cross-cancer real lost"             = "#762A83",
      "True contaminants removed"          = COL$cancer_spec,
      "FDR among 'predicted contaminants'" = COL$contam),
    name = NULL,
    breaks = c("True contaminants removed",
               "Cross-cancer real lost",
               "FDR among 'predicted contaminants'"),
    labels = c("True contaminants removed",
               "Cross-cancer real lost",
               "FDR among predicted contaminants"),
    guide = guide_legend(
      override.aes = list(
        linewidth = c(2.8, 0.9, 0.9),
        alpha     = c(0.35, 1, 1),
        linetype  = c("solid", "31", "solid")),
      ncol = 1,
      keywidth = unit(1.5, "lines"),
      keyheight = unit(0.7, "lines"))) +
  scale_y_continuous(labels = percent_format(1), limits = c(0, 1.02),
                     expand = c(0, 0)) +
  scale_x_continuous(breaks = c(0.3, 0.5, 0.7, 0.9), limits = c(0.30, 0.99),
                     expand = c(0, 0)) +
  annotate("text", x = 0.70, y = -0.06,
           label = "0.7", hjust = 0.5, vjust = 1,
           size = BASE * 0.34, family = "Helvetica",
           colour = "black", fontface = "bold") +
  labs(title = "PCE threshold sensitivity",
       x = "PCE threshold", y = "Fraction of species") +
  cell_theme() +
  theme(legend.position    = c(0.36, 0.32),
        legend.justification = c(0, 0.5),
        legend.background  = element_rect(fill = alpha("white", 0.75),
                                          colour = NA),
        legend.text        = element_text(size = BASE - 1.5),
        legend.margin      = margin(2, 4, 2, 4),
        plot.margin        = margin(3, 6, 4, 3),
        axis.text.x        = element_text(margin = margin(t = 2, b = 4)))


# ===========================================================================
# Panel D — Raw correlation (TCGA replication)
# ===========================================================================
val <- function(tag, col) corr_tbl[[col]][corr_tbl$subset == tag][1]
stats_lab <- sprintf("r = %.3f, p = %.1e, n = %d",
                     val("Orodigestive pooled", "r_raw"),
                     val("Orodigestive pooled", "p_raw"),
                     val("Orodigestive pooled", "n"))

pD <- ggplot(oro, aes(log_TMB, log_RPM)) +
  geom_point(aes(colour = project), alpha = 0.55, size = 1.05,
             stroke = 0, shape = 16) +
  geom_smooth(method = "lm", se = TRUE, colour = "black",
              linewidth = 0.7, fill = "grey60", alpha = 0.4) +
  scale_colour_manual(values = COL$cancer_codes, name = NULL,
                      guide = guide_legend(
                        override.aes = list(alpha = 1, size = 2.0),
                        nrow = 1)) +
  annotate("label", x = Inf, y = -Inf, hjust = 1.05, vjust = -0.5,
           label = stats_lab,
           size = BASE * 0.36, family = "Helvetica",
           label.size = 0, fill = alpha("white", 0.85),
           label.padding = unit(2.5, "pt")) +
  labs(title = "Raw correlation (TCGA replication)",
       x = expression(log[10]~"TMB (mut/Mb)"),
       y = expression(log[10]~"microbial load (RPM)")) +
  cell_theme() +
  theme(legend.position    = "bottom",
        legend.box.spacing = unit(1, "pt"),
        legend.margin      = margin(t = 2, b = 0),
        legend.key.height  = unit(8, "pt"),
        legend.key.width   = unit(11, "pt"),
        legend.text        = element_text(size = BASE - 0.5),
        plot.margin        = margin(3, 6, 3, 3))

# ===========================================================================
# Panel E — Site-stratified Pearson r forest
# ===========================================================================
plot_tbl <- corr_tbl %>%
  pivot_longer(cols = c(r_raw, r_partial),
               names_to = "type", values_to = "r") %>%
  mutate(type   = factor(type, levels = c("r_raw", "r_partial"),
                         labels = c("Raw", "Purity-adjusted")),
         subset = factor(subset, levels = rev(corr_tbl$subset)))

label_tbl <- plot_tbl %>%
  mutate(lab = sprintf("%.2f", r),
         x_text = r + ifelse(r >= 0, 0.012, -0.012),
         hjust  = ifelse(r >= 0, 0, 1))

pE <- ggplot(plot_tbl, aes(r, subset, colour = type, shape = type)) +
  geom_vline(xintercept = 0, linetype = "dashed",
             linewidth = LINE, colour = "grey60") +
  geom_point(size = 2.2, position = position_dodge(width = 0.55),
             stroke = 0.7, fill = NA) +
  geom_text(data = label_tbl,
            aes(x = x_text, y = subset, label = lab,
                colour = type, hjust = hjust),
            position = position_dodge(width = 0.55),
            size = BASE * 0.32, family = "Helvetica",
            show.legend = FALSE) +
  scale_colour_manual(values = c("Raw" = COL$raw,
                                 "Purity-adjusted" = COL$adjusted),
                      name = NULL) +
  scale_shape_manual(values = c("Raw" = 16, "Purity-adjusted" = 17),
                     name = NULL) +
  scale_x_continuous(breaks = c(-0.1, 0, 0.1, 0.2),
                     limits = c(-0.16, 0.27),
                     expand = c(0, 0)) +
  labs(title = "Site heterogeneity in TMB-microbe correlation",
       x = "Pearson r", y = NULL) +
  cell_theme() +
  theme(legend.position    = "top",
        legend.direction   = "horizontal",
        legend.box.spacing = unit(1, "pt"),
        legend.margin      = margin(0, 0, 2, 0),
        legend.key.height  = unit(8, "pt"),
        legend.key.width   = unit(11, "pt"),
        plot.margin        = margin(3, 6, 3, 3))

# ===========================================================================
# Panel F — Within-purity-quintile correlation
# ===========================================================================
quint_corr <- quint_corr %>%
  mutate(sig = p < 0.05,
         label = sprintf("n=%d\np=%.2g", n, p),
         lbl_y = pmax(r, 0) + 0.012)
ymaxF <- max(c(0, quint_corr$r)) + 0.13
yminF <- min(c(0, quint_corr$r)) - 0.03

pF <- ggplot(quint_corr, aes(factor(purity_quintile), r, fill = sig)) +
  geom_col(width = 0.65, colour = NA) +
  geom_hline(yintercept = 0, linewidth = LINE, colour = "black") +
  geom_text(aes(label = label, y = lbl_y), vjust = 0,
            size = BASE * 0.32, family = "Helvetica",
            lineheight = 0.85) +
  scale_fill_manual(values = c("TRUE" = "#0072B2", "FALSE" = "#B0B0B0"),
                    labels = c("TRUE" = "p < 0.05", "FALSE" = "n.s."),
                    name = NULL,
                    guide = guide_legend(override.aes = list(alpha = 1))) +
  scale_x_discrete(labels = sprintf("Q%d\n[%.2f-%.2f]",
                                    quint_corr$purity_quintile,
                                    quint_corr$pur_min,
                                    quint_corr$pur_max)) +
  scale_y_continuous(limits = c(yminF, ymaxF), expand = c(0, 0)) +
  labs(title = "Within-purity-quintile correlation",
       x = "ABSOLUTE purity quintile",
       y = "Pearson r (log TMB vs log RPM)") +
  cell_theme() +
  theme(axis.text.x = element_text(size = BASE - 1, lineheight = 0.9),
        legend.position    = "top",
        legend.box.spacing = unit(1, "pt"),
        legend.margin      = margin(0, 0, 2, 0),
        legend.key.height  = unit(8, "pt"),
        legend.key.width   = unit(11, "pt"),
        plot.margin        = margin(3, 6, 3, 3))

# ===========================================================================
# Compose: 3 rows × 2 columns, A4 portrait one-page layout
# ===========================================================================
dir.create("results/Figure1_v3", showWarnings = FALSE, recursive = TRUE)

fig <- (pA | pB) /
       (pC | pD) /
       (pE | pF) +
  plot_layout(heights = c(1.05, 1.05, 1.0)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(size = TAG, face = "bold",
                                family = "Helvetica",
                                hjust = 0, vjust = 0),
        plot.tag.position = c(0, 1),
        plot.title       = element_text(size = LARGE, face = "bold",
                                        margin = margin(l = 12, b = 5)),
        plot.margin      = margin(t = 14, r = 6, b = 4, l = 4))

ggsave("results/Figure1_v3/Figure1_v3.pdf", fig,
       width = 17.4, height = 24.0, units = "cm", device = cairo_pdf)
ggsave("results/Figure1_v3/Figure1_v3.png", fig,
       width = 17.4, height = 24.0, units = "cm", dpi = 600, bg = "white")
cat("Figure 1 v3 (one-page, 3x2) saved.\n")




