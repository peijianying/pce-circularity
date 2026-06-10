# =============================================================================
# Figure 1 v2 — Panel C (revision: legend below, no in-plot text clutter)
# =============================================================================
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(ggplot2); library(scales); library(showtext)
})

.find_root <- function() {
  for (p in c(getwd(), dirname(getwd()), dirname(dirname(getwd())))) {
    if (dir.exists(file.path(p, "results"))) return(p)
  }; getwd()
}
setwd(.find_root())

.try_font <- function() {
  paths <- list(
    list(reg  = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Regular.otf",
         bold = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Bold.otf",
         italic = "/usr/share/fonts/opentype/urw-base35/NimbusSans-Italic.otf"),
    list(reg = "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
         bold = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
         italic = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf"))
  for (h in paths) if (all(file.exists(unlist(h)))) {
    font_add("Helvetica", regular = h$reg, bold = h$bold, italic = h$italic); return(invisible(TRUE))
  }
}
.try_font(); showtext_auto(); showtext_opts(dpi = 300)

BASE <- 7; LARGE <- 8; LINE <- 0.35

cell_theme <- function() {
  theme_classic(base_size = BASE, base_family = "Helvetica") +
    theme(text = element_text(family = "Helvetica", colour = "black"),
          axis.text = element_text(size = BASE, colour = "black"),
          axis.title = element_text(size = BASE, colour = "black"),
          axis.line = element_line(linewidth = LINE, colour = "black"),
          axis.ticks = element_line(linewidth = LINE, colour = "black"),
          axis.ticks.length = unit(2, "pt"),
          plot.title = element_text(size = LARGE, face = "bold", hjust = 0,
                                    margin = margin(b = 4)),
          plot.title.position = "plot",
          legend.title = element_text(size = BASE),
          legend.text = element_text(size = BASE - 0.5),
          legend.key.size = unit(7, "pt"),
          legend.background = element_blank(),
          strip.background = element_blank(),
          strip.text = element_text(size = BASE, face = "bold"),
          plot.margin = margin(2, 4, 2, 2))
}

COL <- list(contam = "#D55E00", cancer_spec = "#009E73",
            crosscancer = "#56B4E9", null = "#999999")

# Re-generate sensitivity table (cheap)
species_table <- readRDS("results/species_table.rds")
species_table$category <- gsub("Cross-cancer REAL", "Cross-cancer real",
                               species_table$category, fixed = TRUE)

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

# Shaded region marking PCE > 0.7
shade_df <- data.frame(xmin = 0.7, xmax = 0.99, ymin = 0, ymax = 1.02)

pC <- ggplot(sens_tbl, aes(thresh, value, colour = metric)) +
  # grey shade for "removed as contaminant" zone
  geom_rect(data = shade_df, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "grey92") +
  # vertical line at 0.7
  geom_vline(xintercept = 0.7, linetype = "dashed",
             linewidth = LINE, colour = "black") +
  # background line: True contaminants removed (wide, semi-transparent)
  geom_line(data = subset(sens_tbl, metric == "True contaminants removed"),
            linewidth = 2.5, alpha = 0.35) +
  # foreground line: Cross-cancer real lost (dashed, on top)
  geom_line(data = subset(sens_tbl, metric == "Cross-cancer real lost"),
            linewidth = 0.7, linetype = "31") +
  # FDR line
  geom_line(data = subset(sens_tbl, metric == "FDR among 'predicted contaminants'"),
            linewidth = 0.8) +
  scale_colour_manual(
    values = c(
      "Cross-cancer real lost"             = "#762A83",
      "True contaminants removed"          = COL$cancer_spec,
      "FDR among 'predicted contaminants'" = COL$contam),
    name = NULL,
    breaks = c("True contaminants removed",
               "Cross-cancer real lost",
               "FDR among 'predicted contaminants'"),
    labels = c("True contaminants\nremoved",
               "Cross-cancer real\nlost",
               "FDR among predicted\ncontaminants"),
    guide = guide_legend(
      override.aes = list(
        linewidth = c(2.5, 0.7, 0.8),
        alpha     = c(0.35, 1, 1),
        linetype  = c("solid", "31", "solid")),
      ncol = 1,
      keywidth = unit(1.6, "lines"),
      keyheight = unit(0.9, "lines"))) +
  scale_y_continuous(labels = percent_format(1), limits = c(0, 1.02),
                     expand = c(0, 0)) +
  scale_x_continuous(breaks = c(0.3, 0.5, 0.7, 0.9), limits = c(0.30, 0.99),
                     expand = c(0, 0)) +
  # threshold annotation BELOW the axis
  annotate("text", x = 0.70, y = -0.06,
           label = "0.7", hjust = 0.5, vjust = 1,
           size = BASE * 0.32, family = "Helvetica",
           colour = "black", fontface = "bold") +
  labs(title = "PCE threshold sensitivity",
       x = "PCE threshold", y = "Fraction of species") +
  cell_theme() +
  theme(legend.position    = "bottom",
        legend.direction   = "vertical",
        legend.text        = element_text(size = BASE - 1, lineheight = 0.85),
        legend.spacing.y   = unit(0, "pt"),
        legend.box.margin  = margin(t = 2, b = 0),
        legend.margin      = margin(t = 4, r = 0, b = 0, l = 0),
        plot.margin        = margin(2, 6, 8, 2),
        axis.text.x        = element_text(margin = margin(t = 2, b = 4)))

ggsave("results/Figure1_v2/panels/panelC.png", pC,
       width = 7.5, height = 9.0, units = "cm", dpi = 600, bg = "white")
ggsave("results/Figure1_v2/panels/panelC.pdf", pC,
       width = 7.5, height = 9.0, units = "cm", device = cairo_pdf)
cat("Panel C v2 saved.\n")
