# =============================================================================
# Figure 1 v2 — Final assembly (all 6 panels, 2×3 grid)
# =============================================================================
suppressPackageStartupMessages({
  library(dplyr); library(ggplot2); library(patchwork); library(showtext)
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

BASE <- 7; LARGE <- 8
PANEL_TAG_SIZE <- 10

# Load pre-rendered PNG panels (PDF reading via ImageMagick is blocked by
# system security policy; the 600 dpi PNGs are equivalent for assembly).
pA <- cowplot::ggdraw() + cowplot::draw_image("results/Figure1_v2/panels/panelA.png")
pB <- cowplot::ggdraw() + cowplot::draw_image("results/Figure1_v2/panels/panelB.png")
pC <- cowplot::ggdraw() + cowplot::draw_image("results/Figure1_v2/panels/panelC.png")
pD <- cowplot::ggdraw() + cowplot::draw_image("results/Figure1_v2/panels/panelD.png")
pE <- cowplot::ggdraw() + cowplot::draw_image("results/Figure1_v2/panels/panelE.png")
pF <- cowplot::ggdraw() + cowplot::draw_image("results/Figure1_v2/panels/panelF.png")

# Compose: 2 rows × 3 cols
fig <- (pA | pB | pC) / (pD | pE | pF) +
  plot_layout(heights = c(1, 1)) +
  plot_annotation(tag_levels = "A") &
  theme(plot.tag = element_text(size = PANEL_TAG_SIZE, face = "bold",
                                family = "Helvetica"))

# Cell double-column = 17.4 cm wide, taller to fit all 6 panels
ggsave("results/Figure1_v2/Figure1_v2.pdf", fig,
       width = 17.4, height = 16.0, units = "cm", device = cairo_pdf)
ggsave("results/Figure1_v2/Figure1_v2.png", fig,
       width = 17.4, height = 16.0, units = "cm", dpi = 600, bg = "white")
cat("Figure 1 v2 (6-panel) saved.\n")
