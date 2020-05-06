# Práctica Stacks en vivo con datos pequeños

Esta prática de Stacks está basada en:

* El protocolo Rochette, N. C. & Catchen, J. M. Deriving genotypes from RAD-seq short-read data using Stacks. Nature Protocols 12, 2640–2659 (2017).

* Los materiales (datos y scripts) que lo acompañan en: https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/). Pero **utilizando los datos de una sola lane (lane1)**.

* El [Manual de stacks](http://catchenlab.life.illinois.edu/stacks/manual)

* La versión v2.2 de Stacks


**NOTAS IMPORTANTES:** 

1) dependiendo de cómo esté instalado Stacks en tu servidor, quizá tengas que correr los comandos de Stacks con `stacks` antes de cada comando. Por ejemplo: `stacks process_radtags` en vez de `process_radtags`. 

2) Algunos flags dentro de los parámetros de Stacks cambiaron entre la versión que Rochette & Catchen (2017) utilizaron y la actualmente disponible. Por lo tanto los modifiqué.  **El [manual de Stacks](http://catchenlab.life.illinois.edu/stacks/manual/) de la versión que tengas instalada siempre debe de ser tu referencia** de los comandos de Stacks.

3) Los comandos de abajo son ligeramente distintos a los de Rochette debido a las diferencias del punto 2 y a que ajusté las rutas relativas.

4) El tutorial utiliza corre de forma interactiva ("líneas de código en la terminal" en vez de scripts. Pero recuerda que cuadno lo estés utilizando en tu proyecto deberás **hacer tus scripts** y probablemente correrlos en un cluster con un sistema de colas. 

5) Para esta práctica corrí previamente algunos de los pasos que tardan más tiempo.

### Preparar tu espacio en el cluster para esta práctica:

#### Nodo del cluster 

Como los procesos que correremos son algo pesados, para esta práctica **después del ssh con cirio, nos dividiremos en los diferntes nodos del cluster** (normalmente trabajamos solo en en node07). Los nodos en los que trabajaremos serán node02, node04, node07 y node09.

Para esto:

1. En el chat de gitter se te asignará un nodo.

2. Realiza el ssh con cirio como se especifica en el googleclassroom.

3. Si te asignó el node07 **no debes hacer nada más**. 

4. Si se te asignó un nodo **diferente al node07** requerirás hacer lo siguiente: 

`ssh node02` si trabajarás en el node02, o

`ssh node04` si trabajarás en el node04, o 

`ssh node09` si trabajarás en el node09.

(así namás sin password ni nada)

#### Datos

Los datos completos de  Rochette & Catchen (2017) pueden obtenerse como especifico en [La versión con datos completos de este tutorial](./Practica_Stacks_fulldata.md) sin embargo, aquí utilizaremos una versión más pequeña y con alguno de los pasos ya corridos por mí previamente, para ahorrar tiempo.

Estos datos están en el home de nuestro cluster, en un directorio llamado `/stacks_tut_small`.

Copia este directorio al directorio de tu usuario en el cluster:

`cp -r stacks_tut_small tudirectorio`

Ahora entremos al directorio que acabas de copiar y veamos qué contiene:

```
$ cd tudirectorio/stacks_tut_small
$ ls 
README      cleaned       genome  raw            stacks.ref    tests.ref
alignments  demo_scripts  info    stacks.denovo  tests.denovo

```

Esta organizaciónd e directorios es muy limpia, por lo que te recomendamos usar una organización así para tu proyecto.


## ¿Qué va en cada directorio?

* **demo_scripts:** el hogar de los scripts, como el directorio `/bin` o `/source` pues. 

En los datos originales en `/demo_scripts` vienen todos los scripts utilizados, pero en esta práctica no vamos a seguir todos los pasos a detalle, sino una versión simplificada de los pasos principales. Por lo tanto  `/demo_scripts` está vacío, pero durante todo el tutorial **asumimos que demo_scritps es tu wd**

Nota: Si quieres siguir el protocolo de Rochette completo, recomiendo borrar los scripts de `demo_scripts` y utilizar los que están disponibles en línea, pues tienen pequeñas actualizaciones útiles. Pero ojo con tu versión de Stacks.

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
$ cat ../info/barcodes.lane1.tsv 
CTCGCC	sj_1819.35
GACTCT	sj_1819.31
GAGAGA	sj_1819.32
GATCGT	sj_1819.33
GCAGAT	sj_1819.34
GCCGTA	sj_1819.36
GCGACC	sj_1819.37
GCGCTG	sj_1819.38
GCTCAA	sj_1819.39
...
```

Y el [population map](http://catchenlab.life.illinois.edu/stacks/manual/#popmap) describe a qué población corresponde cada muestra:

Estructura:

`<sample name>TAB<population name>`

Ejemplo:

```
$ cat ../info/popmap.tsv 
cs_1335.01	cs
cs_1335.02	cs
cs_1335.03	cs
cs_1335.04	cs
pcr_1193.00	pcr
pcr_1193.01	pcr
```

#### Paso 1) Revisar la calidad de los datos

**Nota** recuerda que asumiremos que estamos en `demo_scripts`

Ver si las secuencias empiezan como lo esperamos según nuestros barcodes y nuestra enzima de restricción. Por ejemplo para los datos del tutorial esperamos un barcode de 6 bases + sitio de corte de SbfI tras la ligación (TGCAGG).

Para una muestra:

```
$ zcat ../raw/lane1/lane1_NoIndex_L001_R1_001.fq.gz | head -n 20
@HWI-ST0747:233:C0RH3ACXX:1:1101:10000:10465 1:N:0:
GGAGCAGAGAGGAGACTAAAGGGGAGCAGAGGGAAGACTAAAGGGGAGCAGAGGGAAGACTAAAGGGGAGCAGAGGAGAGACTAAAGGGGAGCAGAGAGGA
+
CCCFFFFFHHHHHJJJJJJIJJJJIJJGIGIIJ@GHIJJJJJJIJJGHGHHHHFF8BCEEECDDDCDDB@BDDCDBA@BDDDDDDDDDDD-<B?C??9?@8
@HWI-ST0747:233:C0RH3ACXX:1:1101:10000:17644 1:N:0:
TTCCGTTGCAGGGACAGGAGCGCAGGAAATGAGCAGAGGAGGGTTTAACGTACCGGAGGCAGAAGCTGGTTCGACAAAGCGAATGTAAACTGTAAAGCCTC
+
BBBBBBFFHHHHHJJIJJHJJJJJIJIJJJJIJIHIGIIEIJJ;DGGEIHHFFFFDCDD@BBBCDDDDD?A@B<B59CCCDDD7AADDEDCCABDEDCDA<
@HWI-ST0747:233:C0RH3ACXX:1:1101:10000:2461 1:N:0:
TTCTAGTGCAGGTCTCCTGCTACCACCATCCCACCTCTGCAGCTCATTCAGAATGAAGCAGCTCCCCCCGTCTTTTTCCTTCCTACTTTCTCCCTCACTCC

```

Ejemplo de cómo hacerlo para todas las muestras en el script [1.survey_lanes.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/1.survey_lanes.sh)



#### Paso 2) Limpiar y demultiplexear
**Nota:** las muestras que utilizeremos para los pasos siguientes son unas que yo ya demultiplexié previamente, por lo que puedes **no** correr este paso para seguir el tutorial.

Normalmente correras este paso con todas tus muestras, pero aquí vamos a hacerlo solo con unas poquitas muestras de la lane1, más otras muestras de las otras lanes que previamente demutiplexie y que ya deben estar en `clean`. 

Para demultiplexear estas 3 muestras el proceso debe durar al rededor de 5 mins. 

Las pocas muestras que demultiplexearemos están especificadas en `../info/barcodes.lane1_few.tsv`. 

Crear variables con rutas relativas:

```
raw_dir=../raw/lane1/
barcodes_file=../info/barcodes.lane1_few.tsv
out_dir=../cleaned/
```

Correr [process_radtags para demultiplexear](http://catchenlab.life.illinois.edu/stacks/manual/#clean) según tu tipo de barcodes:

```
process_radtags -p $raw_dir -b $barcodes_file -o $out_dir -e sbfI --inline_null -c -q -r 
```

Mientras corre tu terminal debe verse así:

```
Processing single-end data.
Using Phred+33 encoding for quality scores.
Found 10 input file(s).
Searching for single-end, inlined barcodes.
Loaded 24 barcodes (6bp).
Will attempt to recover barcodes with at most 1 mismatches.
Processing file 1 of 10 [lane1_NoIndex_L001_R1_002.fq.gz]
  Processing RAD-Tags...1M...2M...3M...
  3891784 total reads; -327491 ambiguous barcodes; -79841 ambiguous RAD-Tags; +89869 recovered; -354523 low quality reads; 3129929 retained reads.
Processing file 2 of 10 [lane1_NoIndex_L001_R1_007.fq.gz]
  Processing RAD-Tags...1M...2M...3M...
  3906654 total reads; -357482 ambiguous barcodes; -86906 ambiguous RAD-Tags; +120284 recovered; -296963 low quality reads; 3165303 retained reads.
...
```

Puedes ver qué hacen todas las flags en el [manual de process_radtags](http://catchenlab.life.illinois.edu/stacks/comp/process_radtags.php).

Nuestro output al debe generar un archivo `fa.gz` para cada muestra y un archivo `.log` para cada lane:

```
$ ls ../cleaned/
cs_1335.01.fq.gz   process_radtags.lane1.log  sj_1819.31.fq.gz  sj_1819.35.fq.gz
pcr_1193.10.fq.gz  sj_1483.06.fq.gz           sj_1819.32.fq.gz
```

¡El log tiene info muy importante! Nos dice cuántas lecturas de cada muestra se recuperaron, y si no se recuperaron, por qué.

```
$ less ../cleaned/process_radtags.lane1.log 
process_radtags v2.53, executed 2020-05-06 10:14:38 (zlib-1.2.7)
process_radtags -p ../raw/lane1/ -b ../info/barcodes.lane1_few.tsv -o ../cleaned/ -e sbfI --inline_null -c -q -r
File	Retained Reads	Low Quality	Barcode Not Found	RAD cutsite Not Found	Total
lane1_NoIndex_L001_R1_001.fq.gz	231933	25509	3620764	10210	3888416
lane1_NoIndex_L001_R1_002.fq.gz	231091	25254	3625034	10405	3891784
lane1_NoIndex_L001_R1_003.fq.gz	232854	23335	3623293	10451	3889933
lane1_NoIndex_L001_R1_004.fq.gz	235275	21043	3616813	10270	3883401
lane1_NoIndex_L001_R1_005.fq.gz	231903	22296	3636710	10955	3901864
lane1_NoIndex_L001_R1_006.fq.gz	231467	23887	3631191	10496	3897041
lane1_NoIndex_L001_R1_007.fq.gz	233521	21166	3640751	11216	3906654
...
```

Script completo en el protocolo de Rochette: [2.clean_lanes.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/2.clean_lanes.sh). Nota que una parte del script sirve para analizar los logs.


#### Paso 3) Conseguir genoma de referencia

**Nota:** ya corrí este paso previamente, **no debes** hacerlo para seguir el tutorial en vivo ni la tarea (bwa no está instalado en este cluster), pero puedes ver su resultado con  `ls ../genome`.

Si existe genoma de referencia para tu especie. Yey. Si no, sáltate este paso.

Baja el archivo `.fa` o `fa.gz` con el genoma de referencia de tu organismo y guárdalo en `genome`. 

El de Gasterosteus aculeatus de este ejemplo puede bajarse de [ENSEMBL](https://www.ensembl.org/Gasterosteus_aculeatus/Info/Index) con

```
$ wget "ftp://ftp.ensembl.org/pub/release-87/fasta/gasterosteus_aculeatus/dna/Gasterosteus_aculeatus.BROADS1.dna.toplevel.fa.gz" || exit
$ mv Gasterosteus_aculeatus.BROADS1.dna.toplevel.fa.gz ../genome
```

Una vez que lo hayas bajado, crea la bd para el alineamiento:

```
genome_fa=../genome/Gasterosteus_aculeatus.BROADS1.dna.toplevel.fa.gz
mkdir ../genome/bwa
bwa index -p ../genome/bwa/gac $genome_fa > ../genome/bwa/bwa_index

```

Script completo en el protocolo de Rochette: [3.genome_db.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/3.genome_db.sh)


#### Paso 4 Hacer pruebas con un set de datos peque

Correr Stacks, tanto de novo como con genoma de referencia, tarda. Y como tendrás que hacer varias pruebas para ajustar parámetros es buena idea hacer estas pruebas con un subset de los datos. Por ejemplo 10-12 muestras representativias de tus taxa/poblaciones y número de secuencias por muestras.

Escoje estas muestras y ponlas en un population map de prueba que viva en `/info`. En este caso utilizaremos solo 3 muestras  para fines demostrativos. 

Estas ya están seleccionadas (son las mismas que yo ya dejé demultiplexeadas) y están enlistadas en un pop map que se así: 

```
$ cat ../info/popmap.test_samples.tsv
cs_1335.01	cs
pcr_1193.10	pcr
sj_1483.06	sj
```

**NOTA IMPORTANTE:** Si estás siguiendo el protocolo de Mastretta-Yanes et al (2015) utilizando muestras replicadas, este subset de datos deben ser tus muestras replicadas.


#### Paso 4a) Pruebas con ensamble de novo

Script para el paso 4a completo en el protocolo de Rochette: [4.tests_denovo.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/4.tests_denovo.sh)

* **4a.1: Decide cuál de las [estrategias para escoger parámetros de novo utilizarás](http://catchenlab.life.illinois.edu/stacks/manual/#params)** (en realidad ya tomaste esta decisión al hacer tu trabajo de laboratorio).

* **4a.2: Escoge una serie de combinaciones de valores de los [principales parámetros de Stacks de novo](http://catchenlab.life.illinois.edu/stacks/param_tut.php).** 

Normalmente puedes varias M entre 1 y 9, n entre 1 y 5 y m entre 3 y 10 y dejar los otros parámetros fijos. Eg solo varías M y dejas fijos los demás en los defaults.

* **4a.3: Para cada una de estas combinaciones crea un directorio output dentro de `/tests.denovo`.**

Recuerda ponerles nombres relevantes. Puedes usar a nuestros amigos los for loops para esto.

Ejemplo:

```
M_values="1 2 3 "
for M in $M_values ;do
	mkdir -p ../tests.denovo/stacks.M$M
done
```

* **4a.4: Corre el wrapper [denovo_map](http://catchenlab.life.illinois.edu/stacks/comp/denovo_map.php) de stacks, que corre en un solo comando  los [pasos de la pipeline de novo](http://catchenlab.life.illinois.edu/stacks/manual/#phand).**

**Nota:** este es de los pasos que más tardan en correr. Para 3 muestras se tarda al rededor de 35 mins, por lo tanto yo ya corrií este paso y **no** debes correrlo como parte del tutorial en vivo, pero sí para la tarea.

Una vez más aprovecha tu sabiduría de los for loops. Por ejemplo para probar valores de M del 1 al 3 dejando fijo n y m:

(probamos solo tres valores como ejemplo, pero recuerda tu debes probar más)

```
## variables para loop 
M_values="1 2 3"
popmap=../info/popmap.test_samples.tsv

## utilizar loop para construir los flags de `denovo_map`
for M in $M_values ;do
	n=$M
	m=3
	echo "Running Stacks for M=$M, n=$n..."
	reads_dir=../cleaned
	out_dir=../tests.denovo/stacks.M$M
	log_file=$out_dir/denovo_map.oe
	denovo_map.pl --samples $reads_dir -O $popmap -o $out_dir -M $M -n $n -m $m
done
```

**Pregunta** ¿qué hace cada uno de los flags de stacks? 

**Ejercicio que vendrá en la tarea:** modificar el loop anterior **dejando fijo el valor de M** y **variando el valor de n** del 1 al 3.

El ouput dentro de cada uno de tus directorios de resultados se verá parecido a este:

```
$ ls ../tests.denovo/stacks.M1
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
$ less ../tests.denovo/stacks.M1/denovo_map.log 
denovo_map.pl version 2.2 started at 2020-05-04 20:11:32
/usr/lib/stacks/bin/denovo_map.pl --samples ../cleaned -O ../info/popmap.test_samples.tsv -o ../tests.denovo/stacks.M1 -M 1 -n 1 -m 3

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
	stacks_dir=../tests.denovo/stacks.M$M
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
$ ls ../tests.denovo/stacks.M1/populations.r80
```

Son los que empiezan con "populations". Puedes copiarlos del cluster a tu computadora local corriendo esto en **otra terminal donde NO estés conectado al cluster**:

```
scp -P 45789 cirio@200.12.166.164:/persistence/cirio/TUDIRECTORIO/stacks_tut_small/tests.denovo/stacks.M1/populations.r80/populations* ./
```

Donde `TUDIRECTORIO` corresponde al nombre de tu directorio en el cluster, por ejemplo yo corrí:

```
scp -P 45789 cirio@200.12.166.164:/persistence/cirio/aliciamstt/stacks_tut_small/tests.denovo/stacks.M1/populations.r80/populations* ./
```

Con esto los datos se guardarán el wd de la terminal en la que lo hayas corrido. No haré este paso ahorita para ahorrar ancho de banda, pero lo hice previamente. Veamos cada archivo brevemente y qué contienen según [el manual de stacks](http://catchenlab.life.illinois.edu/stacks/manual/#pfiles).


* **4a.6. Compara los outputs**.

La info que queremos está en los archivos output del paso anterior (`populations.r80/populations.log`), y para el método de los replicados además en el archivo plink (para método replicados).

*Método r80*

Te interesa comparar: el % de loci compartido entre el 80% de las muestras, el número de SNPs y el número de loci

Puedes hacer tus propias gráficas, o utilizar los scripts de R de Rochette [4.plot_n_loci.R](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/R_scripts/4.plot_n_loci.R) y [4.plot_n_snps_per_locus.R](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/R_scripts/4.plot_n_snps_per_locus.R). En cualquier forma para esto necesitarás sacar los datos del archivo `populations.r80/populations.log`, de una sección que se ve así:


```
Removed 20595 loci that did not pass sample/population constraints from 57772 loci.
Kept 37177 loci, composed of 3589615 sites; 4023 of those sites were filtered, 65315 variant sites remained.
Mean genotyped sites per locus: 96.55bp (stderr 0.01).*
```

Te dejo un truquito (imo más sencillo que el de Rochette) para extraer esta info de todos los logs con nuestro amigo `sed` y nuestros infalibles loops.

```
mkdir -p ../tests.denovo/results
results_dir=../tests.denovo/results

# create file to save resutls
echo 'M,n,m,n_loci,n_snps' > $results_dir/n_snps_per_locus.tsv

# feed results with a loop
for M in $M_values ;do
	n=$M
	m=3
	log_file=../tests.denovo/stacks.M$M/populations.r80/populations.log

# get number of loci and snps from log file 
n_loci=$(sed -n 's/Kept \(.*\) loci.*/\1/p' $log_file)
n_snps=$(sed -n 's/.*, \([0-9]\{1,\}\) variant .*/\1/p' $log_file)

# echo results and save them to desired file
echo $M,$n,$m,$n_loci,$n_snps >> $results_dir/n_snps_per_locus.tsv
done
```

Veamos los resultados:

```
$ cat ../tests.denovo/results/n_snps_per_locus.tsv 
M,n,m,n_loci,n_snps
1,1,3,35711,19830
2,2,3,36568,27357
3,3,3,36633,30240
```


**Método replicados**

(no se puede hacer con este set de datos ejemplo)

Te interesa comparar: el número de loci y SNPs, % de missing data y valores de error de loci, alelos y SNPs, de los cuales el error en los SNPs es el más importante.

Los scripts para comparar esto puedes obteneros en el repo [RAD-error-rates](https://github.com/AliciaMstt/RAD-error-rates)


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
samples_dir=../tests.ref/alignments.bwa/

# popmap
popmap_file=../info/popmap.test_samples.tsv

# output directory
out_dir=../tests.ref/stacks.bwa/


## Run ref map
ref_map.pl --samples $samples_dir --popmap $popmap_file -o $out_dir 

``` 

Si todo sale bien debes ver algo así mientras corre:

```
Parsed population map: 3 files in 3 populations and 1 group.
Found 3 sample file(s).

Calling variants, genotypes and haplotypes...
  /usr/local/bin/gstacks -I ../tests.ref/alignments.bwa/ -M ../info/popmap.test_samples.tsv -O ../tests.ref/stacks.bwa

Calculating population-level summary statistics
  /usr/local/bin/populations -P ../tests.ref/stacks.bwa -M ../info/popmap.test_samples.tsv

ref_map.pl is done.

```

El output de `ref_map` son estos archivos:

```
$ ls ../tests.ref/stacks.bwa/
catalog.calls  gstacks.log.distribs        populations.log           populations.sumstats.tsv
catalog.fa.gz  populations.haplotypes.tsv  populations.log.distribs  populations.sumstats_summary.tsv
gstacks.log    populations.hapstats.tsv    populations.markers.tsv   ref_map.log
```


* **4b.6. Revisa los logs para evaluar los alineamientos**

Revisa con cuidado los logs en tu direcotorio otuput de `ref_map`. En este caso (`../tests.ref/stacks.bwa/`):

* `ref_map.log` tiene información de cómo corrió toda la pipeline.

* En `populations.log` fíjate especialmente en estas líneas:

```
Removed 0 loci that did not pass sample/population constraints from 46602 loci.
Kept 46602 loci, composed of 4446072 sites; 0 of those sites were filtered, 34697 variant sites remained.
    4332366 genomic sites, of which 111589 were covered by multiple loci (2.6%).
Mean genotyped sites per locus: 95.32bp (stderr 0.01).

Population summary statistics (more detail in populations.sumstats_summary.tsv):
  cs: 1 samples per locus; pi: 0.41001; all/variant/polymorphic sites: 3942761/33875/13889; private alleles: 8300
  pcr: 1 samples per locus; pi: 0.37416; all/variant/polymorphic sites: 4014912/33924/12693; private alleles: 7026
  sj: 1 samples per locus; pi: 0.4015; all/variant/polymorphic sites: 3843216/33357/13393; private alleles: 6576
```

Y **lo más importante de todo** revisa el log `gstacks.log.distribs` pues dice cuántos reads tenía tu muestra (records) y cuántos se mantuvieron (*_kept). Este es un punto clave a comparar entre diferentes alineamientos.

```
# Note: Individual distributions can be extracted using the `stacks-dist-extract` utility.
#       e.g. `stacks-dist-extract gstacks.log.distribs dist_name`

BEGIN bam_stats_per_sample
sample	records	primary_kept	kept_frac	primary_kept_read2	primary_disc_mapq	primary_disc_sclip	unmapped	secondary	supplementary
cs_1335.01	1310138	1083979	0.827	0	153713	26230	38245	7971	0
pcr_1193.10	1540304	1286836	0.835	0	168965	31028	45027	8448	0
sj_1483.06	808591	673792	0.833	0	90957	15884	23674	4284	0
END bam_stats_per_sample

BEGIN effective_coverages_per_sample
# For mean_cov_ns, the coverage at each locus is weighted by the number of
# samples present at that locus (i.e. coverage at shared loci counts more).
sample	n_loci	n_used_fw_reads	mean_cov	mean_cov_ns
cs_1335.01	41334	1083979	26.225	27.149
pcr_1193.10	42097	1286836	30.568	32.120
sj_1483.06	40289	673792	16.724	17.112
END effective_coverages_per_sample

...
```

Al igual que con la pipeline *de novo* compara el número de loci y snps obtenidos. 


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

Lo hiciste muy bien. Te mereces pensar en las maravillas de la evolución viendo este video de [una hydra comiéndose una larva de mosquito](https://youtu.be/SS_HYY97ehw) por haber llegado hasta aquí.  
