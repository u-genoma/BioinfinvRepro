# Tutorial de AMPtk con datos de ITS2 (hongos) generados por Illumina MiSeq 

Conéctate al clúster de CONABIO

Los datos que usaremos están en `metagenomica/fastq`

Son 24 muestras de suelo rizosférico recolectados en sitios de bosque nativo (**N**) y mixto (**M**) de Quercus (**Q**) y de Juniperus (**J**).

Para cada muestra tenemos un archivo fastq con las secuencias *forward* (R1) y otro con las secuencias *reverse* (R2)

Antes de empezar, crea una carpeta con tu nombre y trabaja desde allí: `mkdir yourname` , `cd yourname`


## 1. Pre-processing FASTQ files

*En ese paso se ensamblan los reads forward y reverse, además de eliminar los primers y secuencias cortas.*

`amptk illumina -i ../metagenomica/fastq -o amptk/ -f GTGARTCATCRARTYTTTG -r CCTSCSCTTANTDATATGC -l 300 --min_len 300 --full_length --cleanup`

-i, input folder with FASTQ files

-o, output name

-f, forward primer sequence (here: gITS7ngs)

-r, -reverse primer sequence (here: ITS4ngsUni)

-l, lenght of reads (here: 300 bp)

--min_len, minimum length to keep a sequence

--full_length, keep only full length sequences

--cleanup, remove intermediate files


## 2. Clustering at 97% similarity with UPARSE 

*En ese paso se hace un filtro de cualidad (incluso de las secuencias chimericas) y se agrupan las secuencias en OTUs*

`amptk cluster -i amptk.demux.fq.gz -o cluster -m 2 --uchime_ref ITS`

-i, input folder with paired sequences

-o, output name

-m, minimum number of reads for valid OTU to be retained (singleton filter)

--uchime_ref, run chimera filtering (ITS, LSU, COI, 16S, custom path)



## 3. Filtering the OTU table (index bleed)

*Index bleed = reads asignados a la muestra incorrecta durante el proceso de secuenciación de Illumina. Es frecuente (!!) y además con un grado variable entre varios runs. En ese paso, se puede usar un control positivo (mock) artificial para medir el grado de index bleed dentro de un run. Si el run no incluyó un mock artificial, este umbral se puede definir manualmente (en general se usa 0,005%).*

`amptk filter -i cluster.otu_table.txt -o filter -f cluster.cluster.otus.fa -p 0.005 --min_reads_otu 2`

-i, input OTU table

-o, output name

-f, fasta file with reference sequence for each OTU

-p, % index bleed threshold between samples (if not calculated)

--min_reads_otu, minimum number of reads for valid OTU to be retained (singleton filter)


Hay mucho debate sobre los **OTUs escasos** en ecología microbiana. Algunos piensen que son especies reales con importancia en los patrones de diversidad. Otros argumentan que son el resultado de artefactos y *no se puede comprobar si son especies reales o no*.



## 4. Assign taxonomy to each OTU

*AMPtk utiliza la base de datos de secuencias de [UNITE] (https://unite.ut.ee/) para asignar la taxonomía de los OTUs. Dado que es una base de datos curada, en general da resultados mucho mejores que GenBank (por ejemplo usando QIMME).*

`amptk taxonomy -i filter.final.txt -o taxonomy -f filter.filtered.otus.fa -m ../metagenomica/amptk.mapping_file.txt -d ITS2 --tax_filter Fungi`

-i, input OTU table

-o, output name

-f, fasta file with reference sequence for each OTU

-m, mapping file with meta-data associated with the samples

-d, pre-installed database [ITS1, ITS2, ITS, 16S LSU, COI]

--tax_filter, remove OTUs that do not match filter, i.e. Fungi to keep only fungi


## Felicitaciones! 
Ahora tienes una tabla de OTU en formato `.biom` que puedes cargar en R para hacer análisis de diversidad. Esa tabla contiene la tabla de OTUs con su frecuencia por muestra, su taxonomía, y los meta-datos asociados a cada muestra.
