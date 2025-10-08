# Project 2: Steppe formation model

## Modify names to match your dataset!

#### Load packages:
library(admixtools)
library(tidyverse)

#### Get f2_blocks. Only once for the entire project

target2 <- c("Russia_MLBA_Sintashta.AG", "Kazakhstan_Maitan_MLBA_Alakul.AG", "Russia_LBA_Srubnaya_Alakul.SG")
source2 <- c("Iran_GanjDareh_N.AG", "Russia_Sidelkino_HG.SG")
outgroup2 <- c("Mbuti.DG", "CHB.DG", "Papuan.DG", "Russia_UstIshim_IUP.DG", "Denisova.DG")


all_pops <- c(target2, source2, outgroup2)
prefix <- "v62.0_1240k_public"
outdir <- "aadr_1000G_f2_proyect2"

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

f3_results <- f3(f2_blocks, pop1="Mbuti.DG", pop2=target2, pop3=source2)


#### f4 tests: asymmetry checks. Are target populations closer to any of the potential sources?. Run one per each target population

f4_results <- f4(f2_blocks, pop1="", pop2="", pop3="", pop4="Mbuti.DG")


#### qpWave: test rank (how many ancestry streams are needed). Run one per each target population
wave2 <- qpwave(f2_blocks,
                left = c(target2[3], source2),
                right = outgroup2)


#### qpAdm: 2-way mixture models. Run one per each target populations
admix_2way <- qpadm(f2_blocks, left = c(target2[1], source2), right = outgroup2, target=target2[1])

