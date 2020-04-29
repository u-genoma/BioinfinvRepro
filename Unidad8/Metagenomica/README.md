# Meta-"omics"

El termino *meta* se refiere a grupos o conjuntos que **interactuan** entre sí. Por ejemplo una meta-población consiste en un grupo de poblaciones de la misma especie separadas en el espacio y que interactúan en algún nivel.

En genómica, *meta* se refiere a los genomas, transcriptomas o especies de un **conjunto de organismos** que constituye una muestra ambiental (suelo, agua, hoja, insecto, etc). Se usa en general para el estudio de micro-organismos.

* Meta-genómica = conjunto de genes
* Meta-transcriptómica = conjunto de transcriptos
* Meta-barcoding = conjunto de especies


## 1. Meta-genómica
La metagenómica es el estudio de una colección del material genético (genomas) dentro de una comunidad mixta de organismos. La metagenómica suele referirse al estudio de comunidades microbianas.

Cuando se secuencia el DNA de una muestra, por ejemplo una hoja, en realidad se está secuenciando todo el material genético, incluso los micro-organismos que están presentes. En general, las secuencias de esos micro-organismos se filtran durante la limpieza de las secuencias.

La cobertura es determinada por la variación en la
abundancia relativa de cada miembro de la
comunidad microbiana y el tamaño de su genoma. Por suerte bacterias y hongos tienen genomas muy pequeños (en general >50 MB)! Sin embargo tecnicas de secuenciación sin enriquecimiento del genoma (i.e. secuenciacion por sonicación o shotgun sequencing) funcionan bien para estudiar comunidades microbianas **poco diversas** (como insectos o el estomago de animales), para obtener una profundidad de secuenciación adecuada. Pero eso puede cambiar en el futuro!

Para separar esos micro-organismos y sus genes, se realiza el ensamble de un meta-genóma *de novo*. Las contigs se asignan a **bins** basandose en su contenido de G+C, el uso de codones, el coverage de las secuencias, la presencia de pequeños nmers (frecuencia nucleotidica), etc. Un ejemplo de pipeline es [SqueezeMeta](https://github.com/jtamames/SqueezeMeta).

Para identificar esos micro-organismos y sus genes, se puede usar varios algoritmos semejantes a BLAST. Un ejemplo de pipeline es [FindFungi](https://github.com/GiantSpaceRobot/FindFungi).


## 2. Meta-transcriptómica

La metatranscriptómica es semejente a la meta-genómica con la diferencia que se estudia comunidades microbianas por el medio de RNA en vez de DNA. Eso permite identificar las funciones de comunidades microbianas **activas** en el momento.

Se realiza el ensamble de un meta-transcriptóma *de novo* y se usa como transcriptóma de referencia para asignar los reads de cada muestra. Eso permite identificar los genes responsibles de la expresión génica, pero también cuantificar su actividad por el número de reads.

En el estudio de [Gonzalez et al. 2018](https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-018-0432-5), se extrayó el RNA total de raíces de una especie de *Salix* secuenciado usando Illumina HiSeq 2500. Ensamblaron 12 muestras biológicas en un meta-transcriptoma *de novo* y analizaron la expresión diferencial de cada contig entre las muestras.

En otro ejemplo, esa vez con genóma reducido, [Delhomme et al. 2015](https://journals.plos.org/plosone/article?id=10.1371/journal.pone.0139080#sec010) usaron datos de RNA-Seq de agujas de *Picea abies* para identificar grupos de hongos presentes en las muestras, así que familias de genes involucrados en el crecimiento, el metabolismo y la regulación de genes. Ellos filtraron los contigs usando dos metodos complementarios: el genóma de referencia de *Picea abies* para identificar las contigs de planta, y un meta-transcriptoma *de novo* separando las contigs de plantas y hongos basandose en el contenido de G+C.

![Pipeline Delhomme et al. 2015](https://github.com/u-genoma/BioinfinvRepro/blob/master/Unidad8/Metagenomica/Delhomme2015_FigS2.png)

En resumen, uno de los ventajas de la meta-genómica y la meta-transcriptomica sobre el meta-barcoding es que no solamente se identifica "especies" de micro-organismos pero también sus funciones (genes y transcriptos). Pero como está mencionado arriba, presentemente la cobertura de las tecnicas de secuenciación solo permiten estudiar a fondo comuniades microbianas poco diversas.


## 3. Meta-barcoding
