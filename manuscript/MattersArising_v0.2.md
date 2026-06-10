# Matters Arising — Manuscript Draft v0.2

**Target journal:** *Cell* (Matters Arising)
**Word count target:** 1,200–1,500 (main text); ≤20 references; 1 figure
**Status:** Draft v0.2 (2026-06-10) — Cell-style polish over v0.1

---

## Title

**Pan-cancer equiprevalence cannot distinguish contaminants from cross-cancer microbiota**

*(Working alternative: "Circular logic in equiprevalence-based decontamination of tumor microbiomes")*

---

## Authors (placeholder)

[Your Name]¹\*, [Co-authors]
¹[Affiliation]
\*Correspondence: [email]

---

## Main text

Dohlman et al.¹ apply an updated host-subtraction pipeline (PathSeq–T2T) to 16,369 tumor whole genomes from the UK 100,000 Genomes Project and conclude that, after decontamination, most non-orodigestive cancers lack a tumor-associated microbiome. Their decontamination step — a pan-cancer equiprevalence (PCE) score that flags species distributed evenly across cancer types — drives this conclusion. We show that PCE cannot, in principle, distinguish a true reagent contaminant from a microbe genuinely shared across cancer types, and that the secondary correlation between tumor mutation burden (TMB) and microbial load is heterogeneous across orodigestive sites and partly attributable to tumor purity. Together, these observations limit the inference that non-orodigestive tumors are microbiologically sterile.

### PCE-based decontamination is mathematically circular

For a species detected at prevalence *p_i* in cancer type *i* (i = 1…*K*), Dohlman et al. compute

$$\text{PCE} = 1 - \frac{\text{sd}(p)}{\sqrt{K}\cdot \text{mean}(p)},$$

so that PCE = 0 when prevalence is concentrated in one cancer type and PCE = 1 when prevalence is uniform across all *K*. Species with PCE > 0.7 are removed as contaminants on the rationale that "contaminants will generally be present at similar rates across distinct sample types." The premise is reasonable for reagent contaminants. Used as an exclusion filter, however, the rule is circular: a microbe genuinely shared across cancer types — one disseminating systemically, colonizing immune-permissive niches in distinct tumor sites, or transiting along contiguous mucosal surfaces — must by definition produce uniform cross-cancer prevalence and thus a high PCE score. The criterion that defines a contaminant is identical to the criterion that defines a cross-cancer microbe.

We tested this directly in a controlled simulation (Figure 1A–C). We constructed a synthetic 100kGP-like cohort (27 cancer types, n = 15,371) and seeded four ground-truth species categories at 50 species per category: true contaminants (uniform prevalence in every cancer), cancer-specific microbiota (high prevalence in one or two cancers, near-zero elsewhere), genuinely cross-cancer microbiota (broadly present, biologically variable prevalence), and Bernoulli noise. PCE was computed faithfully according to the *STAR* methods. At the published threshold of 0.7, **50 of 50 cross-cancer real microbiota (100%) were flagged as contaminants, identical to the 50 of 50 true contaminants flagged (100%)**. Median PCE was 0.957 for cross-cancer real microbiota versus 0.955 for true contaminants — a difference of 0.002 that no threshold can exploit. Across the threshold range 0.3–0.99, the false-positive flagging of cross-cancer microbiota tracks the true-positive removal of contaminants almost identically (Figure 1C); the false-discovery rate among "predicted contaminants" remains above 50% until PCE > 0.95, by which point real contaminants are also no longer caught.

The implication is that the conclusion "after decontamination, most cancer types lack a microbiome" is not falsifiable within the analytic framework as constructed. Any tumor microbiome shared across multiple cancer types — the principal alternative hypothesis to site-specific colonization — is preferentially removed by the decontamination step before that hypothesis can be tested. The authors' validation that PCE recovers site-specific known taxa (*F. nucleatum*, HPV-16) confirms that the score preserves site-specific signal, which is what it is designed to do; it does not demonstrate that PCE removes only contaminants. A practical concern follows: of the species removed at PCE > 0.7 across the 100kGP cohort, an unknown fraction may represent biologically real microbiota.

### TMB–microbial-load correlation is heterogeneous and partly purity-driven

Dohlman et al. (Fig. 5E–F) report a positive correlation between log(TMB) and log(microbial load, in reads per million; RPM) across orodigestive cancers, interpreted as a generalizable feature of tumor–microbiome biology. We re-examined this claim using TCMA-decontaminated TCGA-WXS microbiome profiles², ABSOLUTE-derived tumor purity³, and MC3 mutation calls⁴ (n = 1,024 orodigestive samples; Figure 1D–F).

The pooled TCGA correlation reproduces the magnitude reported in 100kGP (raw r = 0.115, p = 2.2 × 10⁻⁴), but the direction is not consistent across sites. In colorectal (r = 0.131, p = 0.013) and gastric (r = 0.189, p = 0.005) cancers the trend matches the original report; in esophageal (r = –0.063) and head-and-neck (r = –0.080) cancers it reverses. The pooled "orodigestive" correlation thus reflects a CRC- and gastric-driven phenomenon rather than a uniform property of the orodigestive axis. Two of the five TCGA orodigestive sites show the opposite direction.

The remaining positive signal in CRC and gastric tumors is partly accounted for by tumor purity. Both quantities share a denominator: RPM normalizes microbial reads to total sequencing reads (mostly host), and TMB normalizes mutation counts to analyzable genome — both quantities increase as tumor purity decreases through immune infiltration, a hallmark of hypermutated subtypes. Adjusting for ABSOLUTE purity in a multivariable regression reduced the partial correlation from r = 0.115 to r = 0.103 (p_TMB = 9.4 × 10⁻⁴; p_purity = 3.3 × 10⁻⁵), and within the lowest three purity quintiles (n = 615, 60% of samples) the correlation was non-significant in every stratum (all p > 0.15); detectable signal was restricted to the upper purity quintiles (Figure 1F). Purity is therefore a contributor to, though not the sole driver of, the reported relationship.

### Implications and recommendations

The orodigestive findings of Dohlman et al. — multi-kingdom communities, anatomic biogeography, and the *F. nucleatum*–MSI association — are biologically interpretable independently of the issues we raise; the tropism of oral and gut commensals for tumors at their barrier sites is concordant with prior work⁵⁻⁷. The conclusion that *non-*orodigestive tumors lack a microbiome is more fragile than the analysis suggests, because the decontamination step that produces it cannot, by construction, return any other answer for any cross-cancer microbe. We therefore suggest three steps. First, decontamination should be anchored to biological controls — extraction blanks, no-template controls, and dilution-series experiments — analyzed with statistical tools such as `decontam`⁸ that model contaminant frequency as a function of input DNA concentration rather than assuming uniformity across cancers. Second, PCE may be retained as a *prioritization* score for follow-up but should not be used as an exclusion filter; species with high PCE that recur across orodigestive *and* non-orodigestive sites with consistent strain-level identity warrant orthogonal validation rather than removal. Third, quantitative associations between RPM-based microbial load and tumor genomic features should be reported with explicit adjustment for tumor purity and stratified by cancer site, to expose the heterogeneity that is invisible in pooled analyses.

The PathSeq–T2T pipeline is a real methodological advance, particularly its use of the complete human reference for host filtering. We hope these observations help refine downstream analyses and contribute to the standardization of decontamination strategies that the field still lacks⁹⁻¹¹.

---

## Figure 1 — Two methodological concerns regarding Dohlman et al. (2026)

**(A)** Distribution of PCE scores by ground-truth category in a synthetic 100kGP-like cohort (27 cancer types, n = 15,371; 50 species per category). Dashed line: PCE = 0.7 contaminant cutoff used by Dohlman et al.

**(B)** Per-cancer prevalence patterns of representative species. Cross-cancer real microbiota and true contaminants are visually and quantitatively indistinguishable.

**(C)** PCE threshold sensitivity. Across thresholds 0.3–0.99 the false-positive flagging of cross-cancer real microbiota (purple) tracks the true-positive removal of contaminants (green); FDR among species classified as contaminants (red) remains > 50% until thresholds at which contaminants are also no longer caught.

**(D)** Raw correlation between log10(TMB) and log10(microbial load) in TCGA orodigestive cancers (TCMA-decontaminated WXS, n = 1,024). r = 0.115, p = 2.2 × 10⁻⁴.

**(E)** Site-stratified Pearson r before (red) and after (green) regressing both variables on tumor purity. Direction reverses in ESCA and HNSC.

**(F)** Within-purity-quintile r in pooled orodigestive cancers; the TMB–microbe correlation is detectable only in the upper purity quintiles.

---

## References (placeholder, to be finalized)

1. Dohlman, A.B., Mjelle, R., Wood, H.M., et al. (2026). Biodiversity and biogeography of the multi-kingdom cancer microbiome. *Cell* 189, 1–21.
2. Dohlman, A.B., Arguijo Mendoza, D., Ding, S., et al. (2021). The cancer microbiome atlas. *Cell Host Microbe* 29, 281–298.
3. Aran, D., Sirota, M., and Butte, A.J. (2015). Systematic pan-cancer analysis of tumour purity. *Nat. Commun.* 6, 8971.
4. Ellrott, K., Bailey, M.H., Saksena, G., et al. (2018). Scalable open science approach for mutation calling of tumor exomes. *Cell Syst.* 6, 271–281.
5. Castellarin, M., Warren, R.L., Freeman, J.D., et al. (2012). *Fusobacterium nucleatum* infection is prevalent in human colorectal carcinoma. *Genome Res.* 22, 299–306.
6. Kostic, A.D., Gevers, D., Pedamallu, C.S., et al. (2012). Genomic analysis identifies association of *Fusobacterium* with colorectal carcinoma. *Genome Res.* 22, 292–298.
7. Baker, J.L., Mark Welch, J.L., Kauffman, K.M., et al. (2024). The oral microbiome: diversity, biogeography and human health. *Nat. Rev. Microbiol.* 22, 89–104.
8. Davis, N.M., Proctor, D.M., Holmes, S.P., et al. (2018). Simple statistical identification and removal of contaminant sequences in marker-gene and metagenomics data. *Microbiome* 6, 226.
9. Salter, S.J., Cox, M.J., Turek, E.M., et al. (2014). Reagent and laboratory contamination can critically impact sequence-based microbiome analyses. *BMC Biol.* 12, 87.
10. Eisenhofer, R., Minich, J.J., Marotz, C., et al. (2019). Contamination in low microbial biomass microbiome studies. *Trends Microbiol.* 27, 105–117.
11. Gihawi, A., Ge, Y., Lu, J., et al. (2023). Major data analysis errors invalidate cancer microbiome findings. *mBio* 14, e01607-23.

---

## Author contributions (placeholder)

Conceptualization, [you]; data analysis, [you]; writing, [you]; supervision, [you].

## Declaration of interests

The authors declare no competing interests.

## Data and code availability

All source data are public. Code reproducing all analyses is available at [GitHub repo, to be created] and archived on Zenodo with DOI [to be assigned].

---

## End-of-draft notes (delete before submission)

- Word count: main text ≈ 1,265 (target 1,200–1,500). Comfortable buffer for one mechanistic paragraph if requested at revision.
- Three structural changes vs v0.1: (i) title shortened; (ii) standalone Summary block dropped — opening paragraph absorbs that role; (iii) TMB section now leads with site-level *direction reversal* (the strongest empirical finding) and treats purity as a contributing rather than primary explanation.
- One inline equation added to make the circularity argument explicit and harder to dispute.
- Anticipated reviewers: Dohlman, Meyerson, Segata, Huttenhower. The PCE point is mathematical, not empirical, and cannot be defeated by counter-data. The TMB point will draw a "cohort-specific" rebuttal — the response is that the original paper presents the trend as orodigestive-wide, and our TCGA replication contradicts that framing in 2/5 sites.
- Submission window: *Cell Matters Arising* requires submission within 3 months of original publication (June 11, 2026 → hard deadline ≈ September 11, 2026). Recommend bioRxiv preprint same day as submission.
