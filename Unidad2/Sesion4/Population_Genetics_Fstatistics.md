# Population Genetics Tutorial

Author: Constanza de la Fuente, School of Medicine, University of Chile

Year: 2026



This practical introduces several population-genetic analyses using **ADMIXTOOLS2** in R, including:

- f-statistics
- admixture f3-statistics
- outgroup f3-statistics
- f4-statistics / D-statistics
- qpWave
- qpAdm

The examples use data from the **1240K public dataset** in EIGENSTRAT format.

---

## 1. Installing the required packages

Install `devtools` if it is not already installed:

```r
install.packages("devtools")
devtools::install_github("uqrmaie1/admixtools")
```

If the installation does not work, try installing the dependencies manually:

```r
install.packages("Rcpp")
install.packages("tidyverse")
install.packages("igraph")
install.packages("plotly")
```

Then try installing `admixtools` again:

```r
devtools::install_github("uqrmaie1/admixtools")
```

Alternatively, you can use `remotes`:

```r
install.packages("remotes")
remotes::install_github("uqrmaie1/admixtools")
```

### Load the required packages

```r
library(admixtools)
library(tidyverse)
library(ggplot2)
library(dplyr)
```

---

## 2. Set the working directory and load metadata

Set the working directory to the location containing your data:

```r
setwd("~/Dropbox/2025/DOCENCIA/POSTGRADO/Practico_popgen_advance/popgen_shared/")
```

Load the metadata:

```r
metadf <- read.table(
  "v62.0_1240k_public_metadata2.csv",
  header = TRUE,
  sep = ","
)
```

---

# 3. Generate f2 blocks

The first step is to calculate **f2 statistics**, which are used as the basis for many downstream analyses in ADMIXTOOLS2.

You can calculate f2 statistics using:

- **transversions only**, which can be useful for ancient DNA analyses because transitions are more strongly affected by post-mortem DNA damage; or
- **all sites**.

### Define the genotype data

The genotype data should be in EIGENSTRAT format. Provide the path to the genotype files **without the file extensions**:

```r
prefix <- "/popgen_shared/v62.0_1240k_public"
```

Define the directory where the f2 results will be stored:

```r
outdir_all <- "aadr_1000G_f2_all"
```

### Select populations

For example:

```r
demo_pops <- c(
  "Altai_Neanderthal.DG",
  "Denisova.DG",
  "Russia_UstIshim_IUP.DG",
  "Luxembourg_Mesolithic.DG",
  "Turkey_Marmara_Barcin_N.AG",
  "Russia_Samara_EBA_Yamnaya.AG",
  "England_C_EBA.AG",
  "Germany_CordedWare.AG",
  "Mbuti.DG",
  "Papuan.DG",
  "CHB.DG",
  "Adygei.DG",
  "Basque.DG",
  "Druze.DG",
  "French.DG",
  "Italian_North.DG",
  "Italian_Sardinian.DG",
  "Orcadian.DG",
  "Russian.DG",
  "Sardinian.DG",
  "FIN.DG",
  "GBR.DG",
  "IBS.DG",
  "TSI.DG",
  "Chimp.REF",
  "MXL.DG",
  "Karitiana.DG",
  "PEL.DG",
  "Mixe.DG"
)
```

### Extract f2 statistics using transversions only

```r
extract_f2(
  pref = prefix,
  outdir = outdir,
  pops = demo_pops,
  transitions = FALSE,
  transversions = TRUE,
  overwrite = TRUE,
  blgsize = 0.05,
  verbose = TRUE
)
```

### Extract f2 statistics using all sites

```r
extract_f2(
  pref = prefix,
  outdir = outdir_all,
  pops = demo_pops,
  overwrite = TRUE,
  blgsize = 0.05,
  verbose = TRUE
)
```

Load the precomputed f2 blocks:

```r
f2_blocks_all <- f2_from_precomp(outdir_all)
```

---

# 4. Admixture f3-statistic

The **admixture f3-statistic** can be used to test whether a target population shows evidence of admixture.

The basic form is:

```text
f3(Target; Source1, Source2)
```

A significantly negative f3-statistic provides evidence that the target population has ancestry related to both source populations.

For example:

```text
f3(MXL; IBS, Karitiana)
```

can be used to test whether Mexican-American population MXL shows evidence of mixed European and Indigenous American ancestry.

### Define populations

```r
popA <- c("MXL.DG", "PEL.DG", "Mixe.DG")
popB <- "IBS.DG"
popC <- "Karitiana.DG"
```

Run the f3-statistic:

```r
f3res <- f3(
  f2_blocks_all,
  popA,
  popB,
  popC
)
```

---

# 5. Outgroup f3-statistic

The **outgroup f3-statistic** measures the amount of shared genetic drift between two populations after divergence from an outgroup.

The basic form is:

```text
f3(Outgroup; Population1, Population2)
```

Here we use **Mbuti** as the outgroup and **Luxembourg_Mesolithic** as the reference population.

We can then compare its shared drift with several present-day European populations.

### Define populations

```r
popA <- "Luxembourg_Mesolithic.DG"

popB <- c(
  "Adygei.DG",
  "Basque.DG",
  "Druze.DG",
  "French.DG",
  "Italian_North.DG",
  "Italian_Sardinian.DG",
  "Orcadian.DG",
  "Russian.DG",
  "Sardinian.DG",
  "FIN.DG",
  "GBR.DG",
  "IBS.DG",
  "TSI.DG"
)

outg <- "Mbuti.DG"
```

Run the outgroup f3-statistic:

```r
f3res <- f3(
  f2_blocks_all,
  outg,
  popA,
  popB
)
```

### Add geographic information

The metadata can be used to identify the region of each target population:

```r
f3res$pop3_region <- metadf$region[
  match(f3res$pop3, metadf$popid)
]
```

### Plot the results

```r
ggplot(
  f3res,
  aes(
    x = reorder(pop3, est),
    y = est,
    color = pop3_region
  )
) +
  geom_point(size = 3) +
  geom_errorbar(
    aes(
      ymin = est - se * 3,
      ymax = est + se * 3
    ),
    width = 0.2
  ) +
  scale_color_manual(
    values = c(
      "orange2",
      "steelblue1",
      "cyan4",
      "yellow2",
      "pink3"
    )
  ) +
  coord_flip() +
  labs(
    x = "Target population",
    y = expression(f[3]),
    color = "Region"
  ) +
  theme_bw() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "right"
  )
```

---

# 6. f4-statistic / D-statistic

The **f4-statistic** can be used to test whether two populations are symmetrically related to a third population.

The general form is:

```text
f4(Pop1, Pop2; Pop3, Pop4)
```

When used as a D-statistic, this is commonly referred to as an **ABBA-BABA test**.

A simplified interpretation is:

- **D ≈ 0**: Pop1 and Pop2 have symmetrical relationships with Pop3.
- **D > 0**: Pop1 shares more alleles with Pop3 than Pop2 does.
- **D < 0**: Pop2 shares more alleles with Pop3 than Pop1 does.

For example:

```r
qpdstat(
  f2_blocks_all,
  pop1 = "GBR.DG",
  pop2 = "TSI.DG",
  pop3 = "Mbuti.DG",
  pop4 = "Chimp.REF"
)
```

You can also test multiple populations simultaneously:

```r
f4res <- qpdstat(
  f2_blocks_all,
  pop1 = "GBR.DG",
  pop2 = c(
    "TSI.DG",
    "CHB.DG",
    "Mbuti.DG",
    "Papuan.DG"
  ),
  pop3 = "Altai_Neanderthal.DG",
  pop4 = "Chimp.REF"
)
```

### Example: Neanderthal and Denisovan affinity

Papuans are known to have substantial Denisovan-related ancestry in addition to Neanderthal-related ancestry. We can compare the relative affinity of a Papuan population with Neanderthal and Denisovan genomes:

```r
qpdstat(
  f2_blocks_all,
  pop1 = "Altai_Neanderthal.DG",
  pop2 = "Denisova.DG",
  pop3 = "Papuan.DG",
  pop4 = "GBR.DG"
)
```

---

# 7. qpWave

**qpWave** tests whether a set of populations can be explained as deriving from a given number of independent ancestry streams relative to a set of Right populations.

The **Left populations** are the populations being tested, while the **Right populations** act as references or outgroups.

The key question is:

> How many independent ancestry streams are needed to explain the allele-frequency relationships among the Left populations relative to the Right populations?

### Define the target and Right populations

```r
target <- "England_C_EBA.AG"

right_qpwave <- c(
  "Mbuti.DG",
  "Papuan.DG",
  "CHB.DG",
  "Denisova.DG",
  "Russia_UstIshim_IUP.DG"
)
```

Run qpWave:

```r
wave <- qpwave(
  f2_blocks_all,
  left = c(
    target,
    "Turkey_Marmara_Barcin_N.AG",
    "Luxembourg_Mesolithic.DG",
    "Russia_Samara_EBA_Yamnaya.AG"
  ),
  right = right_qpwave
)

wave
```

### Interpreting qpWave

qpWave tests different numbers of ancestry streams.

The null hypothesis is:

> The Left populations can be explained by ≤ *k* ancestry streams relative to the Right populations.

The alternative hypothesis is:

> The Left populations require more than *k* ancestry streams relative to the Right populations.

The p-value can be interpreted as:

- **p > 0.05**: fail to reject the null hypothesis; the tested number of ancestry streams is sufficient.
- **p < 0.05**: reject the null hypothesis; the tested number of ancestry streams is not sufficient.

The relationship between rank and ancestry streams is:

| Rank | Number of ancestry streams |
| ----:| --------------------------:|
| 0    | 1                          |
| 1    | 2                          |
| 2    | 3                          |
| 3    | 4                          |

For example:

- **Rank 0**: all Left populations can be described as sharing one ancestry stream relative to the Right populations.
- **Rank 1**: two ancestry streams are required.
- **Rank 2**: three ancestry streams are required.

Importantly, the number of ancestry streams does **not** directly translate into a specific number of historical admixture events without additional demographic assumptions.

---

# 8. qpAdm

**qpAdm** can be used to model a target population as a mixture of a specified set of source populations.

For example, we can test whether `England_C_EBA.AG` can be modeled using:

- `Turkey_Marmara_Barcin_N.AG`
- `Luxembourg_Mesolithic.DG`
- `Russia_Samara_EBA_Yamnaya.AG`

with the Right populations defined above.

```r
adm <- qpadm(
  f2_blocks_all,
  left = c(
    target,
    "Turkey_Marmara_Barcin_N.AG",
    "Luxembourg_Mesolithic.DG",
    "Russia_Samara_EBA_Yamnaya.AG"
  ),
  right = right_qpwave,
  target = target
)
```

### View ancestry proportions

```r
view(adm$weights)
```

### View population-model results

```r
view(adm$popdrop)
```

The `weights` output contains the estimated ancestry proportions for the sources included in the model.

The `popdrop` output contains information about the tested models and their statistical fit.

---

## 9. Repeat the qpAdm analysis

As an exercise, repeat the qpAdm analysis using:

```text
Germany_CordedWare.AG
```

as the target population instead of:

```text
England_C_EBA.AG
```

You can modify:

```r
target <- "Germany_CordedWare.AG"
```

and rerun the qpAdm analysis.
