# Project 1: Do all present-day populations from Europe displau the same 3-way admixture?

## Modify names to match your dataset!

#### Load packages:
library(admixtools)
library(tidyverse)

#### Get f2_blocks. Only once for the entire project

target1 <- "GBR.DG"  # ADD more modern and ancient European targets
source1 <- c("Turkey_Marmara_Barcin_N.AG", "Russia_Samara_EBA_Yamnaya.AG", "Luxembourg_Mesolithic.DG")
outgroup1 <- c("Mbuti.DG", "CHB.DG", "Papuan.DG", "Russia_UstIshim_IUP.DG", "Denisova.DG")


all_pops <- c(target1, source1, outgroup1)
prefix <- "v62.0_1240k_public"
outdir <- "aadr_1000G_f2_proyect1"

extract_f2(pref = prefix,
           outdir = outdir,
           pops = all_pops,          # only populations to analyze
           overwrite = TRUE,
           blgsize = 0.05,            # block size in Morgans (default fine)
           verbose = TRUE)

#### Load f2_blocks
f2_blocks <- f2_from_precomp(outdir)

#### Outgroup-f3: shared drift between target and sources
#pop1=outgroup; pop2=target groups or populations; pop3=the ones to test shared drift with

f3_results <- f3(f2_blocks, pop1="Mbuti.DG", pop2=target1, pop3=source1)


#### f4 tests: asymmetry checks. Are target populations closer to any of the potential sources?

f4_results <- f4(f2_blocks, pop1="", pop2="", pop3="", pop4="Mbuti.DG")


#### qpWave: test rank (how many ancestry streams are needed)
wave1 <- qpwave(f2_blocks,
                left = c(target1, source1),
                right = outgroup1)


#### qpAdm: 2-way and 3-way mixture models
admix_2way <- qpadm(f2_blocks, left = c(target1, source1[1:2]), right = outgroup1, target=target1)
admix_3way <- qpadm(f2_blocks, left = c(target1, source1), right = outgroup1, target=target1)

