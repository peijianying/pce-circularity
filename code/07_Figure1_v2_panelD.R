# =============================================================================
# Figure 1 v2 — Panel D (revision: legend below, stats annotation in white box)
# =============================================================================
suppressPackageStartupMessages({
  library(dplyr); library(tidyr); library(readr); library(ggplot2)
  library(scales); library(showtext)
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

COL <- list(
  cancer_codes  = c(COAD = "#E69F00", READ = "#F0C674",
                    STAD = "#56B4E9", ESCA = "#009E73",
                    HNSC = "#CC79A7"))

merged    <- readRDS("results/TMB_purity_merged.rds")
corr_tbl  <- read_csv("results/TMB_purity_correlation_table.csv", show_col_types = FALSE)
oro_codes <- c("COAD", "READ", "STAD", "ESCA", "HNSC")
oro <- merged %>% filter(project %in% oro_codes)

val <- function(tag, col) corr_tbl[[col]][corr_tbl$subset == tag][1]

# Stats label (single line; place in TOP-LEFT corner, white background)
stats_lab <- sprintf("r = %.3f, p = %.1e, n = %d",
                     val("Orodigestive pooled", "r_raw"),
                     val("Orodigestive pooled", "p_raw"),
                     val("Orodigestive pooled", "n"))

pD <- ggplot(oro, aes(log_TMB, log_RPM)) +
  geom_point(aes(colour = project), alpha = 0.55, size = 0.95,
             stroke = 0, shape = 16) +
  geom_smooth(method = "lm", se = TRUE, colour = "black",
              linewidth = 0.6, fill = "grey60", alpha = 0.4) +
  scale_colour_manual(values = COL$cancer_codes, name = NULL,
                      guide = guide_legend(
                        override.aes = list(alpha = 1, size = 1.8),
                        nrow = 1)) +
  annotate("label", x = -Inf, y = Inf, hjust = -0.05, vjust = 1.2,
           label = stats_lab,
           size = BASE * 0.34, family = "Helvetica",
           label.size = 0, fill = alpha("white", 0.85),
           label.padding = unit(2, "pt")) +
  labs(title = "Raw correlation (TCGA replication)",
       x = expression(log[10]~"TMB (mut/Mb)"),
       y = expression(log[10]~"microbial load (RPM)")) +
  cell_theme() +
  theme(legend.position    = "bottom",
        legend.box.spacing = unit(1, "pt"),
        legend.margin      = margin(t = 2, b = 0),
        legend.key.height  = unit(7, "pt"),
        legend.key.width   = unit(10, "pt"),
        legend.text        = element_text(size = BASE - 0.5),
        plot.margin        = margin(2, 6, 2, 2))

ggsave("results/Figure1_v2/panels/panelD.png", pD,
       width = 7.0, height = 7.5, units = "cm", dpi = 600, bg = "white")
ggsave("results/Figure1_v2/panels/panelD.pdf", pD,
       width = 7.0, height = 7.5, units = "cm", device = cairo_pdf)
cat("Panel D v2 saved.\n")
