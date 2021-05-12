# Práctica Stacks en vivo con datos pequeños

Esta prática de Stacks está basada en:

* El práctico de esta unidad impartido el año pasado en este curso. Gran parte del material es el mismo que el año pasado, pero me tomé la libertad de cambiar algunas cosas, como el set de datos y algunas de la opciones de STACKs que veremos en más detalle. 

* El protocolo Rochette, N. C. & Catchen, J. M. Deriving genotypes from RAD-seq short-read data using Stacks. Nature Protocols 12, 2640–2659 (2017).

* Los datos son un subset de los datos publicados en Casas, L., Saenz‐Agudelo, P., Villegas‐Ríos, D., Irigoien, X. et Saborido‐Rey, F. (2021). Genomic landscape of geographically structured colour polymorphism in a temperate marine fish. Molecular Ecology, 30(5), 1281‑1296. 10.1111/mec.15805
 
* El [Manual de stacks](http://catchenlab.life.illinois.edu/stacks/manual)

* La versión v2.5 de Stacks 


**NOTAS IMPORTANTES:** 

1) dependiendo de cómo esté instalado Stacks en tu servidor, quizá tengas que correr los comandos de Stacks con `stacks` antes de cada comando. Por ejemplo: `stacks process_radtags` en vez de `process_radtags`. 

2) Algunos flags dentro de los parámetros de Stacks cambiaron entre la versión que Rochette & Catchen (2017) utilizaron y la actualmente disponible. Por lo tanto los modifiqué.  **El [manual de Stacks](http://catchenlab.life.illinois.edu/stacks/manual/) de la versión que tengas instalada siempre debe de ser tu referencia** de los comandos de Stacks.

3) Los comandos de abajo son ligeramente distintos a los de Rochette debido a las diferencias del punto 2 y a que ajusté las rutas relativas.

4) El tutorial utiliza corre de forma interactiva ("líneas de código en la terminal" en vez de scripts. Pero recuerda que cuadno lo estés utilizando en tu proyecto deberás **hacer tus scripts** y probablemente correrlos en un cluster con un sistema de colas. 

5) Para esta práctica corrí previamente algunos de los pasos que tardan más tiempo.

### Preparar tu espacio en el cluster para esta práctica:

#### verifica que estás en tu carpeta el el cluster. 

#### Datos

Los datos que vamos a usar son un subset de Casas et al. 2020. Sin embargo, el set de datos completo está disponible en GenBank (leer el paper para más información). [La versión con datos completos de este tutorial](./Practica_Stacks_fulldata.md) sin embargo, aquí utilizaremos una versión más pequeña y con alguno de los pasos ya corridos por mí previamente, para ahorrar tiempo.

Estos datos están en mi carpeta en el cluster, en un directorio llamado `stackss_bioinfo2021`.

Por limitación de espacio en el servidor, les pido que no copien toda la carpeta si no que que crearemos variables para acceder a los archivos que necesitemos. 


Ahora entremos al directorio y veamos qué contiene:

```
$ ls /home-old/bioinfo1/psaenz/stacks_bioinfo2021
bowtie_index clean_small      genome  raw   info   stacks.ref    tests.ref
alignments  info    stacks.denovo  tests.denovo
```

Esta organizaciónd e directorios es muy limpia, por lo que te recomendamos usar una organización así para tu proyecto.


## ¿Qué va en cada directorio?

* **info** equivalente a `meta`. Aquí van los datos de tus barcodes, population maps (de qué especie/población es cada muestra) u otros metadatos.

* **raw:** aquí van las secuencias `.fq.gz` crudas, tal cual salidas del secuenciador. (paso 0)

Los datos originales tienen los datos de tres lanes, aquí utilizaremos solo los de lane1.

* **cleaned:** aquí van tus secuencias después de hacer un análisis de calidad, limpiarlas y demultiplexearlas. (pasos 1 y 2). 

Alternativamente puedes tener un directorio `cleaned` y otro `samples` para las lecturas limpias y demultiplexeadas, respectivamente, si haces estos pasos por separado.

* **genome:** aquí vivirá tu genoma de referencia. (paso 3). Este directorio solo existe si corres stacks con genoma de referencia.

* **tests.denovo** aquí van los resultados de tus (varias) pruebas de  con algunas pocas muestras de correr la pipeline con ensamblado de novo(paso 4a)

* **tests.denovo** aquí van los resultados de tus (no tantas) pruebas con  pocas muestras de correr la pipeline con genoma de referencia (paso 4b)

* **stacks.denovo:** aquí van los resultados de correr tu pipeline con ensamblado de novo con los parámetros que elegiste después de las pruebas (paso 5a)

* **aligments:** aquí va el resultado de alinear las secuencias de tus muestras vs el genoma de referencia. Este directorio solo existe si corres stacks con genoma de referencia. (paso 5b)

* **stacks.ref:** aquí va el resultado correr la pipeline utilizando genoma de referencia con todas tus muestras, después de hacer las pruebas.(paso 5b) 




#### Paso 0) Preparar input
El paso 0 de la pipeline es poner nuestras secuencias en `/raw`, y los barcodes y population map en `/info`. Como notarás si haces `ls` a esos directorios, estos pasos ya están hechos.


Según la [sección de los barcodes del manual de Stacks](http://catchenlab.life.illinois.edu/stacks/manual/#specbc), estos deben estar en un archivo que se vea así:

`<barcode>TAB<sample name>`

Por ejemplo: 

```
$ cat info/barcodes.txt 
AAAAA	Vi01-S100
AACCC	Vi02-S100
AAGGG	Vi03-S100
AATTT	Vi04-S100
ACACG	Vi05-S100
ACCAT	Vi06-S100
ACGTA	Vi11-S100
ACTGC	Vi12-S100
...
```

Y el [population map](http://catchenlab.life.illinois.edu/stacks/manual/#popmap) describe a qué población corresponde cada muestra:

Estructura:

`<sample name>TAB<population name>`

Ejemplo:

```
$ cat /home-old/bioinfo1/psaenz/stacks_bioinfo2021/info/popmap.txt 
Vi02-S100	Vigo
Vi08-P100	Vigo
Vi24-P100	Vigo
Vi32-S100	Vigo
```

#### Paso 1) Revisar la calidad de los datos

**Nota** Todos los comandos asumen que estamos trabajando desde `stacks_bioinfo2021` 

Ver si las secuencias empiezan como lo esperamos según nuestros barcodes y nuestra enzima de restricción. Por ejemplo para los datos del tutorial esperamos un barcode de 6 bases + sitio de corte de SbfI tras la ligación (TGCAGG).

Para una muestra:

```
$ zcat raw/subset_7098-7142__Pinto__RAD1_RAD1__L5_NoIndex_L005_R1_001.fastq.gz | head -n 20
@HISEQ:319:C5PB5ACXX:5:1101:1189:1994 1:N:0:
NCACGCATGCTTTGATACAGCTTGAGGNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN
+
#0<FFFFFBFFBBF<FBFFFFFFIF<7##########################################################################
@HISEQ:319:C5PB5ACXX:5:1101:1381:2000 1:N:0:
NGAAGCATGCTACTAAACCTCAGTGAAATGTTGGACTGAGATAATCATGTAGTGTTGCAATCTGTCTGGTTTGGTTTTCCGCACAGGTTGACTAAGAGCTG
+
#00BFFFFFFBFFFFFFBBFFFBFFFFFI<FFFBFFFFBFFFFFBB7B'0BBBFB<BFFFFFFI<FF<F<<FFIBFFBBBFFFBBBBBBBBB<BB<BBBBB
@HISEQ:319:C5PB5ACXX:5:1101:1629:1992 1:N:0:
NGGGACATGCTACAAAATTAAACTGTGTCACCAGAAACACATTAACCACCTGCTGCTGTTGAGGACGGGTCTTTTTTCTTCATCAACAAACCAGCTGAAGA

```

Ejemplo de cómo hacerlo para todas las muestras en el script [1.survey_lanes.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/1.survey_lanes.sh)



#### Paso 2) Limpiar y demultiplexear
**Nota:** las muestras que utilizeremos para los pasos siguientes son unas que yo ya demultiplexié previamente, por lo que puedes **no** correr este paso para seguir el tutorial.

Normalmente correras este paso con todas tus muestras, pero aquí vamos a hacerlo solo con unas poquitas muestras de la lane1, más otras muestras de las otras lanes que previamente demutiplexie y que ya deben estar en `clean`. 

Para demultiplexear estas 3 muestras el proceso debe durar al rededor de 5 mins. 

Las muestras que demultiplexearemos están especificadas en `info/barcodes.txt`. 


Correr [process_radtags para demultiplexear](http://catchenlab.life.illinois.edu/stacks/manual/#clean) según tu tipo de barcodes.

Tener en cuenta que en este ejemplo los datos se secuenciaron en ambas direcciones (paired end) y por lo tanto hay que indicar a Stacks con el flag `-P`. 

```

#primero activemos el ambiente que tiene instalado Stacks 
conda activate stacks_env

#creemos variable para acceder fácil a los archivos que vamos a usar
datos_fuente=/home-old/bioinfo1/psaenz/stacks_bioinfo2021
ls $datos_fuente

#creemos el directorio donde vamos a guardar los datos
mkdir clean_subset

#procedemos a correr el process_radtags
process_radtags -p $datos_fuente/raw -P -b $datos_fuente/info/barcodes.txt -o clean_subset/ -e sphI --inline_null -c -q -r 
```

Mientras corre tu terminal debe verse así:

```
Processing paired-end data.
Using Phred+33 encoding for quality scores.
Found 1 paired input file(s).
Searching for single-end, inlined barcodes.
Loaded 45 barcodes (5bp).
Will attempt to recover barcodes with at most 1 mismatches.
Processing file 1 of 1 [subset_7098-7142__Pinto__RAD1_RAD1__L5_NoIndex_L005_R1_001.fastq.gz]
  Reading data from:
  /home-old/bioinfo1/psaenz/stacks_bioinfo2021/raw/subset_7098-7142__Pinto__RAD1_RAD1__L5_NoIndex_L005_R1_001.fastq.gz and
  /home-old/bioinfo1/psaenz/stacks_bioinfo2021/raw/subset_7098-7142__Pinto__RAD1_RAD1__L5_NoIndex_L005_R2_001.fastq.gz
  Processing RAD-Tags...
1M...2M...3M...4M...5M...
  10000000 total reads; -144556 ambiguous barcodes; -267538 ambiguous RAD-Tags; +470702 recovered; -314993 low quality reads; 9272913 retained reads.
Closing files, flushing buffers...
Outputing details to log: 'clean_subset/process_radtags.log'

10000000 total sequences
  144556 ambiguous barcode drops (1.4%)
  314993 low quality read drops (3.1%)
  267538 ambiguous RAD-Tag drops (2.7%)
 9272913 retained reads (92.7%)
...
```

Puedes ver qué hacen todas las flags en el [manual de process_radtags](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php).

En nuestro caso, ustedes van a explorar el efecto de manipular las dos flags que controlan la calidad de las secuencias: `-w` y `-s`, lo cual es parte de la tarea de este módulo. 

Nuestro output  debe generar dos archivos `fq.gz` para cada muestra (uno de lecturas forward: 1.fq.gz; y uno de reverse: 2.fq.gz) y un archivo `.log`:

```
$ ls clean_subset/
Ma05-S100.1.fq.gz      Ma16-S100.rem.2.fq.gz    Vi01-S100.2.fq.gz      Vi06-P100.1.fq.gz      Vi12-S100.rem.2.fq.gz  Vi20-P100.rem.1.fq.gz
Ma05-S100.2.fq.gz      Ma18-S100.1.fq.gz        Vi01-S100.rem.1.fq.gz  Vi06-P100.2.fq.gz      Vi14-P100.1.fq.gz      Vi20-P100.rem.2.fq.gz
Ma05-S100.rem.1.fq.gz  Ma18-S100.2.fq.gz        Vi01-S100.rem.2.fq.gz  Vi06-P100.rem.1.fq.gz  Vi14-P100.2.fq.gz      Vi21-S100.1.fq.gz
Ma05-S100.rem.2.fq.gz  Ma18-S100.rem.1.fq.gz    Vi02-P100.1.fq.gz      Vi06-P100.rem.2.fq.gz  Vi14-P100.rem.1.fq.gz  Vi21-S100.2.fq.gz
Ma07-S100.1.fq.gz      Ma18-S100.rem.2.fq.gz    Vi02-P100.2.fq.gz      Vi06-S100.1.fq.gz      Vi14-P100.rem.2.fq.gz  Vi21-S100.rem.1.fq.gz
Ma07-S100.2.fq.gz      Ma20-S100.1.fq.gz        Vi02-P100.rem.1.fq.gz  Vi06-S100.2.fq.gz      Vi14-S100.1.fq.gz      Vi21-S100.rem.2.fq.gz
Ma07-S100.rem.1.fq.gz  Ma20-S100.2.fq.gz        Vi02-P100.rem.2.fq.gz  Vi06-S100.rem.1.fq.gz  Vi14-S100.2.fq.gz
```

¡El log tiene info muy importante! Nos dice cuántas lecturas de cada muestra se recuperaron, y si no se recuperaron, por qué.

```
$ less clean_subset/process_radtags.raw.log 
process_radtags v2.53, executed 2021-04-06 14:50:23 (zlib-1.2.8)
process_radtags -p raw/ -P -b info/barcodes.txt -o clean_subset/ -e sphI --inline_null -c -q -r
File    Retained Reads  Low Quality     Barcode Not Found       RAD cutsite Not Found   Total
subset_7098-7142__Pinto__RAD1_RAD1__L5_NoIndex_L005_R1_001.fastq.gz     9272913 314993  144556  267538  10000000

Total Sequences 10000000
Barcode Not Found       144556
Low Quality     314993
RAD Cutsite Not Found   267538
Retained Reads  9272913

Barcode Filename        Total   NoRadTag        LowQuality      Retained
AAAAA   Vi01-S100       273438  10050   9314    254074
AACCC   Vi02-S100       198114  6512    6784    184818
AAGGG   Vi03-S100       245156  6269    7583    231304
AATTT   Vi04-S100       199112  6808    7332    184972
ACACG   Vi05-S100       186342  3480    6175    176687
ACCAT   Vi06-S100       157982  8266    5653    144063
ACGTA   Vi11-S100       58080   3156    1946    52978
ACTGC   Vi12-S100       114018  6799    4113    103106
...
```


#### Paso 3) Conseguir genoma de referencia

**Nota:** ya corrí este paso previamente, **no debes** hacerlo para seguir el tutorial en vivo ni la tarea (bowtie2 está instalado en este cluster, pero el alineamiento toma tiempo y no haremos la demostración en vivo), pero puedes ver su resultado con  `ls ../genome`.

Si existe genoma de referencia para tu especie. Yey. Si no, sáltate este paso.

Baja el archivo `.fa` o `fa.gz` con el genoma de referencia de tu organismo y guárdalo en `genome`. 

El de Labrus bergylta de este ejemplo puede bajarse de [ENSEMBL](https://www.ensembl.org/Labrus_bergylta_/Info/Index) con

```
$ wget "ftp://ftp.ensembl.org/pub/release-103/fasta/labrus_bergylta/dna/Labrus_bergylta.BallGen_V1.dna.toplevel.fa.gz " || exit
$ mv Labrus_bergylta.BallGen_V1.dna.toplevel.fa.gz ../genome
```

Una vez que lo hayas bajado, crea la bd para el alineamiento:

```
genome_fa=$datos_fuente/genome/Labrus_bergylta.BallGen_V1.dna.toplevel.fa.gz
mkdir bowtie_index
cd bowtie_index
bowtie2-build -f $genome_fa L-bergylta

```

Un ejemplo de Script completo en el protocolo de Rochette: [3.genome_db.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/3.genome_db.sh)


#### Paso 4 Hacer pruebas con un set de datos pequeño

Correr Stacks, tanto de novo como con genoma de referencia, tarda. Y como tendrás que hacer varias pruebas para ajustar parámetros es buena idea hacer estas pruebas con un subset de los datos. Por ejemplo 10-12 muestras representativias de tus taxa/poblaciones y número de secuencias por muestras.

Escoje estas muestras y ponlas en un population map de prueba que viva en `/info`. En este caso utilizaremos solo 4 muestras  para fines demostrativos. 

Estas ya están seleccionadas (son las mismas que yo ya dejé demultiplexeadas) y están enlistadas en un pop map que se así: 

```
$ cat $datos_fuente/info/popmap.txt 
Vi02-S100	Vigo
Vi08-P100	Vigo
Vi24-P100	Vigo
Vi30-S100	Vigo
```


#### Paso 4a) Pruebas con ensamble de novo

Script para el paso 4a completo en el protocolo de Rochette: [4.tests_denovo.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/4.tests_denovo.sh)

* **4a.1: Decide cuál de las [estrategias para escoger parámetros de novo utilizarás](http://catchenlab.life.illinois.edu/stacks/manual/#params)** (en realidad ya tomaste esta decisión al hacer tu trabajo de laboratorio).

* **4a.2: Escoge una serie de combinaciones de valores de los [principales parámetros de Stacks de novo](http://catchenlab.life.illinois.edu/stacks/param_tut.php).** 

Normalmente puedes varias M entre 1 y 9, n entre 1 y 5 y dejar los otros parámetros fijos. Eg solo varías M y dejas fijos los demás en los defaults.

* **4a.3: Para cada una de estas combinaciones crea un directorio output dentro de `/tests.denovo`.**

Recuerda ponerles nombres relevantes. Puedes usar a nuestros amigos los for loops para esto.

Ejemplo:

```
mkdir tests.denovo

M_values="1 2 3 "
for M in $M_values ;do
	mkdir -p tests.denovo/stacks.M$M
done
```

* **4a.4: Corre el wrapper [denovo_map](http://catchenlab.life.illinois.edu/stacks/comp/denovo_map.php) de stacks, que corre en un solo comando  los [pasos de la pipeline de novo](http://catchenlab.life.illinois.edu/stacks/manual/#phand).**

**Nota:** este es de los pasos que más tardan en correr. Para 3 muestras se tarda al rededor de 35 mins, por lo tanto yo ya corrií este paso y **no** debes correrlo como parte del tutorial en vivo, pero sí para la tarea.

Una vez más aprovecha tu sabiduría de los for loops. Por ejemplo para probar valores de M del 1 al 3 dejando fijo n y m:

(probamos solo tres valores como ejemplo, pero recuerda tu debes probar más). Para efectos del tutorial hay 4 muestras demultiplexadas que he colocado en una carpeta llamada `clean_small`. 

```
## variables para loop 
M_values="1 2 3"
popmap=$datos_fuente/info/popmap.txt 

## utilizar loop para construir los flags de `denovo_map`
for M in $M_values ;do
	n=$M
	echo "Running Stacks for M=$M, n=$n..."
	reads_dir=$datos_fuente/clean_small/
	out_dir=tests.denovo/stacks.M$M
	log_file=$out_dir/denovo_map.log
		denovo_map.pl --samples $reads_dir -O $popmap -o $out_dir -M $M -n $n --paired --rm-pcr-duplicates -T 8
done
```

**Pregunta** ¿qué hace cada uno de los flags de stacks? 

**Ejercicio que vendrá en la tarea:** correr el  denovo_map para otros valores de M y N hasta completar todas las combinaciones de M 1-4 y n 1-4 **cada estudiante corre una combinación distinta** y **comparte con los compañeros los resultados**.

El ouput dentro de cada uno de tus directorios de resultados se verá parecido a este:

```
$ ls tests.denovo/stacks.M1
catalog.alleles.tsv.gz     cs_1335.01.snps.tsv.gz      pcr_1193.10.snps.tsv.gz           sj_1483.06.alleles.tsv.gz
catalog.calls              cs_1335.01.tags.tsv.gz      pcr_1193.10.tags.tsv.gz           sj_1483.06.matches.bam
catalog.fa.gz              denovo_map.log              populations.haplotypes.tsv        sj_1483.06.matches.tsv.gz
catalog.snps.tsv.gz        gstacks.log                 populations.hapstats.tsv          sj_1483.06.snps.tsv.gz
catalog.tags.tsv.gz        gstacks.log.distribs        populations.log                   sj_1483.06.tags.tsv.gz
cs_1335.01.alleles.tsv.gz  pcr_1193.10.alleles.tsv.gz  populations.log.distribs          tsv2bam.log
cs_1335.01.matches.bam     pcr_1193.10.matches.bam     populations.sumstats.tsv
cs_1335.01.matches.tsv.gz  pcr_1193.10.matches.tsv.gz  populations.sumstats_summary.tsv
```

En resumen para cada muestra te generó un archivo **tags.tsv**, **snps.tsv**, **alleles.tsv**, **matches.tsv** y **matches,bam**. [Puedes ver que contienen exactamente aquí](http://catchenlab.life.illinois.edu/stacks/manual/#files). 

Y no olvides que los logs también están llenos de información preciada

```
$ less tests.denovo/stacks.M1/denovo_map.log 
denovo_map.pl version 2.2 started at 2020-05-04 20:11:32
/opt/anaconda3/envs/stacks_env/bin/denovo_map.pl --samples ../cleaned -O ../info/popmap.test_samples.tsv -o ../tests.denovo/stacks.M1 -M 1 -n 1 -m 3

ustacks
==========

Sample 1 of 12 'cs_1335.01'
----------
/usr/lib/stacks/bin/ustacks -t gzfastq -f ../cleaned/cs_1335.01.fq.gz -o ../tests.denovo/stacks.M1 -i 1 -m 3 -M 1
ustacks parameters selected:
  Input file: '../cleaned/cs_1335.01.fq.gz'
  Sample ID: 1
  Min depth of coverage to create a stack (m): 3
  Repeat removal algorithm: enabled
  Max distance allowed between stacks (M): 1
  Max distance allowed to align secondary reads: 3
  Max number of stacks allowed per de novo locus: 3
  Deleveraging algorithm: disabled
  Gapped assembly: enabled
  Minimum alignment length: 0.8
  Model type: SNP
  Alpha significance level for model: 0.05

Loading RAD-Tags...1M...

Loaded 1302167 reads; formed:
  59499 stacks representing 1190118 primary reads (91.4%)
  104369 secondary stacks representing 112049 secondary reads (8.6%)
  ...
```


* 4a.5 Exporta loci a analizar con [populations](http://catchenlab.life.illinois.edu/stacks/comp/populations.php)
  
**Nota:** este paso corre rápido y vamos a hacerlo en vivo.

Si estás siguiendo el método r80 (Paris et al 2017), filtra los loci que solo estén en al menos el 80% de tus muestras:

```
M_values="1 2 3"
for M in $M_values ;do
	stacks_dir=tests.denovo/stacks.M$M
	out_dir=$stacks_dir/populations.r80
	mkdir $out_dir
	log_file=$out_dir/populations
	populations -P $stacks_dir -O $out_dir -r 0.80
done

```

Si estás siguiendo el protocolo de replicados (Mastretta-Yanes et al 2015) puedes exportar todos los loci, o hacer un filtro como el de arriba. IMPORTANTE: Necesitarás además exportar los datos a plink, agregando el flag `--plink`.

```
$ populations -P $stacks_dir -O $out_dir -r 0.80 --plink
```

También es importante familiarizarnos con los resultados de `populations`. Vamos a verlos en:

```
$ ls tests.denovo/stacks.M1/populations.r80
```

Son los que empiezan con "populations". Puedes copiarlos del cluster a tu computadora local corriendo esto en **otra terminal donde NO estés conectado al cluster**:

```
scp -P bioinfo1@genoma.med.uchile.cl:/TUDIRECTORIO/tests.denovo/stacks.M1/populations.r80/populations* ./
```

Donde `TUDIRECTORIO` corresponde al nombre de tu directorio en el cluster, por ejemplo yo corrí:

```
scp -P 4bioinfo1@genoma.med.uchile.cl:/TUDIRECTORIO/tests.denovo/stacks.M1/populations.r80/populations* ./
```

Con esto los datos se guardarán el wd de la terminal en la que lo hayas corrido. No haré este paso ahorita para ahorrar ancho de banda, pero lo hice previamente. Veamos cada archivo brevemente y qué contienen según [el manual de stacks](http://catchenlab.life.illinois.edu/stacks/manual/#pfiles).


* **4a.6. Compara los outputs**.

La info que queremos está en los archivos output del paso anterior (`populations.r80/populations.log`), y para el método de los replicados además en el archivo plink (para método replicados).

*Método r80*

Te interesa comparar: el % de loci compartido entre el 80% de las muestras, el número de SNPs y el número de loci

Puedes hacer tus propias gráficas, o utilizar los scripts de R de Rochette [4.plot_n_loci.R](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/R_scripts/4.plot_n_loci.R) y [4.plot_n_snps_per_locus.R](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/R_scripts/4.plot_n_snps_per_locus.R). En cualquier forma para esto necesitarás sacar los datos del archivo `populations.r80/populations.log`, de una sección que se ve así:


```
Removed 67306 loci that did not pass sample/population constraints from 298368 loci.
Kept 231062 loci, composed of 105593425 sites; 144245 of those sites were filtered, 164681 variant sites remained.
Number of loci with PE contig: 231062.00 (100.0%);
  Mean length of loci: 446.99bp (stderr 0.26);
Number of loci with SE/PE overlap: 223219.00 (96.6%);
  Mean length of overlapping loci: 459.02bp (stderr 0.26); mean overlap: 30.75bp (stderr 0.02);
Mean genotyped sites per locus: 456.67bp (stderr 0.26).
```

Te dejo un truquito (imo más sencillo que el de Rochette) para extraer esta info de todos los logs con nuestro amigo `sed` y nuestros infalibles loops.

```
mkdir -p tests.denovo/results
results_dir=tests.denovo/results

# create file to save resutls
echo 'M,n,m,n_loci,n_snps' > $results_dir/n_snps_per_locus.tsv

# feed results with a loop
for M in $M_values ;do
	n=$M
	log_file=tests.denovo/stacks.M$M/populations.r80/populations.log

# get number of loci and snps from log file 
n_loci=$(sed -n 's/Kept \(.*\) loci.*/\1/p' $log_file)
n_snps=$(sed -n 's/.*, \([0-9]\{1,\}\) variant .*/\1/p' $log_file)

# echo results and save them to desired file
echo $M,$n,$m,$n_loci,$n_snps >> $results_dir/n_snps_per_locus.tsv
done
```

Veamos los resultados:

```
$ cat tests.denovo/results/n_snps_per_locus.tsv 
M,n,m,n_loci,n_snps
1,1,3,35711,19830
2,2,3,36568,27357
3,3,3,36633,30240
```


#### Paso 4b) Pruebas con genoma de referencia

* **4b.1. Escoge un método de alineamiento**

Revisa el Box 2 de Rochette et al para una discusión de método usar. Aquí utilizaremos BWA.

* **4b.2. Escoge parámetros de alineamiento**

La suerte de quienes tienen genoma de referencia es tal que normalmente no hace falta hacer tantas pruebas como con el ensambladod de novo, pues si el genoma de referencia es cercano se obtienen resultados buenos aún variando parámetros.
 
 * **4b.3. Crea los directorios `alignments` y `stacks` para resultados de prueba en el directorio `/tests.ref`**

Por ejemplo para nuestra prueba con bwa:

```
mkdir -p ../tests.ref/alignments.bwa
mkdir -p ../tests.ref/stacks.bwa/
```

* **4b.4. Alinea _algunas_ muestras (guardadas en `/cleaned`) contra el genoma de referencia.**

**Nota:** este paso ya lo corrí previamente y **no** debes correrlo en el tutorial (bwa no está instalado en este cluster).


El prodecimineto base es:

`bwa mem -M <el genoma indexado previamente> <el .fq.gz de la muestra a alinear> | samtools view -b > <el bam output para esa muestra>`

Podemos usar el population map que hicimos antes (`../info/popmap.test_samples.tsv`) con las pocas muestras para las pruebas de_novo dentro de un loop:


```
# extract samples names from pop name to use in for loop
for sample in $(cut -f1 ../info/popmap.test_samples_few.tsv) ;do

# define variables
	fq_file=../cleaned/$sample.fq.gz
	bam_file=../tests.ref/alignments.bwa/$sample.bam
	log_file=../tests.ref/alignments.bwa/$sample
	db=../genome/bwa/gac
  
# run bwa & samtools 
  bwa mem -M $db $fq_file | samtools view -b | samtools sort --threads 4 > $bam_file
	
done

```

Mientras corre debe verse algo así:

```
[M::bwa_idx_load_from_disk] read 0 ALT contigs
[M::process] read 105264 sequences (10000080 bp)...
[M::process] read 105264 sequences (10000080 bp)...
[M::mem_process_seqs] Processed 105264 reads in 15.612 CPU sec, 15.484 real sec
[M::process] read 105264 sequences (10000080 bp)...
[M::mem_process_seqs] Processed 105264 reads in 15.763 CPU sec, 15.489 real sec
[M::process] read 105264 sequences (10000080 bp)...

```

Nota: en [5.tests_ref.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/5.tests_ref.sh) hay un error en la línea 22, pues hace falta correr `samtools sort` sin lo cual no funciona el siguiente paso.



* **4b.5. Corre `ref_map`**

[ref_map](http://catchenlab.life.illinois.edu/stacks/comp/ref_map.php) es un wrapper de la pipeline con genoma de referencia, que al igual que `denovo_map` conjunta en un solo programa todos los pasos de la pipeline (una vez que tenemos las muestras alineadas), incluyendo `populations`. 


El script del protocolo de Rochette [5.tests_ref.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/5.tests_ref.sh) corre los pasos por separado en vez de usando `ref_map`. Pero yo recomiendo usar el wrapper ref_map, así que mejor revisa la [documentación de ref_map](http://catchenlab.life.illinois.edu/stacks/comp/ref_map.php). 

Ejemplo:

```
## define variables:

# directory with algimened samples
samples_dir=aligned/

# popmap
popmap_file=info/popmap.txt

# output directory
mkdir tests.ref
out_dir=tests.ref/


## Run ref map. acá incluimos el flag rm-pcr-duplicates ya que tenemos pe reads
ref_map.pl --samples $samples_dir --popmap $popmap_file -o $out_dir --rm-pcr-duplicates

``` 

Si todo sale bien debes ver algo así mientras corre:

```
Parsed population map: 4 files in 1 population and 1 group.
Found 4 sample file(s).

Calling variants, genotypes and haplotypes...
  /usr/local/bin/gstacks -I aligned/ -M info/popmap.txt -O tests.ref -t 20 --rm-pcr-duplicates

Calculating population-level summary statistics
  /usr/local/bin/populations -P tests.ref -M info/popmap.txt -t 20

ref_map.pl is done.

```

El output de `ref_map` son estos archivos:

```
$ ls tests.ref/
catalog.calls  gstacks.log.distribs        populations.log           populations.sumstats.tsv
catalog.fa.gz  populations.haplotypes.tsv  populations.log.distribs  populations.sumstats_summary.tsv
gstacks.log    populations.hapstats.tsv    populations.markers.tsv   ref_map.log
```


* **4b.6. Revisa los logs para evaluar los alineamientos**

Revisa con cuidado los logs en tu direcotorio otuput de `ref_map`. En este caso (`tests.ref/`):

* `ref_map.log` tiene información de cómo corrió toda la pipeline.

* En `populations.log` fíjate especialmente en estas líneas:

```
Removed 0 loci that did not pass sample/population constraints from 330362 loci.
Kept 330362 loci, composed of 216581622 sites; 0 of those sites were filtered, 348618 variant sites remained.
    186290410 genomic sites, of which 27065006 were covered by multiple loci (14.5%).
Mean genotyped sites per locus: 590.92bp (stderr 0.40).

Population summary statistics (more detail in populations.sumstats_summary.tsv):
  Vigo: 3.3003 samples per locus; pi: 0.47627; all/variant/polymorphic sites: 195215923/348618/348618; private alleles: 0
Populations is done.
```

Y **lo más importante de todo** revisa el log `gstacks.log.distribs` pues dice cuántos reads tenía tu muestra (records) y cuántos se mantuvieron (*_kept). Este es un punto clave a comparar entre diferentes alineamientos.

```
BEGIN bam_stats_per_sample
sample  records primary_kept    kept_frac       primary_kept_read2      primary_disc_mapq       primary_disc_sclip      unmapped        secondary       suppl
ementary
Vi02-S100       10744688        8634066 0.804   4329345 1496847 0       613775  0       0
Vi08-P100       6417438 5074913 0.791   2561096 911049  0       431476  0       0
Vi24-P100       12938932        10413078        0.805   5218544 1820624 0       705230  0       0
Vi32-S100       9579944 7766102 0.811   3893076 1290682 0       523160  0       0
END bam_stats_per_sample

BEGIN effective_coverages_per_sample
# For mean_cov_ns, the coverage at each locus is weighted by the number of
# samples present at that locus (i.e. coverage at shared loci counts more).
sample  n_loci  n_used_fw_reads mean_cov        mean_cov_ns     n_unpaired_reads        n_pcr_dupl_pairs        pcr_dupl_rate
Vi02-S100       286525  3540630 12.357  12.868  249487  514604  0.127
Vi08-P100       280003  2040723 7.288   7.507   215005  258089  0.112
Vi24-P100       290994  4247150 14.595  15.325  300542  646842  0.132
Vi32-S100       284062  3183854 11.208  11.618  235697  453475  0.125
END effective_coverages_per_sample

...
```

Al igual que con la pipeline *de novo* compara el número de loci y snps obtenidos. 

Puedes también correr el populations con le filtro `r -0.80` para comparar los resultados con las corridas que hiciste del denovo_map.pl.  

```
mkdir tests.ref/populations.r80

populations -P tests.ref/ -O tests.ref/populations.r80/ -r 0.80 

```

Ya podrán ver el `populations.log`y comparar los resultados de este ensamble con respecto al denovo. 

### Paso 5 Correr Stacks con todas tus muestras

Este paso es esencialmente igual al paso 4, pero con todas tus muestras y los parámetros que elegiste como los mejores. 

Similar a como hicimos con los directorios para las pruebas, si estás trabajando **de novo** el output de tus scripts debes guardarlo en el directorio `/stacks.denovo` y si trabajaste con un **genoma de referencia** debes guardarlo en el directorio `/stacks.ref`. 

### Paso 6 Exporta tus datos con `populations` 

El programa de Stacks [populations](http://catchenlab.life.illinois.edu/stacks/comp/populations.php) te permite:

* Exportar tus datos a otros formatos útiles para análisis filogenéticos o de genética de poblaciones (vcf, plink, phylip, genepop, structure, y otros). 
ls
* calcular *F*st, Pi, *F*is, HWE y otros.

* Repetir los dos puntos anteriores filtrando por loci/individuo 

Recuerda: el principal input de `populations` el el flag `P`, que es **la ruta al directorio** donde están guardados tus resultados de correr `denovo_map` o `ref_map`. Es decir en este tuturial `/stacks.denovo` y `/stacks.ref`.


### Ultimas recomendaciones

* Lee con detenimiento el manual de cada comando de Stacks que corras ¿qué hace cada flag? ¿cuál es el input y el output?

* Cada que corras un comando de Stacks has `ls` en el directorio output y **revisa** cada archivo (apoyándote de la documentación de Stacks). Recuerda que los archivos `.tsv` puedes revisarlos mejor en Excel o Libre Office.

* Levántate de tu silla regularmente y toma agua.

* Lee las recomendaciones y comandos para revisar que cada paso haya corrido correctamente que vienen en Rochette et al.

* **Ajusta Stacks a tus datos** ¿cómo son tus barcodes? ¿secuenciaste single end o pair end? En la documentación viene qué hacer en cada caso, pero debes tenerlo siempre presente. 


## Fin
