# pce-circularity

**Reanalysis and methodological critique of Dohlman et al., *Cell* 2026.**
*"Biodiversity and biogeography of the multi-kingdom cancer microbiome"* (doi:[10.1016/j.cell.2026.04.015](https://doi.org/10.1016/j.cell.2026.04.015))

This repository contains the code, processed data, and figures supporting our *Cell* Matters Arising / bioRxiv preprint:

> **Pan-cancer equiprevalence cannot distinguish contaminants from cross-cancer microbiota**
> [Authors]. bioRxiv (2026). doi:[TBD]

---

## TL;DR

Dohlman et al. flag pan-cancer-equiprevalent species (PCE > 0.7) as contaminants and remove them, then conclude that "most non-orodigestive cancers lack a microbiome." We show that:

1. **PCE cannot distinguish a true reagent contaminant from a microbe genuinely shared across cancer types** — both produce uniform cross-cancer prevalence by construction. In simulation, **100% of cross-cancer real microbiota are flagged as contaminants** at the published threshold, identical to true contaminants (median PCE 0.957 vs 0.955).
2. **The TMB–microbial-load correlation reverses in 2 of 5 TCGA orodigestive sites** (ESCA, HNSC) and is partially driven by tumor purity, a shared denominator.

The orodigestive findings (multi-kingdom communities, *F. nucleatum*–MSI association) are independent of these concerns and remain valuable.

---

## Repository structure

```
pce-circularity/
├── README.md                              <- this file
├── LICENSE                                <- MIT
├── CITATION.cff                           <- citation metadata for Zenodo / GitHub
├── renv.lock                              <- (optional) R session lock
├── environment.txt                        <- minimum software requirements
├── .gitignore
│
├── code/
│   ├── 01_PCE_circularity_simulation.R    <- Figure 1A–C (simulation)
│   ├── 02_TMB_purity_reanalysis.R         <- Figure 1D–F (TCGA reanalysis)
│   └── 03_Figure1_final.R                 <- composite Figure 1, Cell-style
│
├── manuscript/
│   ├── MattersArising_v0.2.md             <- main text
│   ├── CoverLetter_v0.1.md                <- cover letter to Cell
│   └── bioRxiv_package_v0.1.md            <- preprint metadata + thread
│
├── results/
│   ├── Figure1_final/Figure1.pdf          <- production figure (vector)
│   ├── Figure1_final/Figure1.png          <- 600 dpi
│   ├── Figure1_final/Figure1_singlecol.pdf
│   ├── PCE_summary_by_category.csv        <- simulation summary
│   ├── PCE_threshold_sensitivity.csv      <- threshold sweep
│   ├── TMB_purity_correlation_table.csv   <- raw vs purity-adjusted r per site
│   ├── TMB_purity_within_quintile.csv     <- within-purity-quintile r
│   ├── TMB_purity_merged.rds              <- intermediate merged table (n=1024)
│   └── species_table.rds                  <- simulation output
│
└── data/                                  <- (not tracked in git; see Data section)
    ├── WGS/                               <- TCMA WGS microbiome (Dohlman 2021)
    ├── WXS/                               <- TCMA WXS microbiome (used here)
    ├── metadata/                          <- TCMA metadata
    ├── TCGA_ABSOLUTE_purity.tsv           <- Aran 2015
    └── mc3.nonsilent.gene.matrix.gz       <- MC3 v0.2.8 PUBLIC (UCSC Xena mirror)
```

---

## How to reproduce all results

### 1. Software requirements

- R ≥ 4.2
- R packages: `dplyr`, `tidyr`, `readr`, `ggplot2`, `patchwork`, `scales`, `showtext`, `Cairo`
- Helvetica or Nimbus Sans font installed (the script falls back to Nimbus Sans if Helvetica is unavailable)

Quick install:
```r
install.packages(c("dplyr","tidyr","readr","ggplot2","patchwork",
                   "scales","showtext","Cairo"))
```

### 2. Data download

All data are public. Run from the repository root:

```bash
mkdir -p data
cd data

# TCMA decontaminated microbiome profiles (Dohlman et al. 2021, Cell Host Microbe)
curl -L -o README.txt    https://duke.tind.io/record/126/files/README.txt
curl -L -o metadata.zip  https://duke.tind.io/record/126/files/metadata.zip
curl -L -o WGS.zip       https://duke.tind.io/record/126/files/WGS.zip
curl -L -o WXS.zip       https://duke.tind.io/record/126/files/WXS.zip
unzip metadata.zip -d metadata/
unzip WGS.zip      -d WGS/
unzip WXS.zip      -d WXS/

# TCGA ABSOLUTE-derived purity (Aran et al. 2015)
curl -L -o TCGA_ABSOLUTE_purity.tsv \
  https://raw.githubusercontent.com/judithabk6/ITH_TCGA/master/external_data/TCGA_mastercalls.abs_tables_JSedit.fixed.txt

# MC3 non-silent gene mutation matrix (UCSC Xena mirror)
curl -L -o mc3.nonsilent.gene.matrix.gz \
  https://pancanatlas.xenahubs.net/download/mc3.v0.2.8.PUBLIC.nonsilentGene.xena.gz

cd ..
```

### 3. Run the analyses

```bash
Rscript code/01_PCE_circularity_simulation.R   # ~10s; produces panel A–C inputs
Rscript code/02_TMB_purity_reanalysis.R        # ~30s; produces panel D–F inputs
Rscript code/03_Figure1_final.R                # ~15s; renders Figure 1
```

Output: `results/Figure1_final/Figure1.pdf` (vector) + `Figure1.png` (600 dpi).

### 4. Expected key numbers

| Metric | Value |
|---|---|
| Cross-cancer real microbiota flagged at PCE > 0.7 | 100% (50/50) |
| True contaminants flagged at PCE > 0.7 | 100% (50/50) |
| Median PCE: contaminant vs cross-cancer real | 0.955 vs 0.957 |
| FDR among predicted contaminants at PCE > 0.7 | 66.7% |
| Pooled TCGA orodigestive raw r (TMB ~ microbial load) | 0.115 (n = 1,024, p = 2.2 × 10⁻⁴) |
| Same, after purity adjustment | 0.103 (p = 9.4 × 10⁻⁴) |
| Sites where direction *reverses* | ESCA (r = –0.063), HNSC (r = –0.080) |

---

## Citation

If you use this code or analysis, please cite both the preprint and the original Dohlman et al. paper:

```bibtex
@article{your_lastname_2026_pce_circularity,
  author  = {[Your Name] and colleagues},
  title   = {Pan-cancer equiprevalence cannot distinguish contaminants from cross-cancer microbiota},
  journal = {bioRxiv},
  year    = {2026},
  doi     = {[TBD]}
}

@article{dohlman_2026_microbiome,
  author  = {Dohlman, A.B. and Mjelle, R. and Wood, H.M. and others},
  title   = {Biodiversity and biogeography of the multi-kingdom cancer microbiome},
  journal = {Cell},
  volume  = {189},
  pages   = {1--21},
  year    = {2026},
  doi     = {10.1016/j.cell.2026.04.015}
}
```

A Zenodo archive of this repository is available at **DOI: [TBD]**.

---

## Data sources

| Dataset | Source | License |
|---|---|---|
| TCMA decontaminated microbiomes | Dohlman et al. 2021 (Duke Research Repository, [doi:10.7924/r4bk1j35s](https://doi.org/10.7924/r4bk1j35s)) | CC-BY 4.0 |
| TCGA ABSOLUTE purity | Aran, Sirota & Butte 2015 (*Nat. Commun.* 6:8971) | Public |
| MC3 v0.2.8 PUBLIC | Ellrott et al. 2018 (*Cell Syst.* 6:271) via [UCSC Xena](https://xenabrowser.net/) | Public |
| 100kGP microbiomes | Dohlman et al. 2026 — Genomics England controlled access (NOT redistributed here) | Restricted |

Note: 100kGP-derived microbiome profiles are not redistributable; analyses presented here use the *complementary* TCGA dataset for which equivalent processed data are public. The simulation panels (A–C) are self-contained and require no external data.

---

## Contact

[Your Name]
[Affiliation]
[Email]
[ORCID]

For questions about the underlying Dohlman et al. data, please contact the original authors.

---

## License

Code is released under the MIT License (see `LICENSE`). Manuscript text is released under CC-BY 4.0.
