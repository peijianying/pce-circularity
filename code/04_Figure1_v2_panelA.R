# =============================================================================
# Figure 1 v2 — Panel A (revision 2: shaded flagged region, unified y-scale,
#                        bigger strip text, threshold annotation)
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

species_table <- readRDS("results/species_table.rds")
species_table$category <- gsub("Cross-cancer REAL", "Cross-cancer real",
                               species_table$category, fixed = TRUE)
cat_levels  <- c("True contaminant","Cross-cancer real","Cancer-specific real","Null noise")
cat_palette <- c("True contaminant"=COL$contam,"Cross-cancer real"=COL$crosscancer,
                 "Cancer-specific real"=COL$cancer_spec,"Null noise"=COL$null)
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

# ---- Build the panel ------------------------------------------------------
shade_df <- data.frame(xmin = 0.7, xmax = 1.02, ymin = -Inf, ymax = Inf)

pA <- ggplot(species_table, aes(PCE, fill = category)) +
  # grey shade marking "removed as contaminant" zone
  geom_rect(data = shade_df, inherit.aes = FALSE,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = "grey90", alpha = 0.6) +
  geom_histogram(binwidth = 0.05, color = "white", linewidth = 0.2,
                 alpha = 0.95, boundary = 0) +
  geom_vline(xintercept = 0.7, linetype = "dashed",
             linewidth = LINE, colour = "black") +
  facet_wrap(~ cat_lab, ncol = 1, strip.position = "right") +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(breaks = c(0,.25,.5,.7,1),
                     labels = c("0","0.25","0.5","0.7","1"),
                     limits = c(0, 1.02), expand = c(0,0)) +
  scale_y_continuous(limits = c(0, 50), breaks = c(0, 25, 50),
                     expand = expansion(mult = c(0, 0.05))) +
  labs(title = "PCE distribution by ground-truth class",
       x = "PCE score", y = "Species (n)") +
  cell_theme() +
  theme(strip.text.y       = element_text(angle = 0, hjust = 0,
                                          size  = BASE,
                                          face  = "bold",
                                          lineheight = 0.9,
                                          margin = margin(l = 4, r = 2)),
        strip.placement    = "outside",
        panel.spacing.y    = unit(3, "pt"),
        plot.title         = element_text(size = LARGE, face = "bold"),
        plot.margin        = margin(t = 14, r = 6, b = 2, l = 2))

# Add a single annotation OUTSIDE the panels (at the top) using cowplot/grid.
# Simpler approach: use plot.subtitle or annotation_custom in the FIRST facet only.
# We'll use a top annotation by wrapping with a top-grob via geom_text in the first row.
# Trick: use a tag with a small phantom panel above is complex; instead place
# annotation INSIDE the top panel only, anchored to the top-right.

ann_tbl <- data.frame(
  cat_lab = factor("True\ncontaminant",
                   levels = c("True\ncontaminant","Cross-cancer\nreal",
                              "Cancer-\nspecific real","Null\nnoise")),
  x = 0.71, y = 47, lab = "PCE > 0.7\nremoved as 'contaminant'")

pA <- pA +
  geom_text(data = ann_tbl, inherit.aes = FALSE,
            aes(x = x, y = y, label = lab),
            hjust = 0, vjust = 1, size = BASE * 0.32,
            family = "Helvetica", colour = "grey25",
            lineheight = 0.95, fontface = "italic")

ggsave("results/Figure1_v2/panels/panelA.png", pA,
       width = 7.0, height = 8.0, units = "cm", dpi = 600, bg = "white")
ggsave("results/Figure1_v2/panels/panelA.pdf", pA,
       width = 7.0, height = 8.0, units = "cm", device = cairo_pdf)
cat("Panel A v2 saved.\n")
