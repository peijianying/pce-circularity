---
title: "Cover Letter — Matters Arising submission"
fontsize: 11pt
geometry: "left=2.5cm,right=2.5cm,top=2.5cm,bottom=2.5cm"
linestretch: 1.2
header-includes:
  - \pagestyle{empty}
---

\begin{flushleft}
\textbf{Jianying Pei, Ph.D.}\\
Clinical Laboratory Center\\
Gansu Provincial Maternity and Child-care Hospital\\
Lanzhou 730050, Gansu, China\\
Email: \href{mailto:861645823@qq.com}{861645823@qq.com}\\
ORCID: \href{https://orcid.org/0000-0003-0108-9230}{0000-0003-0108-9230}
\end{flushleft}

\vspace{1em}

\begin{flushleft}
[Submission date]
\end{flushleft}

\vspace{1em}

\begin{flushleft}
The Editors\\
\textit{Cell}\\
Cell Press\\
50 Hampshire Street, 5th Floor\\
Cambridge, MA 02139, USA
\end{flushleft}

\vspace{1.5em}

Dear Editors,

We are writing to submit our manuscript, **"Pan-cancer equiprevalence cannot distinguish contaminants from cross-cancer microbiota,"** for consideration as a *Matters Arising* on Dohlman et al., *Cell* 189, 1–21 (June 11, 2026; doi: 10.1016/j.cell.2026.04.015). The submission is well within the three-month *Matters Arising* window.

The Dohlman et al. study is an important contribution: PathSeq–T2T, with its complete telomere-to-telomere reference, is the most rigorous host-subtraction pipeline yet applied at pan-cancer scale, and the resulting orodigestive findings — multi-kingdom communities, anatomic biogeography, and the *Fusobacterium nucleatum*–MSI association — are biologically valuable. The headline conclusion of the paper, however, is the *negative* one: that "after decontamination, most cancer types lack microbiomes distinguishable from background." This claim, which directly contradicts several recent pan-cancer microbiome surveys, depends entirely on a single decontamination step — the Pan-Cancer Equiprevalence (PCE) score with a cutoff of 0.7 — and has immediate implications for how the field interprets prior work and designs future studies.

In this submission we make two points that we believe constrain the strength of the negative conclusion without undermining the positive findings.

**First, the PCE score is mathematically unable to discriminate a true reagent contaminant from a microbe genuinely shared across cancer types.** Both produce uniform cross-cancer prevalence by definition. We demonstrate this by constructing a controlled simulation (27 cancer types, n = 15,371; four ground-truth species classes) and applying the published PCE method without modification. At the cutoff of 0.7, **100% of genuinely cross-cancer microbiota are flagged as contaminants — identical to the 100% true-contaminant rate**, with median PCE values of 0.957 versus 0.955. The conclusion that "non-orodigestive cancers lack a microbiome" is therefore not falsifiable within the analytic framework as constructed.

**Second, the secondary finding that microbial load correlates with tumor mutation burden across orodigestive cancers does not generalize.** Using TCMA-decontaminated TCGA WXS microbiomes (n = 1,024) merged with ABSOLUTE-derived purity and MC3 mutation calls, we replicate the pooled trend in CRC and gastric cancer but find the direction *reverses* in esophageal and head-and-neck cancers. The remaining positive signal in CRC/gastric tumors is partly attributable to tumor purity, a shared denominator the original analysis did not include.

We are not proposing that the orodigestive findings of Dohlman et al. are wrong; we are proposing that the decontamination algorithm is logically circular and that the claim of pan-cancer absence is artifactual. Because PCE has been adopted in adjacent work, an early correction matters for the field.

We anticipate that this work will be of interest to *Cell* readers working on tumor microbiomes, low-biomass sequencing, and pan-cancer genomics. Suggested external referees are listed in the submission system; we respectfully request that the original authors and their immediate collaborators be excluded as reviewers, given the overlap with their other ongoing work.

A preprint has been deposited at bioRxiv concurrently with this submission, in keeping with *Cell*'s preprint policy. The work has not been submitted elsewhere. All authors have approved the submission and declare no competing interests. The full code, data-fetching scripts, and figures are publicly archived (Zenodo doi: 10.5281/zenodo.20621025).

Thank you for considering this *Matters Arising*. We would be glad to provide additional information or modifications as needed.

\vspace{1em}

Sincerely,

\vspace{2em}

**Jianying Pei, Ph.D.** (corresponding author)\
Clinical Laboratory Center, Gansu Provincial Maternity and Child-care Hospital, Lanzhou, China\
861645823@qq.com | ORCID: 0000-0003-0108-9230

\vspace{0.5em}

on behalf of:

**Yan Li** (first author)\
Department of Biochemistry and Molecular Biology, Medical College of Northwest Minzu University, Lanzhou, China\
290192798@xbmu.edu.cn
