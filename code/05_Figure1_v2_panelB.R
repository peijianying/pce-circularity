# =============================================================================
# Figure 1 v2 — Panel B (revision 2: clean side legend, fewer x-labels)
# =============================================================================
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(ggplot2); library(scales)
  library(patchwork); library(showtext); library(grid)
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

cancer_sizes <- c(
  Colorectal=2482, Breast=2200, Prostate=1800, Lung=1500, Brain=295,
  Ovarian=750, Renal=700, Endometrial=600, Sarcoma=500, Skin=500,
  Bladder=450, HepBili=400, Pancreatic=380, Lymphoid=350,
  Esophageal=120, Gastric=79, Oropharyngeal=251, Sinonasal=60,
  Testicular=200, Thyroid=180, Mesothelioma=100, Adrenal=90,
  HeadNeckOther=250, Myeloid=300, EyeOcular=80,
  ChildhoodSolid=400, OtherRare=354
)

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

# Show all 27 cancer-type labels on the x-axis (was previously truncated to
# top-10, which left the right half of the heatmap unlabelled).
cancer_labels_display <- names(cancer_sizes)

# ---------- Heatmap (main) -------------------------------------------------
pB_main <- ggplot(prev_long, aes(cancer, species_id, fill = prev)) +
  geom_tile(colour = "white", linewidth = 0.25) +
  scale_fill_gradientn(
    colours = c("white", "#DEEBF7", "#9ECAE1", "#3182BD", "#08306B"),
    values  = c(0, 0.05, 0.20, 0.5, 1),
    limits  = c(0, 1),
    breaks  = c(0, 0.25, 0.5, 0.75, 1),
    name    = "Prev.",
    guide   = guide_colorbar(barwidth = unit(0.4, "lines"),
                             barheight = unit(2.8, "lines"),
                             ticks.colour = "black",
                             frame.colour = "black",
                             title.position = "top",
                             title.hjust = 0)) +
  scale_y_discrete(labels = y_labels, position = "left") +
  scale_x_discrete(labels = cancer_labels_display, expand = c(0, 0)) +
  labs(title = "Example species: per-cancer prevalence",
       x = NULL, y = "PCE") +
  cell_theme() +
  theme(axis.text.x  = element_text(angle = 45, hjust = 1,
                                    size = BASE - 2, colour = "black"),
        axis.text.y  = element_text(size = BASE - 0.5, colour = "black",
                                    family = "Helvetica"),
        axis.title.y = element_text(size = BASE, face = "bold",
                                    margin = margin(r = 2)),
        axis.line    = element_blank(),
        axis.ticks   = element_blank(),
        legend.position = "right",
        legend.title    = element_text(size = BASE - 1),
        legend.box.spacing = unit(2, "pt"),
        plot.margin     = margin(2, 4, 2, 2))

# ---------- Left-side category color strip --------------------------------
strip_df <- ord_tbl %>%
  arrange(match(species_id, rev(ord))) %>%
  mutate(species_id = factor(species_id, levels = rev(ord)),
         x = 1)

pB_strip <- ggplot(strip_df, aes(x = x, y = species_id, fill = category)) +
  geom_tile(width = 1, height = 1) +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  theme_void(base_family = "Helvetica") +
  theme(legend.position = "none",
        plot.margin = margin(0, 1, 0, 0))

# ---------- Category legend (right-side standalone plot) ------------------
leg_df <- tibble(
  category = factor(cat_levels, levels = rev(cat_levels)),
  x = 1, y = rev(seq_along(cat_levels)))

pB_legend <- ggplot(leg_df, aes(x = x, y = y, fill = category)) +
  geom_tile(width = 0.25, height = 0.6) +
  geom_text(aes(label = category), nudge_x = 0.20, hjust = 0,
            size = BASE * 0.32, family = "Helvetica") +
  scale_fill_manual(values = cat_palette, guide = "none") +
  scale_x_continuous(limits = c(0.85, 3.5), expand = c(0, 0)) +
  scale_y_continuous(limits = c(0.4, 5.0), expand = c(0, 0)) +
  annotate("text", x = 0.85, y = 4.7,
           label = "Category", hjust = 0, fontface = "bold",
           size = BASE * 0.36, family = "Helvetica") +
  theme_void() +
  theme(plot.margin = margin(0, 0, 0, 0))

# ---------- Compose ------------------------------------------------------
pB_full <- pB_strip + pB_main + pB_legend +
  plot_layout(widths = c(0.06, 1, 0.30))

ggsave("results/Figure1_v2/panels/panelB.png", pB_full,
       width = 11.0, height = 7.5, units = "cm", dpi = 600, bg = "white")
ggsave("results/Figure1_v2/panels/panelB.pdf", pB_full,
       width = 11.0, height = 7.5, units = "cm", device = cairo_pdf)
cat("Panel B v3 saved.\n")
