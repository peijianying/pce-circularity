# =============================================================================
# Figure 1 v2 — Panel F (revision: cleaner labels, baseline highlight)
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

quint_corr <- read_csv("results/TMB_purity_within_quintile.csv", show_col_types = FALSE)

# Color bars: significant vs not
quint_corr <- quint_corr %>%
  mutate(sig = p < 0.05,
         bar_color = ifelse(sig, "#0072B2", "#B0B0B0"),
         label = sprintf("n=%d\np=%.2g", n, p),
         lbl_y = pmax(r, 0) + 0.012)

ymax <- max(c(0, quint_corr$r)) + 0.12
ymin <- min(c(0, quint_corr$r)) - 0.03

pF <- ggplot(quint_corr, aes(factor(purity_quintile), r,
                             fill = sig)) +
  geom_col(width = 0.65, colour = NA) +
  geom_hline(yintercept = 0, linewidth = LINE, colour = "black") +
  geom_text(aes(label = label, y = lbl_y), vjust = 0,
            size = BASE * 0.30, family = "Helvetica",
            lineheight = 0.85) +
  scale_fill_manual(values = c("TRUE" = "#0072B2", "FALSE" = "#B0B0B0"),
                    labels = c("TRUE" = "p < 0.05", "FALSE" = "n.s."),
                    name = NULL,
                    guide = guide_legend(override.aes = list(alpha = 1))) +
  scale_x_discrete(labels = sprintf("Q%d\n[%.2f-%.2f]",
                                    quint_corr$purity_quintile,
                                    quint_corr$pur_min,
                                    quint_corr$pur_max)) +
  scale_y_continuous(limits = c(ymin, ymax), expand = c(0, 0)) +
  labs(title = "Within-purity-quintile correlation",
       x = "ABSOLUTE purity quintile",
       y = "Pearson r (log TMB vs log RPM)") +
  cell_theme() +
  theme(axis.text.x = element_text(size = BASE - 1, lineheight = 0.9),
        legend.position = "top",
        legend.box.spacing = unit(1, "pt"),
        legend.margin = margin(0, 0, 2, 0),
        legend.key.height = unit(7, "pt"),
        legend.key.width = unit(10, "pt"),
        plot.margin = margin(2, 6, 2, 2))

ggsave("results/Figure1_v2/panels/panelF.png", pF,
       width = 7.0, height = 7.0, units = "cm", dpi = 600, bg = "white")
ggsave("results/Figure1_v2/panels/panelF.pdf", pF,
       width = 7.0, height = 7.0, units = "cm", device = cairo_pdf)
cat("Panel F v2 saved.\n")
