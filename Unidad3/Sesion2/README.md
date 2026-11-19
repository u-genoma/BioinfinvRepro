# Práctica: genómica del cáncer de mama antes y después del tratamiento preoperatorio

Magíster en Genética, Universidad de Chile · sesión de 90 min · R Markdown.

## Uso

1. Abrir la carpeta como directorio de trabajo en RStudio.
2. Abrir `Practica_GenomicaCancer.Rmd` y ejecutar los chunks en orden, o hacer *Knit*. La guía se renderiza en ~10 s.
3. La versión resuelta es `soluciones/Practica_GenomicaCancer.html`. Las figuras se guardan en `figuras/`.

## Contenido

| Ruta                              | Descripción                                                                                  |
| --------------------------------- | -------------------------------------------------------------------------------------------- |
| `Practica_GenomicaCancer.Rmd`     | Guía del estudiante (objetivos, cronograma, código, preguntas)                               |
| `scripts/funciones_practica.R`    | Funciones: lectura de VCF, CCF, potencia de detección, SBS96, NNLS y bootstrap, métricas TCR |
| `data/`                           | Datos anonimizados (PAC01–PAC08)                                                             |
| `preparacion/01_preparar_datos.R` | Extracción y anonimización (solo docente; lee rutas privadas de PRADA)                       |
| `soluciones/`                     | HTML renderizado con todos los resultados                                                    |

## Procedencia de los datos

- **Cohorte:** ensayo PRADA (ICR). 8 pacientes con normal germinal verificado (Somalier), con muestras D (biopsia diagnóstica) y M (mastectomía tras quimioterapia y radioterapia preoperatorias). WES sobre GRCh38.
- **Variantes:** nextNEOpi, conjunto de alta confianza (Mutect2 PASS confirmado por Strelka o VarScan) anotado con VEP. La consecuencia elegida es la más grave en un transcrito codificante.
- **Recuentos forzados:** `samtools mpileup` (-Q20 -q20 -B) sobre los BAM tumorales de D y M, en todas las SNV del paciente (D ∪ M).
- **Contexto trinucleotídico:** `samtools faidx` sobre el FASTA GRCh38.
- **Número de copias y pureza:** Sequenza (fila de máxima verosimilitud de `confints_CP`) y ASCAT3, más la pureza patológica (área tumoral/100).
- **SV y fusiones:** Manta (somáticas, PASS) y Arriba (ARN).
- **Expresión:** RSEM TPM, 52 genes. Hay ARN de D y M para 6 de los 8 pacientes.
- **TCRβ:** Decombinator/AIRR (datos TRBRERAD), clonotipos productivos.
- **Firmas:** COSMIC SBS v3.4 GRCh38 (cancer.sanger.ac.uk).

**Anonimización:** los IDs se reemplazaron por PAC01–PAC08, y la tabla de equivalencias queda solo en la carpeta privada de PRADA. Se eliminaron los IDs de laboratorio y de Novogene, las rutas, la edad y la supervivencia.

**Uso:** datos reales para uso docente exclusivo; **no publicar en GitHub**. Para `u-genoma/BioinfinvRepro` se publicará más adelante solo el código, junto con un conjunto de ejemplo.

## Limitaciones conocidas

- Las muestras M tienen pureza de 0–5 %. Las variantes llamadas en M son mayoritariamente artefactos FFPE (C>T de VAF baja).
- La pureza de ASCAT no es fiable en las muestras M, y ASCAT falló en PAC05D.
- No se evaluó la MSI.
- El dN/dS de cohorte está pendiente de decisión.
- Repertorios TCR poco profundos (43–10.576 moléculas): casi no hay clonotipos compartidos entre T0 y T3.



## Soluciones

Puede encontrar las soluciones a este tutorial en este [vínculo](docs/Practica_GenomicaCancer.html).
