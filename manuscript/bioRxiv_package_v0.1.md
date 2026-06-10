# bioRxiv Preprint Submission Package

**Companion file to:** Matters Arising submission to *Cell* (Dohlman et al., 2026)
**Recommended deposit:** Same day as *Cell* submission
**Status:** v0.1 (2026-06-10)

---

## Title (preprint)

**Pan-cancer equiprevalence cannot distinguish contaminants from cross-cancer microbiota: a comment on Dohlman et al. (Cell, 2026)**

*(Same as the Matters Arising title with a "comment on…" subtitle. The subtitle is preprint-only — bioRxiv readers benefit from knowing the target of the comment up front; the published version drops it for journal style.)*

---

## Authors

Yan Li¹, Jianying Pei²,\*

¹Department of Biochemistry and Molecular Biology, Medical College of Northwest Minzu University, Lanzhou, China
²Clinical Laboratory Center, Gansu Provincial Maternity and Child-care Hospital, Lanzhou, China

\*Correspondence: peijianying1989@163.com

ORCID: 0000-0003-0108-9230 (J.P.)

---

## Abstract (≈220 words)

Dohlman et al. (Cell, 2026) profiled the microbiomes of 16,369 tumor whole genomes from the UK 100,000 Genomes Project using their PathSeq–T2T pipeline and concluded that, after decontamination, most non-orodigestive cancers harbor no microbiome distinguishable from background. Here we identify two methodological concerns that limit this negative inference.

First, the pan-cancer equiprevalence (PCE) score used to flag contaminants is logically circular: a microbe genuinely shared across cancer types is mathematically indistinguishable from a true reagent contaminant, because both produce uniform cross-cancer prevalence. In a controlled simulation (27 cancer types, n = 15,371; four ground-truth species categories), we recover the published PCE behavior and find that 100% of genuinely cross-cancer microbiota are flagged as contaminants at the published threshold of 0.7 — identical to the 100% true-contaminant flag rate, with median PCE values of 0.957 versus 0.955. The conclusion that "non-orodigestive cancers lack a microbiome" therefore cannot be tested within the analytic framework as constructed.

Second, the reported correlation between tumor mutation burden (TMB) and microbial load does not generalize across orodigestive sites. Re-analysis of TCMA-decontaminated TCGA microbiomes (n = 1,024) with ABSOLUTE-derived purity reveals that the direction of the correlation reverses in esophageal and head-and-neck cancers, and the remaining positive signal in colorectal and gastric tumors is partly attributable to tumor purity — a shared denominator the original analysis did not include.

The orodigestive findings of Dohlman et al. — multi-kingdom communities, anatomic biogeography, and the *Fusobacterium nucleatum*–MSI association — are robust to these concerns. The pan-cancer absence claim is not.

---

## One-sentence summary (for bioRxiv "Summary" field / social media)

The pan-cancer-equiprevalence-based decontamination used by Dohlman et al. (Cell, 2026) cannot, by construction, distinguish a true contaminant from a microbe genuinely shared across cancer types — making the conclusion that "most cancers lack a microbiome" unfalsifiable within their analytic framework.

---

## bioRxiv submission metadata

| Field | Value |
|---|---|
| **Subject area (primary)** | Bioinformatics |
| **Subject area (secondary)** | Cancer Biology |
| **Subject area (tertiary)** | Microbiology |
| **Article type** | New Results — Comment |
| **License** | CC-BY 4.0 (recommended for maximum reuse) |
| **Linked paper** | Dohlman et al. *Cell* 189, 1–21 (2026); doi:10.1016/j.cell.2026.04.015 |
| **Companion submission** | *Cell* Matters Arising, submitted [date] |

### Keywords (5–8)

tumor microbiome; decontamination; equiprevalence; PathSeq; tumor mutation burden; tumor purity; pan-cancer; methods critique

---

## Suggested Twitter / X thread (optional, post on day of preprint)

🧬 1/ New preprint commenting on Dohlman et al. (Cell 2026), the recent pan-cancer tumor-microbiome atlas reporting that "most cancers lack a microbiome." We argue this conclusion is partly an artifact of how their decontamination algorithm is defined.
[bioRxiv link]

🧬 2/ Their decontamination uses a "pan-cancer equiprevalence" (PCE) score: species evenly distributed across cancer types are flagged as contaminants and removed. Reasonable for reagent contamination — but it has a circular failure mode.

🧬 3/ A microbe *genuinely shared* across cancers (e.g., systemic, blood-borne, or immune-permissive across multiple tumor types) ALSO produces uniform prevalence. PCE cannot distinguish the two — they're the same signal.

🧬 4/ We simulated 200 species across 27 cancer types in 4 ground-truth classes. At the published cutoff of 0.7, **100% of true cross-cancer microbiota were flagged as contaminants**, identical to the 100% true-contaminant rate. Median PCE: 0.957 vs 0.955.

🧬 5/ Implication: any tumor microbiome systemically shared across cancer types is preferentially removed *before* it can be tested. The conclusion "most cancers lack a microbiome" is not falsifiable within this framework.

🧬 6/ We also reanalyzed the TMB–microbe correlation on TCGA. The direction reverses in esophageal and head-and-neck cancers, and the remaining positive signal in CRC/gastric is partly tumor-purity-driven (RPM and TMB share a host-DNA denominator).

🧬 7/ The orodigestive findings (multi-kingdom communities, F. nucleatum–MSI) are independent of these concerns and remain interesting. The pan-cancer absence claim is the part we think needs revisiting.

🧬 8/ Code and data: https://github.com/peijianying/pce-circularity (Zenodo DOI: 10.5281/zenodo.20622530). Companion *Cell* Matters Arising submitted today. Comments welcome.

---

## bioRxiv submission checklist

- [ ] Convert v0.2 Matters Arising MS to a single PDF (full text + Figure 1 + references)
- [ ] Replace placeholder author block with finalized authors
- [ ] Confirm GitHub repository public and Zenodo DOI minted before submission
- [ ] Verify all 11 references have valid DOIs
- [ ] Use the *same submission day* as the *Cell* Matters Arising — establishes priority
- [ ] After acceptance at Cell (if successful): update preprint with link to published version
- [ ] Tag the preprint as "Comment" on the bioRxiv interface so it's findable as a critique

---

## Rationale for preprinting (for your reference)

1. **Establishes priority.** Cell Matters Arising can take 6–12 months to appear; bioRxiv is timestamped within hours.
2. **Community visibility.** Microbiome methods folks — exactly the readers who will form the next consensus on decontamination — read bioRxiv daily.
3. **Pressure on review timeline.** Once a preprint is live, the field starts citing it. Editors at Cell are less likely to sit on a Matters Arising once the underlying work is publicly available.
4. **Insurance against desk-rejection.** If Cell declines, the preprint already exists with its own DOI; resubmission to *Genome Biology* / *Microbiome* / *Briefings in Bioinformatics* loses no time.
5. **Cell preprint policy.** As of 2024, Cell explicitly permits and encourages preprints simultaneously with submission.
