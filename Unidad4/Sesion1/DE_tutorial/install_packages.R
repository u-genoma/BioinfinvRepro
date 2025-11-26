if (!require("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

BiocManager::install("preprocessCore")
BiocManager::install("maanova")
BiocManager::install("limma")
BiocManager::install("topGO")
BiocManager::install("org.Mm.eg.db")


