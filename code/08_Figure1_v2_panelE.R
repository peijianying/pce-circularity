# =============================================================================
# Figure 1 v2 — Panel E (revision: add r-value labels, cleaner top legend)
# =============================================================================
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr); library(ggplot2); library(showtext)
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

COL <- list(raw = "#D55E00", adjusted = "#0072B2")

corr_tbl <- read_csv("results/TMB_purity_correlation_table.csv", show_col_types = FALSE)

plot_tbl <- corr_tbl %>%
  pivot_longer(cols = c(r_raw, r_partial), names_to = "type", values_to = "r") %>%
  mutate(type   = factor(type, levels = c("r_raw", "r_partial"),
                         labels = c("Raw", "Purity-adjusted")),
         subset = factor(subset, levels = rev(corr_tbl$subset)))

# Add r-value text labels
label_tbl <- plot_tbl %>%
  mutate(lab = sprintf("%.2f", r),
         x_text = r + ifelse(r >= 0, 0.012, -0.012),
         hjust  = ifelse(r >= 0, 0, 1))

pE <- ggplot(plot_tbl, aes(r, subset, colour = type, shape = type)) +
  geom_vline(xintercept = 0, linetype = "dashed",
             linewidth = LINE, colour = "grey60") +
  geom_point(size = 1.9, position = position_dodge(width = 0.5),
             stroke = 0.6, fill = NA) +
  geom_text(data = label_tbl,
            aes(x = x_text, y = subset, label = lab,
                colour = type, hjust = hjust),
            position = position_dodge(width = 0.5),
            size = BASE * 0.30, family = "Helvetica",
            show.legend = FALSE) +
  scale_colour_manual(values = c("Raw" = COL$raw, "Purity-adjusted" = COL$adjusted),
                      name = NULL) +
  scale_shape_manual(values = c("Raw" = 16, "Purity-adjusted" = 17),
                     name = NULL) +
  scale_x_continuous(breaks = c(-0.1, 0, 0.1, 0.2),
                     limits = c(-0.16, 0.27),
                     expand = c(0, 0)) +
  labs(title = "Site heterogeneity in TMB-microbe correlation",
       x = "Pearson r", y = NULL) +
  cell_theme() +
  theme(legend.position = "top",
        legend.direction = "horizontal",
        legend.box.spacing = unit(1, "pt"),
        legend.margin = margin(0, 0, 2, 0),
        legend.key.height = unit(7, "pt"),
        legend.key.width = unit(10, "pt"),
        plot.margin = margin(2, 6, 2, 2))

ggsave("results/Figure1_v2/panels/panelE.png", pE,
       width = 8.0, height = 6.5, units = "cm", dpi = 600, bg = "white")
ggsave("results/Figure1_v2/panels/panelE.pdf", pE,
       width = 8.0, height = 6.5, units = "cm", device = cairo_pdf)
cat("Panel E v2 saved.\n")
