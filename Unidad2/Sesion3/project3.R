# Project 3: Peopling of the Americas

## Modify names to match your dataset!

#### Load packages:
library(admixtools)
library(tidyverse)

#### Get f2_blocks. Only once for the entire project

target3 <- c("Pima.DG","Karitiana.DG","Surui.DG","PEL.DG","Mixe.DG") #check for other ancient or present-day groups in the Americas.
source3 <- c("USA_Anzick_realigned.SG","USA_Ancient_Beringian.SG","USA_Nevada_SpiritCave_11000BP.SG")
outgroup3 <- c("Mbuti.DG", "CHB.DG", "Papuan.DG", "Russia_UstIshim_IUP.DG", "Denisova.DG")


all_pops <- c(target3, source3, outgroup3, "India_GreatAndaman_100BP.SG")
prefix <- "v62.0_1240k_public"
outdir <- "aadr_1000G_f2_proyect3"

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

f3_results <- f3(f2_blocks, pop1="Mbuti.DG", pop2=target3, pop3=source3)


#### f4 tests: asymmetry checks. Are target populations closer to any of the potential sources?. Run one per each target population

f4_results <- f4(f2_blocks, pop1="", pop2="", pop3="", pop4="Mbuti.DG")


#### qpWave: test rank (how many ancestry streams are needed). Run one per each target population
wave2 <- qpwave(f2_blocks,
                left = c(target3[1], source3),
                right = outgroup3)

wave2 <- qpwave(f2_blocks,
                left = c(target3[2],"USA_Ancient_Beringian.SG","India_GreatAndaman_100BP.SG"),
                right = outgroup3)

#### qpAdm: 2 or 3-way mixture models. Run one per each target populations
admix_2way <- qpadm(f2_blocks, left = c(target3[1], source3[1:2]), right = outgroup3, target=target3[1])

