## =============================================================================
## preparacion/01_preparar_datos.R
## SOLO DOCENTE — no se ejecuta en clase.
## Extrae, reduce y ANONIMIZA los datos de la cohorte PRADA (ICR) para la práctica.
##   Entradas privadas (no se distribuyen):
##     - nextNEOpi (Mutect2 + Strelka/VarScan, alta confianza, tumor vs normal germinal) + VEP
##       copiado desde alma: .../graichand/nextNEOpi/results_PRADA/analyses/<muestra>/
##     - recuentos forzados (samtools mpileup, Q20/q20) en las posiciones SNV de D ∪ M
##     - contexto trinucleotídico (samtools faidx sobre GRCh38)
##     - RSEM TPM, TCRβ (Decombinator/AIRR), metadatos clínicos
##   Salidas: ../data/  (IDs PAC01–PAC08; sin IDs de laboratorio, rutas, edad ni supervivencia)
## =============================================================================
suppressPackageStartupMessages(library(data.table))

PRADA <- "/Users/lzapata/Library/CloudStorage/Dropbox-ICR/Luis Zapata Ortiz/PI_position/Projects/P3_ClinicalTrials_ICR/Aim3_RadioImmunoPRADA"
RAW   <- file.path(PRADA, "03_data/WES/nextNEOpi_hc")
OUT   <- "data"   # ejecutar desde la carpeta raíz de la práctica
stopifnot(dir.exists(OUT))

## ---- 1. Mapa de anonimización (P1012 = caso guía = PAC01) ----------------------
map <- data.table(patient = c("P1012","P1001","P1006","P1008","P2002","P2006","P2008","P2011"),
                  anon    = sprintf("PAC%02d", 1:8))
fwrite(map, file.path(RAW, "MAPA_ANONIMIZACION_privado.tsv"), sep = "\t")   # queda en PRADA, NO en data/
anon <- function(x) { for (i in seq_len(nrow(map))) x <- gsub(map$patient[i], map$anon[i], x); x }

## ---- 2. Lectura de VCF nextNEOpi + VEP (consecuencia más grave en transcrito codificante) ----
sev <- c("transcript_ablation","splice_acceptor_variant","splice_donor_variant","stop_gained",
         "frameshift_variant","stop_lost","start_lost","transcript_amplification","inframe_insertion",
         "inframe_deletion","missense_variant","protein_altering_variant","splice_region_variant",
         "splice_donor_5th_base_variant","splice_donor_region_variant","splice_polypyrimidine_tract_variant",
         "incomplete_terminal_codon_variant","start_retained_variant","stop_retained_variant",
         "synonymous_variant","coding_sequence_variant","mature_miRNA_variant","5_prime_UTR_variant",
         "3_prime_UTR_variant","non_coding_transcript_exon_variant","intron_variant","NMD_transcript_variant",
         "non_coding_transcript_variant","upstream_gene_variant","downstream_gene_variant",
         "TFBS_ablation","TFBS_amplification","TF_binding_site_variant","regulatory_region_ablation",
         "regulatory_region_amplification","feature_elongation","regulatory_region_variant",
         "feature_truncation","intergenic_variant")
read_vcf <- function(s) {
  f <- file.path(RAW, s, "05_vep/vcf/high_confidence", paste0(s, "_hc_vep.vcf.gz"))
  x <- fread(cmd = paste("gzip -dc", shQuote(f), "| grep -v '^##'"), sep = "\t", header = TRUE, colClasses = "character")
  setnames(x, 1, "CHROM")
  nc <- grep("_normal$", names(x), value = TRUE); tc <- grep("_tumor$", names(x), value = TRUE)
  fmt  <- strsplit(x$FORMAT, ":")
  getf <- function(col, key) mapply(function(f, v) strsplit(v, ":")[[1]][match(key, f)], fmt, x[[col]])
  adT <- getf(tc, "AD"); adN <- getf(nc, "AD")
  csq <- sub(".*CSQ=([^;]*).*", "\\1", x$INFO)
  best <- t(sapply(strsplit(csq, ","), function(tr) {
    m  <- do.call(rbind, lapply(strsplit(tr, "\\|"), function(z) z[1:12]))
    rk <- sapply(strsplit(m[, 2], "&"), function(cc) suppressWarnings(min(match(cc, sev), na.rm = TRUE)))
    rk[m[, 8] != "protein_coding"] <- rk[m[, 8] != "protein_coding"] + 100
    m[which.min(rk), c(2, 3, 4, 11, 12)]
  }))
  data.table(sample = s, CHROM = x$CHROM, POS = as.integer(x$POS), REF = x$REF, ALT = x$ALT, FILTER = x$FILTER,
             t_ref = as.integer(sub(",.*", "", adT)), t_alt = as.integer(sub(".*,", "", adT)),
             n_ref = as.integer(sub(",.*", "", adN)), n_alt = as.integer(sub(".*,", "", adN)),
             CALLERS = sub(".*VariantCalledBy=([^;]*).*", "\\1", x$INFO),
             CONSEQUENCE = sub("&.*", "", best[, 1]), IMPACT = best[, 2], GENE = best[, 3],
             HGVSc = sub(".*:", "", best[, 4]), HGVSp = sub(".*:", "", best[, 5]))
}
samples <- as.vector(t(outer(map$patient, c("D", "M"), paste0)))
V <- rbindlist(lapply(samples, read_vcf))

## contexto trinucleotídico (samtools faidx, GRCh38)
tri <- fread(file.path(RAW, "snv_trinuc.tsv"), header = FALSE, col.names = c("region", "TRINUC"))
tri[, `:=`(CHROM = sub(":.*", "", region), POS = as.integer(sub(".*:(\\d+)-.*", "\\1", region)) + 1L)]
V <- merge(V, tri[, .(CHROM, POS, TRINUC)], by = c("CHROM", "POS"), all.x = TRUE, sort = FALSE)
V[nchar(REF) != 1 | nchar(ALT) != 1, TRINUC := "."]
stopifnot(V[TRINUC != ".", all(substr(TRINUC, 2, 2) == REF)])   # el REF coincide con la referencia

## ---- 3. Escribir VCF docentes simplificados ---------------------------------------
write_teaching_vcf <- function(s) {
  d <- V[sample == s][order(factor(CHROM, levels = paste0("chr", c(1:22, "X", "Y"))), POS)]
  id <- anon(s); pt <- substr(id, 1, 5); tp <- substr(s, 6, 6)
  hdr <- c("##fileformat=VCFv4.2",
           "##source=nextNEOpi_v1.4_Mutect2_alta_confianza(PASS,_confirmado_por_>=2_llamadores)+VEP",
           "##reference=GRCh38 (GRCh38.d1.vd1)",
           sprintf("##paciente=%s", pt),
           sprintf("##momento=%s", ifelse(tp == "D", "D_biopsia_diagnostica_pretratamiento", "M_mastectomia_postratamiento")),
           "##datos=REALES_ANONIMIZADOS_cohorte_PRADA_ICR_uso_docente_exclusivo_NO_REDISTRIBUIR",
           '##FILTER=<ID=PASS,Description="Todas las variantes de este archivo pasaron FilterMutectCalls y fueron confirmadas por un segundo llamador">',
           '##INFO=<ID=GENE,Number=1,Type=String,Description="Gen (VEP)">',
           '##INFO=<ID=CONSEQUENCE,Number=1,Type=String,Description="Consecuencia más grave en transcrito codificante (VEP, Sequence Ontology)">',
           '##INFO=<ID=IMPACT,Number=1,Type=String,Description="Impacto VEP: HIGH, MODERATE, LOW, MODIFIER">',
           '##INFO=<ID=HGVSc,Number=1,Type=String,Description="Cambio en cDNA">',
           '##INFO=<ID=HGVSp,Number=1,Type=String,Description="Cambio en proteína">',
           '##INFO=<ID=TRINUC,Number=1,Type=String,Description="Contexto trinucleotídico de referencia (5\'-REF-3\'), solo SNV">',
           '##INFO=<ID=CALLERS,Number=1,Type=String,Description="Llamadores que detectaron la variante (M2=Mutect2, ST=Strelka, VS=VarScan)">',
           '##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotipo">',
           '##FORMAT=<ID=AD,Number=R,Type=Integer,Description="Lecturas de alta calidad que apoyan REF,ALT">',
           '##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Profundidad = suma de AD">',
           '##FORMAT=<ID=AF,Number=A,Type=Float,Description="Fracción alélica = ALT/DP">',
           paste(c("#CHROM","POS","ID","REF","ALT","QUAL","FILTER","INFO","FORMAT","NORMAL","TUMOR"), collapse = "\t"))
  enc <- function(z) gsub(";", ",", gsub(" ", "_", ifelse(is.na(z) | z == "", ".", z)))
  body <- d[, paste(CHROM, POS, ".", REF, ALT, ".", FILTER,
                    paste0("GENE=", enc(GENE), ";CONSEQUENCE=", enc(CONSEQUENCE), ";IMPACT=", enc(IMPACT),
                           ";HGVSc=", enc(HGVSc), ";HGVSp=", enc(HGVSp), ";TRINUC=", TRINUC, ";CALLERS=", enc(CALLERS)),
                    "GT:AD:DP:AF",
                    sprintf("0/0:%d,%d:%d:%.3f", n_ref, n_alt, n_ref + n_alt, n_alt / pmax(1, n_ref + n_alt)),
                    sprintf("0/1:%d,%d:%d:%.3f", t_ref, t_alt, t_ref + t_alt, t_alt / pmax(1, t_ref + t_alt)),
                    sep = "\t")]
  f <- file.path(OUT, "vcf", paste0(pt, "_", tp, ".somatic.vcf"))
  writeLines(c(hdr, body), f); system(paste("gzip -f", shQuote(f)))
}
invisible(lapply(samples, write_teaching_vcf))

## ---- 4. Recuentos forzados (pileup del tumor D y M en todas las SNV del paciente) -----
fg <- fread(file.path(RAW, "forced_genotypes.tsv"))
fg[, `:=`(paciente = anon(patient), momento = substr(sample, 6, 6))]
fwrite(fg[, .(paciente, momento, chrom, pos, ref, alt, ref_count, alt_count, depth)],
       file.path(OUT, "recuentos_forzados_snv.tsv"), sep = "\t")

## ---- 5. Número de copias (Sequenza), pureza (patología, Sequenza, ASCAT), TMB nextNEOpi ----
meta <- fread(cmd = paste("tr -d '\\r' <", shQuote(file.path(PRADA, "01_metadata/WES_metadata_v7.txt"))))
cnv <- rbindlist(lapply(samples, function(s) {
  x <- fread(file.path(RAW, s, "08_CNVs/Sequenza", paste0(s, "_segments.txt")))
  x[, .(muestra = anon(s), chrom = chromosome, inicio = start.pos, fin = end.pos, CN_total = CNt, CN_mayor = A, CN_menor = B, n_snp_baf = N.BAF)]
}))
cnv[, `:=`(paciente = substr(muestra, 1, 5), momento = substr(muestra, 6, 6))][, muestra := NULL]
fwrite(cnv, file.path(OUT, "cnv", "segmentos_sequenza.tsv"), sep = "\t")

pur <- rbindlist(lapply(samples, function(s) {
  sq <- fread(file.path(RAW, s, "08_CNVs/Sequenza", paste0(s, "_confints_CP.txt")))
  asc <- tryCatch(fread(file.path(RAW, s, "08_CNVs/ASCAT3", paste0(s, "_tumor.purityploidy.txt"))), error = function(e) NULL)
  tmb <- readLines(file.path(RAW, s, "07_MutationalBurden", paste0(s, "_mutational_burden_coding.txt")))
  num <- function(k) as.numeric(sub(".*\t", "", grep(k, tmb, value = TRUE, fixed = TRUE)[1]))
  data.table(muestra = s,
             pureza_patologia = meta[Trial_ID == s, Tumour_area] / 100,
             pureza_sequenza = sq$cellularity[2], ploidia_sequenza = sq$ploidy.estimate[2],
             pureza_ascat = if (!is.null(asc) && nrow(asc) > 0 && is.numeric(asc[[1]])) asc[[1]][1] else NA_real_,
             ploidia_ascat = if (!is.null(asc) && nrow(asc) > 0 && is.numeric(asc[[2]])) asc[[2]][1] else NA_real_,
             territorio_exonico_pb_nextneopi = num("Coverage over exons"),
             variantes_codificantes_nextneopi = num("Variants of type coding"),
             tmb_codificante_nextneopi = num("Mutational load (variants/Mbps)"))
}))
pur[, muestra := anon(muestra)]
fwrite(pur, file.path(OUT, "pureza_y_tmb_nextneopi.tsv"), sep = "\t")

## ---- 6. SV (Manta, PASS) y fusiones (Arriba, ARN) ---------------------------------
sv <- rbindlist(lapply(samples, function(s) {
  f <- file.path(RAW, s, "04_variations/manta", paste0(s, "_somaticSV.vcf.gz"))
  x <- fread(cmd = paste("gzip -dc", shQuote(f), "| grep -v '^##'"), sep = "\t", header = TRUE)
  if (!nrow(x)) return(NULL); setnames(x, 1, "CHROM"); x <- x[FILTER == "PASS"]
  if (!nrow(x)) return(NULL)
  x[, .(muestra = anon(s), chrom = CHROM, pos = POS, tipo = sub(".*SVTYPE=([^;]*).*", "\\1", INFO),
        longitud = suppressWarnings(as.integer(sub(".*SVLEN=-?([0-9]*).*", "\\1", INFO))), alt = ALT,
        puntaje_somatico = as.integer(sub(".*SOMATICSCORE=([0-9]*).*", "\\1", INFO)))]
}), fill = TRUE)
sv[!grepl("SVLEN", tipo) & tipo == "BND", longitud := NA]
fwrite(sv, file.path(OUT, "sv_manta_pass.tsv"), sep = "\t")

fus <- rbindlist(lapply(samples, function(s) {
  f <- Sys.glob(file.path(RAW, s, "11_Fusions/Arriba", "*fusions.tsv")); f <- f[!grepl("discarded", f)]
  if (!length(f)) return(data.table(muestra = anon(s), arn_disponible = FALSE))
  x <- fread(f[1], sep = "\t", quote = "")
  setnames(x, 1, "gene1")
  if (!nrow(x)) return(data.table(muestra = anon(s), arn_disponible = TRUE))
  x[, .(muestra = anon(s), arn_disponible = TRUE, gen1 = gene1, gen2 = gene2, punto1 = breakpoint1, punto2 = breakpoint2,
        tipo = type, lecturas_split = split_reads1 + split_reads2, pares_discordantes = discordant_mates,
        confianza = confidence, marco = reading_frame)]
}), fill = TRUE)
fwrite(fus, file.path(OUT, "fusiones_arriba.tsv"), sep = "\t")

## ---- 7. Clínica docente -----------------------------------------------------------
cl <- meta[Patient_ID %in% map$patient & Timepoint %in% c("D", "M"),
           .(muestra = Trial_ID, subtipo = Molecular_subtype, momento = Timepoint, estadio_T = T.stage,
             ganglios = Nodal.status, grado = Grade, pureza_patologia = Tumour_area / 100,
             sTIL = sTIL_score, pCR = PCR, respuesta = Response)]
cl[, `:=`(paciente = anon(substr(muestra, 1, 5)), tratamiento = "Quimioterapia + radioterapia preoperatoria (brazo PRADA)")]
cl[, muestra := NULL]; setcolorder(cl, c("paciente", "momento"))
fwrite(cl[order(paciente, momento)], file.path(OUT, "clinica_docente.tsv"), sep = "\t")

## ---- 8. Expresión de genes inmunes (RSEM TPM) -------------------------------------
genes <- c("PTPRC","CD3E","CD8A","CD4","FOXP3","GZMA","GZMB","PRF1","NKG7","IFNG","CXCL9","CXCL10","CXCL13",
           "IDO1","STAT1","HLA-DRA","HLA-DQA1","HLA-DRB1","HLA-E","HLA-A","HLA-B","HLA-C","B2M","TAP1","PSMB10",
           "CCL5","CD27","CD274","CD276","PDCD1","PDCD1LG2","CTLA4","LAG3","TIGIT","HAVCR2","CXCR6","CMKLR1",
           "MS4A1","CD19","CD79A","JCHAIN","MZB1","CD68","CD163","ESR1","PGR","ERBB2","KRT5","EPCAM","MKI67",
           "COL1A1","ACTA2")
nv <- fread(file.path(PRADA, "03_data/RNA/novogene_counts/1.Count/gene_fpkm.xls"), select = c("gene_id", "gene_name"))
tpm <- fread(file.path(PRADA, "03_data/RNA/rsem_2026-09_TrialIDs/rsem.merged.gene_tpm.tsv"))
tpm[, gene_id := sub("\\..*", "", gene_id)]
tpm <- merge(nv[gene_name %in% genes], tpm, by = "gene_id")
keep <- intersect(samples, names(tpm))
ex <- melt(tpm[, c("gene_name", keep), with = FALSE], id.vars = "gene_name", variable.name = "muestra", value.name = "TPM")
ex <- ex[, .(TPM = sum(TPM)), by = .(gen = gene_name, muestra)]
ex[, `:=`(paciente = anon(substr(muestra, 1, 5)), momento = substr(muestra, 6, 6))][, muestra := NULL]
fwrite(ex[order(paciente, momento, gen)], file.path(OUT, "expresion_inmune_tpm.tsv"), sep = "\t")

## ---- 9. TCRβ (T0 = pretratamiento; T3 = cirugía) ----------------------------------
tcrdir <- file.path(PRADA, "03_data/TCRseq/TCRseq_Data_Miki")
for (f in list.files(tcrdir, pattern = paste0("^(", paste(map$patient, collapse = "|"), ")-T[0-3]\\.tsv$"), full.names = TRUE)) {
  x <- fread(f, select = c("v_call", "j_call", "junction_aa", "duplicate_count", "productive"))
  x <- x[productive %in% c(TRUE, "T", "TRUE")][, .(conteo = sum(duplicate_count)), by = .(cdr3b = junction_aa, v = v_call, j = j_call)]
  fwrite(x[order(-conteo)], file.path(OUT, "tcr", paste0(anon(sub("\\.tsv$", "", basename(f))), ".tsv")), sep = "\t")
}
message("Datos docentes escritos en ", OUT)
