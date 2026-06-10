# Matters Arising — Manuscript Draft v0.3

**Target journal:** *Cell* (Matters Arising)
**Word count target:** 1,200–1,500 (main text); ≤20 references; 1 figure
**Status:** Draft v0.3 (2026-06-10) — verified reference list, tightened figure callouts

Changes vs v0.2:
- Reference list replaced with PubMed-verified entries (full author lists, DOIs, accurate page numbers).
- In-text citations renumbered to match (no order changes, but `et al.` styling updated to *Cell* convention).
- Figure 1 callouts tightened to match the final composite figure (panels A-C simulation, D-F TCGA reanalysis).
- Two sentences sharpened for tone: removed hedging adverbs, replaced ambiguous "the authors" with specific references.
- Added a brief mechanistic clarification in the discussion of the shared-denominator effect.

---

## Title

**Pan-cancer equiprevalence cannot distinguish contaminants from cross-cancer microbiota**

---

## Authors (placeholder)

[Your Name]¹\*, [Co-authors]
¹[Affiliation]
\*Correspondence: [email]

---

## Main text

Dohlman et al.¹ apply an updated host-subtraction pipeline (PathSeq–T2T) to 16,369 tumor whole genomes from the UK 100,000 Genomes Project and conclude that, after decontamination, most non-orodigestive cancers lack a tumor-associated microbiome. Their decontamination step — a pan-cancer equiprevalence (PCE) score that flags species distributed evenly across cancer types — drives this conclusion. We show that PCE cannot, in principle, distinguish a true reagent contaminant from a microbe genuinely shared across cancer types, and that the secondary correlation between tumor mutation burden (TMB) and microbial load is heterogeneous across orodigestive sites and partly attributable to tumor purity. Together, these observations limit the inference that non-orodigestive tumors are microbiologically sterile, while leaving the orodigestive findings of Dohlman et al. unchallenged.

### PCE-based decontamination is mathematically circular

For a species detected at prevalence *pᵢ* in cancer type *i* (i = 1…*K*), Dohlman et al.¹ define

$$\text{PCE} = 1 - \frac{\text{sd}(p)}{\sqrt{K}\cdot \text{mean}(p)},$$

so that PCE = 0 when prevalence is concentrated in one cancer type and PCE = 1 when prevalence is uniform across all *K*. Species with PCE > 0.7 are removed as contaminants on the rationale that "contaminants will generally be present at similar rates across distinct sample types"¹. This rationale, originally introduced in Dohlman et al.²,³, is reasonable for reagent contaminants. Used as an exclusion filter, however, it is circular: a microbe genuinely shared across cancer types — one disseminating systemically, colonizing immune-permissive niches in distinct tumor sites, or transiting along contiguous mucosal surfaces — must by definition produce uniform cross-cancer prevalence and thus a high PCE score. The criterion that defines a contaminant is identical to the criterion that defines a cross-cancer microbe.

We tested this directly in a controlled simulation (Figure 1A–C). We constructed a synthetic 100kGP-like cohort (27 cancer types, n = 15,371) and seeded four ground-truth species categories at 50 species per category: true contaminants (uniform prevalence in every cancer), cancer-specific microbiota (high prevalence in one or two cancers, near-zero elsewhere), genuinely cross-cancer microbiota (broadly present, biologically variable prevalence), and Bernoulli noise. PCE was computed faithfully according to the *STAR* methods of Dohlman et al.¹ At the published threshold of 0.7, **50 of 50 cross-cancer real microbiota (100%) were flagged as contaminants, identical to the 50 of 50 true contaminants flagged (100%)**. Median PCE was 0.957 for cross-cancer real microbiota versus 0.955 for true contaminants — a difference of 0.002 that no threshold can exploit. Across the threshold range 0.3–0.99, the false-positive flagging of cross-cancer microbiota tracks the true-positive removal of contaminants almost identically (Figure 1C); the false-discovery rate among species classified as contaminants remains above 50% until PCE > 0.95, by which point real contaminants are also no longer caught.

The implication is that the conclusion "after decontamination, most cancer types lack a microbiome" is not falsifiable within the analytic framework as constructed. Any tumor microbiome shared across multiple cancer types — the principal alternative hypothesis to site-specific colonization — is preferentially removed by the decontamination step before that hypothesis can be tested. The observation in Dohlman et al.¹ that PCE recovers site-specific known taxa such as *Fusobacterium nucleatum* and HPV-16 confirms that the score preserves site-specific signal, which is what it is designed to do; it does not demonstrate that PCE removes only contaminants. A practical concern follows: of the 1,213 species removed at PCE > 0.7 across the 100kGP cohort, an unknown fraction may represent biologically real microbiota.

### TMB–microbial-load correlation is heterogeneous and partly purity-driven

Dohlman et al. (their Figure 5E–F) report a positive correlation between log(TMB) and log(microbial load, in reads per million; RPM) across orodigestive cancers, interpreted as a generalizable feature of tumor–microbiome biology. We re-examined this claim using TCMA²-decontaminated TCGA-WXS microbiome profiles, ABSOLUTE-derived tumor purity⁴, and MC3 mutation calls⁵ (n = 1,024 orodigestive samples; Figure 1D–F).

The pooled TCGA correlation reproduces the magnitude reported in 100kGP (raw r = 0.115, p = 2.2 × 10⁻⁴), but the direction is not consistent across sites. In colorectal (r = 0.131, p = 0.013) and gastric (r = 0.189, p = 0.005) cancers the trend matches the original report; in esophageal (r = –0.063) and head-and-neck (r = –0.080) cancers it reverses (Figure 1E). The pooled "orodigestive" correlation thus reflects a CRC- and gastric-driven phenomenon rather than a uniform property of the orodigestive axis: two of the five TCGA orodigestive sites show the opposite direction.

The remaining positive signal in CRC and gastric tumors is partly accounted for by tumor purity. Both quantities share a denominator: RPM normalizes microbial reads to total sequencing reads (host plus microbial), and TMB normalizes mutation counts to the analyzable genome. Because hypermutated tumors (MSI/POLE) display heavier immune infiltration⁴, their tumor purity is systematically lower, which can mechanically inflate microbial RPM independently of true microbial colonization. Adjusting for ABSOLUTE purity in a multivariable regression reduced the partial correlation from r = 0.115 to r = 0.103 (p_TMB = 9.4 × 10⁻⁴; p_purity = 3.3 × 10⁻⁵), and within the lowest three purity quintiles (n = 615; 60% of samples) the correlation was non-significant in every stratum (all p > 0.15); detectable signal was restricted to the upper purity quintiles (Figure 1F). Purity is therefore a contributor to, though not the sole driver of, the reported relationship.

### Implications and recommendations

The orodigestive findings of Dohlman et al.¹ — multi-kingdom communities, anatomic biogeography, and the *F. nucleatum*–MSI association — are biologically interpretable independently of the issues we raise; the tropism of oral and gut commensals for tumors at their barrier sites is concordant with prior work⁶⁻⁸. The conclusion that *non-*orodigestive tumors lack a microbiome is more fragile than the analysis suggests, because the decontamination step that produces it cannot, by construction, return any other answer for any cross-cancer microbe.

We therefore suggest three steps. First, decontamination should be anchored to biological controls — extraction blanks, no-template controls, and dilution-series experiments — analyzed with statistical tools such as `decontam`⁹ that model contaminant frequency as a function of input DNA concentration rather than assuming uniformity across cancers. Second, PCE may be retained as a *prioritization* score for follow-up but should not be used as an exclusion filter; species with high PCE that recur across orodigestive *and* non-orodigestive sites with consistent strain-level identity warrant orthogonal validation rather than removal. Third, quantitative associations between RPM-based microbial load and tumor genomic features should be reported with explicit adjustment for tumor purity and stratified by cancer site, to expose the heterogeneity that pooled analyses obscure.

The PathSeq–T2T pipeline of Dohlman et al.¹ is a real methodological advance, particularly its use of the complete human reference for host filtering. We hope these observations help refine downstream analyses and contribute to the standardization of decontamination strategies that the field still lacks¹⁰⁻¹².

---

## Figure 1 — Two methodological concerns regarding Dohlman et al. (Cell, 2026)

**(A)** Distribution of PCE scores by ground-truth category in a synthetic 100kGP-like cohort (27 cancer types, n = 15,371 samples; 50 species per category). Dashed line: PCE = 0.7 contaminant cutoff used by Dohlman et al.¹

**(B)** Per-cancer prevalence patterns of representative species, color-coded by ground-truth category. Cross-cancer real microbiota and true contaminants are visually and quantitatively indistinguishable.

**(C)** PCE threshold sensitivity. Across thresholds 0.3–0.99, the fraction of cross-cancer real microbiota lost to the filter (purple, dashed) tracks the fraction of true contaminants correctly removed (green) almost identically; the false-discovery rate among species classified as contaminants (red) stays above 50% until thresholds at which contaminants are also no longer caught.

**(D)** Raw correlation between log₁₀(TMB) and log₁₀(microbial load) in TCGA orodigestive cancers (TCMA-decontaminated WXS²; n = 1,024). r = 0.115, p = 2.2 × 10⁻⁴.

**(E)** Site-stratified Pearson r before (red, raw) and after (blue, purity-adjusted) regressing both variables on tumor purity. Direction reverses in ESCA and HNSC.

**(F)** Within-purity-quintile r in pooled orodigestive cancers; the TMB–microbe correlation is detectable only in the upper purity quintiles, indicating partial confounding by the shared host-DNA denominator.

---

## References

1. Dohlman, A.B., Mjelle, R., Wood, H.M., Jiang, K., Shumate, A., Lee, I., Piccinno, G., Serna, G., Yakubu, A.-R., Nuciforo, P., et al. (2026). Biodiversity and biogeography of the multi-kingdom cancer microbiome. Cell. *Online ahead of print*. https://doi.org/10.1016/j.cell.2026.04.015.

2. Dohlman, A.B., Arguijo Mendoza, D., Ding, S., Gao, M., Dressman, H., Iliev, I.D., Lipkin, S.M., and Shen, X. (2021). The cancer microbiome atlas: a pan-cancer comparative analysis to distinguish tissue-resident microbiota from contaminants. Cell Host Microbe *29*, 281–298.e5. https://doi.org/10.1016/j.chom.2020.12.001.

3. Dohlman, A.B., Klug, J., Mesko, M., Gao, I.H., Lipkin, S.M., Shen, X., and Iliev, I.D. (2022). A pan-cancer mycobiome analysis reveals fungal involvement in gastrointestinal and lung tumors. Cell *185*, 3807–3822.e12. https://doi.org/10.1016/j.cell.2022.09.015.

4. Aran, D., Sirota, M., and Butte, A.J. (2015). Systematic pan-cancer analysis of tumour purity. Nat. Commun. *6*, 8971. https://doi.org/10.1038/ncomms9971.

5. Ellrott, K., Bailey, M.H., Saksena, G., Covington, K.R., Kandoth, C., Stewart, C., Hess, J., Ma, S., Chiotti, K.E., McLellan, M., et al. (2018). Scalable open science approach for mutation calling of tumor exomes using multiple genomic pipelines. Cell Syst. *6*, 271–281.e7. https://doi.org/10.1016/j.cels.2018.03.002.

6. Castellarin, M., Warren, R.L., Freeman, J.D., Dreolini, L., Krzywinski, M., Strauss, J., Barnes, R., Watson, P., Allen-Vercoe, E., Moore, R.A., and Holt, R.A. (2012). *Fusobacterium nucleatum* infection is prevalent in human colorectal carcinoma. Genome Res. *22*, 299–306. https://doi.org/10.1101/gr.126516.111.

7. Kostic, A.D., Gevers, D., Pedamallu, C.S., Michaud, M., Duke, F., Earl, A.M., Ojesina, A.I., Jung, J., Bass, A.J., Tabernero, J., et al. (2012). Genomic analysis identifies association of *Fusobacterium* with colorectal carcinoma. Genome Res. *22*, 292–298. https://doi.org/10.1101/gr.126573.111.

8. Baker, J.L., Mark Welch, J.L., Kauffman, K.M., McLean, J.S., and He, X. (2024). The oral microbiome: diversity, biogeography and human health. Nat. Rev. Microbiol. *22*, 89–104. https://doi.org/10.1038/s41579-023-00963-6.

9. Davis, N.M., Proctor, D.M., Holmes, S.P., Relman, D.A., and Callahan, B.J. (2018). Simple statistical identification and removal of contaminant sequences in marker-gene and metagenomics data. Microbiome *6*, 226. https://doi.org/10.1186/s40168-018-0605-2.

10. Salter, S.J., Cox, M.J., Turek, E.M., Calus, S.T., Cookson, W.O., Moffatt, M.F., Turner, P., Parkhill, J., Loman, N.J., and Walker, A.W. (2014). Reagent and laboratory contamination can critically impact sequence-based microbiome analyses. BMC Biol. *12*, 87. https://doi.org/10.1186/s12915-014-0087-z.

11. Eisenhofer, R., Minich, J.J., Marotz, C., Cooper, A., Knight, R., and Weyrich, L.S. (2019). Contamination in low microbial biomass microbiome studies: issues and recommendations. Trends Microbiol. *27*, 105–117. https://doi.org/10.1016/j.tim.2018.11.003.

12. Gihawi, A., Ge, Y., Lu, J., Puiu, D., Xu, A., Cooper, C.S., Brewer, D.S., Pertea, M., and Salzberg, S.L. (2023). Major data analysis errors invalidate cancer microbiome findings. mBio *14*, e01607-23. https://doi.org/10.1128/mbio.01607-23.

---

## Author contributions (placeholder)

Conceptualization, [you]; formal analysis, [you]; visualization, [you]; writing — original draft, [you]; writing — review and editing, [you and co-authors]; supervision, [PI].

## Declaration of interests

The authors declare no competing interests.

## Data and code availability

All source data are public and listed in the *Methods* section. Code reproducing every figure panel and statistical claim in this manuscript is available at https://github.com/[your-username]/pce-circularity and archived on Zenodo (https://doi.org/10.5281/zenodo.[TBD]). Intermediate results (CSV tables, RDS objects) and the rendered Figure 1 (PDF + PNG) are bundled with the repository.

---

## Methods (brief — to be expanded if requested at revision)

**Simulation of PCE behavior.** A synthetic cohort matched to the per-cancer sample sizes of the 100kGP cohort (27 types, n = 15,371) was generated. Four ground-truth species classes were seeded at 50 species per class: true contaminants, drawn from Beta(8, 8) prevalence in every cancer; cancer-specific real microbiota, with prevalence drawn from U(0, 0.005) in all but 1–2 hot cancers, in which prevalence ~ U(0.3, 0.7); cross-cancer real microbiota, with prevalence Beta(5, 7) × 0.25 + 0.05 in every cancer; and Bernoulli null noise from Beta(1, 50). PCE was computed with the formula above, equivalent to (1 – CV/√K). All simulations are deterministic given `set.seed(20260609)`.

**Re-analysis of TMB and microbial load.** TCMA decontaminated WXS microbiome profiles² were merged with ABSOLUTE-derived tumor purity⁴ and per-sample non-silent mutation counts derived from the MC3 v0.2.8 PUBLIC MAF⁵ (UCSC Xena mirror), normalized by 38 Mb of analyzable exome. Tumor samples were restricted to TCGA orodigestive projects (COAD, READ, STAD, ESCA, HNSC; n = 1,024). Total microbial load per sample was computed as the sum of decontaminated species-level RPM. Pearson correlations between log₁₀(TMB) and log₁₀(microbial load) were calculated raw and after residualizing both variables on `purity` via OLS. Site-stratified correlations and within-purity-quintile correlations were computed without further covariates.

---

## End-of-draft notes (delete before submission)

- Word count: main text ≈ 1,290 (target 1,200–1,500). Slight increase vs v0.2 due to the mechanistic clarification and the brief Methods block.
- v0.3 changes: (i) PubMed-verified reference list (12 entries); (ii) Dohlman 2022 fungal Cell paper added as ref 3 to anchor the equiprevalence-thresholding lineage to a second source; (iii) Methods block added (Cell sometimes asks for one inline in Matters Arising); (iv) figure callouts updated to match the final composite figure.
- Anticipated reviewers: Dohlman, Meyerson, Segata, Huttenhower. The PCE point is mathematical and cannot be defeated by counter-data. The TMB point will draw a "cohort-specific" rebuttal — the response is that the original paper presents the trend as orodigestive-wide, and our TCGA replication contradicts that framing in 2/5 sites.
- Submission window: *Cell Matters Arising* requires submission within 3 months of original publication (June 11, 2026 → hard deadline ≈ September 11, 2026). bioRxiv preprint same day as submission.
- Once GitHub repo is public and Zenodo DOI is minted, replace `[your-username]` and `[TBD]` placeholders.
