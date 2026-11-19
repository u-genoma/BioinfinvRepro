## =============================================================================
## scripts/funciones_practica.R — funciones auxiliares de la práctica
## Solo R base (+ nnls para el ajuste de firmas). Léelas: ¡son parte de la práctica!
## =============================================================================

## ---- Lectura de un VCF somático (tumor vs normal) sin paquetes externos ----------
leer_vcf <- function(archivo) {
  lineas <- readLines(archivo)
  cuerpo <- lineas[!startsWith(lineas, "##")]
  vcf <- read.delim(text = cuerpo, sep = "\t", header = TRUE, check.names = FALSE,
                    colClasses = "character", comment.char = "")
  names(vcf)[1] <- "CHROM"
  ## INFO: "CLAVE=valor;CLAVE=valor" -> columnas
  info <- strsplit(vcf$INFO, ";")
  claves <- c("GENE", "CONSEQUENCE", "IMPACT", "HGVSp", "TRINUC", "CALLERS")
  for (k in claves) vcf[[k]] <- vapply(info, function(z) {
    v <- z[startsWith(z, paste0(k, "="))]; if (length(v)) sub("^[^=]*=", "", v) else NA_character_ }, "")
  ## FORMAT GT:AD:DP:AF -> recuentos de lecturas del normal y del tumor
  ad <- function(x) do.call(rbind, lapply(strsplit(sapply(strsplit(x, ":"), `[`, 2), ","), as.integer))
  t_ad <- ad(vcf$TUMOR); n_ad <- ad(vcf$NORMAL)
  data.frame(chrom = vcf$CHROM, pos = as.integer(vcf$POS), ref = vcf$REF, alt = vcf$ALT,
             gen = vcf$GENE, consecuencia = vcf$CONSEQUENCE, impacto = vcf$IMPACT,
             hgvsp = vcf$HGVSp, trinuc = vcf$TRINUC, llamadores = vcf$CALLERS,
             t_ref = t_ad[, 1], t_alt = t_ad[, 2], t_dp = t_ad[, 1] + t_ad[, 2],
             n_ref = n_ad[, 1], n_alt = n_ad[, 2], n_dp = n_ad[, 1] + n_ad[, 2],
             vaf = t_ad[, 2] / (t_ad[, 1] + t_ad[, 2]),
             tipo = ifelse(nchar(vcf$REF) == 1 & nchar(vcf$ALT) == 1, "SNV", "INDEL"),
             stringsAsFactors = FALSE)
}

## ---- Fracción de células cancerosas (CCF) -----------------------------------------
## VAF esperada para una mutación presente en una fracción 'ccf' de células tumorales,
## con m copias mutadas, número de copias tumoral 'cn_t' y pureza 'p' (normal diploide):
##     VAF = p * ccf * m / (p * cn_t + 2 * (1 - p))
## Invertida:  ccf = VAF * (p * cn_t + 2 * (1 - p)) / (p * m)
calcular_ccf <- function(vaf, pureza, cn_t = 2, m = 1) {
  pmin(vaf * (pureza * cn_t + 2 * (1 - pureza)) / (pureza * m), 1.5)
}

## ---- Potencia para detectar una mutación ------------------------------------------
## P(observar >= k lecturas alternativas | profundidad dp, VAF esperada f) — modelo binomial
potencia_deteccion <- function(dp, vaf_esperada, k_min = 3) {
  1 - pbinom(k_min - 1, size = dp, prob = vaf_esperada)
}

## ---- Espectro de 96 canales (SBS96) ----------------------------------------------
## Convierte cada SNV a la convención de pirimidina (C o T en el centro) y cuenta
## los 96 contextos en el mismo orden que COSMIC (p. ej. "A[C>A]A").
revcomp <- function(x) chartr("ACGT", "TGCA", vapply(strsplit(x, ""), function(z) paste(rev(z), collapse = ""), ""))
contar_sbs96 <- function(ref, alt, trinuc, orden_cosmic) {
  ok <- nchar(ref) == 1 & nchar(alt) == 1 & !is.na(trinuc) & nchar(trinuc) == 3
  ref <- ref[ok]; alt <- alt[ok]; tri <- trinuc[ok]
  purina <- ref %in% c("A", "G")
  ref[purina] <- chartr("ACGT", "TGCA", ref[purina])
  alt[purina] <- chartr("ACGT", "TGCA", alt[purina])
  tri[purina] <- revcomp(tri[purina])
  canal <- paste0(substr(tri, 1, 1), "[", ref, ">", alt, "]", substr(tri, 3, 3))
  as.vector(table(factor(canal, levels = orden_cosmic)))
}

## ---- Ajuste a firmas COSMIC por mínimos cuadrados no negativos (NNLS) ----------------
## Devuelve la fracción de mutaciones atribuida a cada firma.
ajustar_firmas <- function(conteos, firmas) {
  fit <- nnls::nnls(as.matrix(firmas), as.numeric(conteos))
  setNames(fit$x / sum(fit$x), colnames(firmas))
}
## Bootstrap: re-muestrea las mutaciones con reemplazo para estimar la incertidumbre
bootstrap_firmas <- function(conteos, firmas, B = 200, semilla = 1) {
  set.seed(semilla); n <- sum(conteos)
  t(replicate(B, ajustar_firmas(rmultinom(1, n, conteos / n)[, 1], firmas)))
}
similitud_coseno <- function(a, b) sum(a * b) / sqrt(sum(a^2) * sum(b^2))

## ---- Métricas del repertorio TCR -------------------------------------------------
## Clonalidad = 1 - entropía de Shannon normalizada (0 = policlonal, 1 = monoclonal)
metricas_tcr <- function(conteo) {
  p <- conteo / sum(conteo); H <- -sum(p * log(p))
  c(clonotipos = length(conteo), lecturas = sum(conteo), shannon = H,
    clonalidad = if (length(conteo) > 1) 1 - H / log(length(conteo)) else NA,
    frac_top10 = sum(sort(p, decreasing = TRUE)[1:min(10, length(p))]))
}
## Rarefacción: sub-muestrea 'n' moléculas para comparar repertorios de distinta profundidad
rarefaccion_tcr <- function(conteo, n, B = 50, semilla = 1) {
  set.seed(semilla)
  celulas <- rep(seq_along(conteo), conteo)
  r <- replicate(B, { s <- tabulate(sample(celulas, n)); s <- s[s > 0]; metricas_tcr(s)[c("clonotipos", "shannon", "clonalidad")] })
  rowMeans(r)
}
