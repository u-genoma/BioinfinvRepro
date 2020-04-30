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

El código de barras de DNA es un método que utiliza una región corta del DNA (gen o no-codificante) para identificar especies. Por comparación con una **biblioteca de secuencias** de referencia, se puede identificar la secuencia de un individuo de la misma forma que un escáner del supermercado.

Códigos de barras más comúnmente utilizadas para animales (y algunos protistas) es una porción del gen mitocondrial del citocromo c (COI o COX1). Esos estudios son muy controvertidos en plantas, dando que no se ha encontrado un código de barra universal. Por lo tanto se usa regiones tanto del DNA cloroplasto (rbcL, matK) o nuclear (RuBisCO, ITS2).

Los microorganismos se detectan utilizando diferentes regiones de genes. El gen 16S rDNA se usa ampliamente en la identificación de procariotas, mientras que el gen 18S rDNA se usa principalmente para detectar eucariotas microbianos. En el caso de hongos, el código de barras universal es la region no-codificante de ITS rDNA (ITS1 o ITS2), pero para ciertos grupos se necesita otras regiones como 18S rDNA (hongos micorrízicos arbusculares) o 28S rDNA (Ophiostomatales). Estas regiones se eligieron por ser faciles de amplificar en un rango amplio de especies, y tener una variación intraespecífica menor a la variación interespecífica, lo que se conoce como **barcoding gap**. El procentage de similitud usado para delimitar especies de micro-organismos está definido a *97%*, aunque ese porcentaje puede variar entre diferentes grupos. 

![barcoding_gap](https://github.com/u-genoma/BioinfinvRepro/blob/master/Unidad8/Metagenomica/barcoding_gap.png)

Cuando se usa códigos de barras para identificar organismos dentro de una muestra que contiene el DNA de más de un organismo, se habla de **meta-barcoding**. Esos taxones se definen basándose en el *barcoding gap* (en general con 97% de similitud), por lo cual se identifican como **operational taxonomic units** (OTUs) que pueden ser aproximados como “especies”.  

Estudios de meta-barcoding se han multiplicado en un esfuerzo por identificar la diversidad de especies de un ambito particular (suelo, agua) o en partes de un organismo (***microbioma*** de las hojas, del estomago de animales, etc). Han permitido el descubrimiento de muchas especies desconocidas y de patrones ecológicos fundamentales para los ecosistemas. Sin embargo existen varios siesgos metodólogicos que hay que tener en cuenta para tener estimaciones robustas de diversidad.


### PCR
Para poder secuenciar el código de barra de todos los organismos presentes dentro de una muestra es necesario amplificarlo por PCR. Por lo tanto, no existen *primers* que funcionan para todos los micro-organismos (como es el caso de la meta-genómica), por lo cual los procariontes y eucariontes se tienen que analizar de manera separada. 

Adentro de los diferentes reinos de eucariontes, ciertos primers tienen más afinidades para ciertos grupos y menos (o no funcionan en absoluto) para otros, por lo cual esos grupos serán más dificiles de detectar. Por ejemplo, muchos hongos micorrízicos arbusculares (sub-phylum Glomeromycotina) no se pueden amplificar con los primers "universales" de ITS, por lo cual estudios sobre esos grupos usan en general la región de 18S rDNA ([Leckberg et al. 2018](https://nph.onlinelibrary.wiley.com/doi/full/10.1111/nph.15035)). En resúmen, la **elección de los primers** es fundamental para limitar siesgos en la detección de los micro-organismos de intéres.

Adémas, porque los primers tienen una afinidad variable entre los grupos de organismos presente en una muestra, **no se puede usar la abundancia de reads dentro de una muestra como proxy para determinar la abundancia de OTUs**. Eso se puede verificar usando controles positivos (o *mock*) que tienen el DNA de varias especies en cuantidad identica ([Nguyen et al. 2014](https://nph.onlinelibrary.wiley.com/doi/full/10.1111/nph.12923)).


### "Pairing" de los reads
Muchas plataformas como Illumina secuencian el DNA en ambos direcciones y el *denoising* de los datos implica ensemblar los reads *forward* y *reverse*. Eso puede generar siesgos si la cualidad de los reads *forward* y *reverse* no es igual en todos los grupos taxonómicos ([Truong et al. 2019](https://nph.onlinelibrary.wiley.com/doi/abs/10.1111/nph.15714)).

En esa [pipeline](https://github.com/camillethuyentruong/Illumina_paired_end), desarollamos scripts en python para recuperar *single* reads de alta cualidad en  [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) y
[QIIME](https://qiime2.org/).


### Delimitación de los OTUs
Obviamente, el *barcoding gap* no es identico para todos los grupos de organismos ([Garnica et al. 2016](https://academic.oup.com/femsec/article/92/4/fiw045/2197947)), por lo cual el uso de 97% de similitud permite una **estimación** de la diversidad de especies, no su delimitacíon.

Otro factor importante durante el *clustering* de los reads en OTUs es el **tamaño** de los reads. Obviamente, el número de mutaciones a 97% de similitud no es lo mismo para reads de un tamaño de 150 bp o de 300 bp. El tamaño del código de barras de ITS (hongos) suele ser muy variable. Por lo tanto se desarollaron algoritmos que toman en cuenta el tamaño de los reads. Por ejemplo, [AMPtk](https://amptk.readthedocs.io/en/latest/pre-processing.html?highlight=padding) usa un *padding* de los reads para que todos sean del mismo tamaño.


### Identificación de los OTUs
Como mencionado arriba, la identificación de los OTUs se hace por comparación (*BLAST*) con **bibliotecas de secuencias** de referencia, como GenBank, [Greengenes](https://greengenes.secondgenome.com/) (bacterias) o [UNITE](https://unite.ut.ee/index.php) (hongos). Si una especie no existe en la base de datos, el OTU no podrá ser identificado. Existen miliones de secuencias ambientales y miles de OTUs de hongos que todavía quedan desconocidos ([Nilsson et al. 2016](https://mycokeys.pensoft.net/articles.php?id=7553)).


### Ejemplos de pipelines

Existen una variedad de pipelines para analizar datos de meta-barcoding. Sin embargo, todas contienen los siguientes pasos:

* Pre-Processing / Denoising: eliminar los primers, filtrado de cualidad y de secuencias chimericas, *padding*, etc.
* OTU clustering
* Filtros de la tabla de OTUs: frecuencia, contaminaciones (usando *controles positivos y negativos*)
* Asignación taxonomica: BLAST


[QIIME](https://qiime2.org/) ha sido desarollado y es optimizado para analizar datos de bacterias.

En el caso de hongos, [AMPtk](https://amptk.readthedocs.io/en/latest/pre-processing.html?highlight=padding) es muy eficiente para el clustering (*padding*), filtrado y asignacíon taxonómica de los OTUs.
