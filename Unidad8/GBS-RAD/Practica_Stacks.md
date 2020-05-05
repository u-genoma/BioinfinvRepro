# Práctica Stacks

Esta prática es una versión corta y simplificada del protocolo:

Rochette, N. C. & Catchen, J. M. Deriving genotypes from RAD-seq short-read data using Stacks. Nature Protocols 12, 2640–2659 (2017).

Y en los materiales que lo acompañan en:

[https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/)

Así como de los pasos del [Manual de stacks]()http://catchenlab.life.illinois.edu/stacks/manual.

**NOTAS IMPORTANTES:** 

1) dependiendo de cómo esté instalado Stacks en tu servidor, quizá tengas que correr los comandos de Stacks con `stacks` antes de cada comando. Por ejemplo: `stacks process_radtags` en vez de `process_radtags`. Por eso yo necesité modificar manulamente todos los scripts del demo para agregar `stacks` al principio de cada comando de stacks.

2) Algunos flags dentro de los parámetros de Stacks cambiaron entre la versión que Rochette & Catchen (2017) utilizaron y la actualmente disponible. Por lo tanto **el [manual de Stacks](http://catchenlab.life.illinois.edu/stacks/manual/) de la versión que tengas instalada siempre debe de ser tu referencia** de los comandos de Stacks.


### Obtener los datos del tutorial:

(para la demostración en vivo yo ha hice estos pasos previamente para ahorrar tiempo).

`wget http://catchenlab.life.illinois.edu/data/rochette2017_gac_or.tar.gz`

Descomprimir:

`tar -xzvf rochette2017_gac_or.tar.gz`

Verás que dentro del arhivo descomprimido hay un solo directorio, llamadado **top**. La idea es que esta sea el nombre de tu proyecto, puedes dejarlo con algo genérico como *top* o ponerle el nombre corto de tu proyecto, eg *Juniperus_RAD* 

Dentro folder `top` está la estructura típica de un proyecto de Stacks para analizar datos RADseq:

```
$ cd rochette2017_gac_or/top
$ ls 
README      cleaned       genome  raw            stacks.ref    tests.ref
alignments  demo_scripts  info    stacks.denovo  tests.denovo

```

En esta práctica no vamos a seguir todos los pasos, así que no utilizaremos los scripts de `demo_scripts` sino una versión simplificada de los pasos principales. 

Si quieres hacerlo todo completo siguiendo el protocolo recomiendo borrar los scripts de `demo_scripts` y utilizar los que están disponibles en línea, pues tienen pequeñas actualizaciones útiles (puedes bajarlos todos con `wget https://bitbucket.org/rochette/rad-seq-genotyping-demo/get/c22c0c66b8fd.zip`) 



## ¿Qué va en cada direcotorio?

* **raw:** aquí van tus secuencias `.fq.gz` crudas, tal cual salidas del secuenciador. (paso 0)

* **cleaned:** aquí van tus secuencias después de hacer un análisis de calidad, limpiarlas y demultiplexearlas. (pasos 1 y 2). Alternativamente puedes tener un directorio `cleaned` y otro `samples` para las lecturas limpias y demultiplexeadas, respectivamente, si haces estos pasos por separado.

* **genome:** aquí vivirá tu genoma de referencia. (paso 3). Este directorio solo existe si corres stacks con genoma de referencia.

* **tests.denovo** aquí van los resultados de tus (varias) pruebas de ensamblado de novo con algunas pocas muestras (paso 4a)

* **stacks.denovo:** aquí van los resultados del ensamblado de novo con los parámetros que elegiste (paso 5a)

* **aligments:** aquí va el resultado de alinear las secuencias de tus muestras vs el genoma de referencia. Este directorio solo existe si corres stacks con genoma de referencia.

* **stacks.ref:** aquí va el resultado de llamar los genotipos 




Vamos a ver paso por paso la pipeline para llegar a eso con los scripts del demo, que están en:

[https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/)

y siguiendo el pdf del protocolo (en los documentos de google class) y la información de cada comando en el [manual de Stacks](http://catchenlab.life.illinois.edu/stacks/manual/#pipe).

#### Preparar input
El paso 0 de la pipeline es poner nuestras secuencias en `/raw`, y los barcodes y population map en `info`. Los barcodes deben estar en un archivo que se vea así:

`<barcode>TAB<sample name>`

Por ejemplo: 

```
$ cat info/barcodes.lane1.tsv 
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

El population map describe a qué población corresponde cada muestra:

Estructura:

`<sample name>TAB<population name>`

Ejemplo:

```
$ cat info/popmap.tsv 
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

Ejemplo de cómo hacerlo para todas las muestras:

[1.survey_lanes.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/1.survey_lanes.sh)



#### Paso 2) Limpiar y demultiplexear

Nota: Recuerda dependiendo de cómo esté instalado Stacks en tu servidor, quizá tengas que correr los comandos de Stacks con `stacks` antes de cada comando.

Crear variables con rutas relativas:

```
raw_dir=../raw/lane1/barcodes_file=../info/barcodes.lane1.tsv
out_dir=../cleaned/
```

Correr [process_radtags para demultiplexear](http://catchenlab.life.illinois.edu/stacks/manual/#clean) según tu tipo de barcodes:

```
$ stacks process_radtags -p $raw_dir -b $barcodes_file -o $out_dir -e sbfI --inline_null -c -q -r 
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
cs_1335.01.fq.gz  cs_1335.15.fq.gz   pcr_1211.02.fq.gz          process_radtags.lane2.oe   sj_1484.06.fq.gz  wc_1218.05.fq.gz
cs_1335.02.fq.gz  cs_1335.16.fq.gz   pcr_1211.03.fq.gz          process_radtags.lane3.log  sj_1484.07.fq.gz  wc_1218.06.fq.gz
cs_1335.03.fq.gz  cs_1335.17.fq.gz   pcr_1211.04.fq.gz          process_radtags.lane3.oe   sj_1819.31.fq.gz  wc_1218.07.fq.gz
cs_1335.04.fq.gz  cs_1335.19.fq.gz   pcr_1211.05.fq.gz          sj_1483.01.fq.gz           sj_1819.32.fq.gz  wc_1219.01.fq.gz
cs_1335.05.fq.gz  pcr_1193.00.fq.gz  pcr_1211.06.fq.gz          sj_1483.02.fq.gz           sj_1819.33.fq.gz  wc_1219.02.fq.gz
cs_1335.06.fq.gz  pcr_1193.01.fq.gz  pcr_1211.07.fq.gz          sj_1483.03.fq.gz           sj_1819.34.fq.gz  wc_1219.04.fq.gz
cs_1335.07.fq.gz  pcr_1193.02.fq.gz  pcr_1211.08.fq.gz          sj_1483.04.fq.gz           sj_1819.35.fq.gz  wc_1219.05.fq.gz
cs_1335.08.fq.gz  pcr_1193.08.fq.gz  pcr_1211.09.fq.gz          sj_1483.05.fq.gz           sj_1819.36.fq.gz  wc_1220.01.fq.gz
cs_1335.09.fq.gz  pcr_1193.09.fq.gz  pcr_1211.10.fq.gz          sj_1483.06.fq.gz           sj_1819.37.fq.gz  wc_1220.02.fq.gz
cs_1335.10.fq.gz  pcr_1193.10.fq.gz  pcr_1211.11.fq.gz          sj_1484.01.fq.gz           sj_1819.38.fq.gz  wc_1220.03.fq.gz
cs_1335.11.fq.gz  pcr_1193.11.fq.gz  pcr_1213.02.fq.gz          sj_1484.02.fq.gz           sj_1819.39.fq.gz  wc_1221.01.fq.gz
cs_1335.12.fq.gz  pcr_1193.12.fq.gz  process_radtags.lane1.log  sj_1484.03.fq.gz           sj_1819.40.fq.gz  wc_1221.02.fq.gz
cs_1335.13.fq.gz  pcr_1210.05.fq.gz  process_radtags.lane1.oe   sj_1484.04.fq.gz           sj_1819.41.fq.gz  wc_1221.04.fq.gz
cs_1335.14.fq.gz  pcr_1211.01.fq.gz  process_radtags.lane2.log  sj_1484.05.fq.gz           wc_1218.04.fq.gz  wc_1222.02.fq.gz
```

¡El log tiene info muy importante! Nos dice cuántas lecturas de cada muestra se recuperaron, y si no se recuperaron, por qué.

```
$ less ../cleaned/process_radtags.lane1.log 

process_radtags v2.2, executed 2020-05-04 17:41:50
/usr/lib/stacks/bin/process_radtags -p ../raw/lane1/ -b ../info/barcodes.lane1.tsv -o ../cleaned/ -e sbfI --inline_null -c -q -r
File    Retained Reads  Low Quality     Barcode Not Found       RAD cutsite Not Found   Total
lane1_NoIndex_L001_R1_001.fq.gz 3136039 352260  321836  78281   3888416
lane1_NoIndex_L001_R1_002.fq.gz 3129929 354523  327491  79841   3891784
lane1_NoIndex_L001_R1_003.fq.gz 3152587 329947  326572  80827   3889933
lane1_NoIndex_L001_R1_004.fq.gz 3195170 292073  317415  78743   3883401
lane1_NoIndex_L001_R1_005.fq.gz 3152970 313188  350822  84884   3901864
lane1_NoIndex_L001_R1_006.fq.gz 3140862 341788  332094  82297   3897041
lane1_NoIndex_L001_R1_007.fq.gz 3165303 296963  357482  86906   3906654
lane1_NoIndex_L001_R1_008.fq.gz 3175402 309017  322006  80990   3887415
lane1_NoIndex_L001_R1_009.fq.gz 3167011 318301  324280  80895   3890487
lane1_NoIndex_L001_R1_010.fq.gz 452235  54472   47744   12124   566575

Total Sequences 35603570
Barcode Not Found       3027742
Low Quality     2962532
RAD Cutsite Not Found   745788
Retained Reads  28867508

Barcode Filename        Total   NoRadTag        LowQuality      Retained
CTCGCC  sj_1819.35      1346898 30273   118707  1197918
GACTCT  sj_1819.31      26185   25574   163     448
GAGAGA  sj_1819.32      1061822 40347   91021   930454
GATCGT  sj_1819.33      1306694 28929   122723  1155042
GCAGAT  sj_1819.34      982500  34682   84821   862997
GCCGTA  sj_1819.36      1180712 24784   108070  1047858
GCGACC  sj_1819.37      977166  18061   85919   873186
GCGCTG  sj_1819.38      1540755 40369   137439  1362947

```

Script completo en el protocolo de Rochette: [2.clean_lanes.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/2.clean_lanes.sh). Nota que una parte del script sirve para analizar los logs.


#### Paso 3) Conseguir genoma de referencia

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
bwa index -p bwa/gac $genome_fa &> ../genome/bwa/bwa_index.oe

```

Script completo en el protocolo de Rochette: [3.genome_db.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/3.genome_db.sh)


#### Paso 4 Hacer pruebas con un set de datos peque

Correr Stacks, tanto de novo como con genoma de referencia, tarda. Y como tendrás que hacer varias pruebas para ajustar parámetros es buena idea hacer estas pruebas con un subset de los datos. Por ejemplo 10-12 muestras representativias de tus taxa/poblaciones y número de secuencias por muestras.

Escoje estas muestras y ponlas en un population map de prueba:

```
$ cat ../info/popmap.test_samples.tsv
cs_1335.01	cs
cs_1335.13	cs
cs_1335.15	cs
pcr_1193.10	pcr
pcr_1193.11	pcr
pcr_1211.04	pcr
sj_1483.06	sj
sj_1484.07	sj
sj_1819.36	sj
wc_1218.04	wc
wc_1221.01	wc
wc_1222.02	wc
```

**Si estás siguiendo el protocolo de Mastretta-Yanes et al (2015) utilizando muestras replicadas, este subset de datos deben ser tus muestras replicadas.**


##### Paso 4a) Pruebas con ensamble de novo

Script para el paso 4a completo en el protocolo de Rochette: [4.tests_denovo.sh](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/4.tests_denovo.sh)

* 4a.1: Decide cuál de las [estrategias para escoger parámetros de novo utilizarás](http://catchenlab.life.illinois.edu/stacks/manual/#params). (en realidad ya tomaste esta decisión al hacer tu trabajo de laboratorio)

* 4a.2: Escoge una serie de combinaciones de valores de los [principales parámetros de Stacks de novo](http://catchenlab.life.illinois.edu/stacks/param_tut.php). 

* 4a.3: Para cada una de estas combinaciones crea un directorio output dentro de `/tests.denovo`. Recuerda ponerles nombres relevantes. Puedes usar a nuestros amigos los for loops para esto.

Ejemplo:

```
$ M_values="1 2 3 4 5 6 7 8 9"
$ for M in $M_values ;do
	mkdir ../tests.denovo/stacks.M$M
done
```

* 4a.4: Corre el wrapper [denovo_map](http://catchenlab.life.illinois.edu/stacks/comp/denovo_map.php) de stacks, que corre en un solo comando  los [pasos de la pipeline de novo](http://catchenlab.life.illinois.edu/stacks/manual/#phand).

**Nota:** este es de los pasos que más tardan en correr.

Una vez más aprovecha tu sabiduría de los for loops:

```
popmap=../info/popmap.test_samples.tsv
for M in $M_values ;do
	n=$M
	m=3
	echo "Running Stacks for M=$M, n=$n..."
	reads_dir=../cleaned
	out_dir=../tests.denovo/stacks.M$M
	log_file=$out_dir/denovo_map.oe
	stacks denovo_map.pl --samples $reads_dir -O $popmap -o $out_dir -M $M -n $n -m $m
done
```

**Pregunta** ¿qué hace cada uno de los flags de stacks? 

Tu output se verá así:

```
$ ls ../tests.denovo/stacks.M1
catalog.alleles.tsv.gz     cs_1335.15.tags.tsv.gz      populations.haplotypes.tsv        sj_1819.36.matches.tsv.gz
catalog.calls              denovo_map.log              populations.hapstats.tsv          sj_1819.36.snps.tsv.gz
catalog.fa.gz              gstacks.log                 populations.log                   sj_1819.36.tags.tsv.gz
catalog.snps.tsv.gz        gstacks.log.distribs        populations.log.distribs          tsv2bam.log
catalog.tags.tsv.gz        pcr_1193.10.alleles.tsv.gz  populations.markers.tsv           wc_1218.04.alleles.tsv.gz
cs_1335.01.alleles.tsv.gz  pcr_1193.10.matches.bam     populations.sumstats.tsv          wc_1218.04.matches.bam
cs_1335.01.matches.bam     pcr_1193.10.matches.tsv.gz  populations.sumstats_summary.tsv  wc_1218.04.matches.tsv.gz
cs_1335.01.matches.tsv.gz  pcr_1193.10.snps.tsv.gz     sj_1483.06.alleles.tsv.gz         wc_1218.04.snps.tsv.gz
cs_1335.01.snps.tsv.gz     pcr_1193.10.tags.tsv.gz     sj_1483.06.matches.bam            wc_1218.04.tags.tsv.gz
cs_1335.01.tags.tsv.gz     pcr_1193.11.alleles.tsv.gz  sj_1483.06.matches.tsv.gz         wc_1221.01.alleles.tsv.gz
cs_1335.13.alleles.tsv.gz  pcr_1193.11.matches.bam     sj_1483.06.snps.tsv.gz            wc_1221.01.matches.bam
cs_1335.13.matches.bam     pcr_1193.11.matches.tsv.gz  sj_1483.06.tags.tsv.gz            wc_1221.01.matches.tsv.gz
cs_1335.13.matches.tsv.gz  pcr_1193.11.snps.tsv.gz     sj_1484.07.alleles.tsv.gz         wc_1221.01.snps.tsv.gz
cs_1335.13.snps.tsv.gz     pcr_1193.11.tags.tsv.gz     sj_1484.07.matches.bam            wc_1221.01.tags.tsv.gz
cs_1335.13.tags.tsv.gz     pcr_1211.04.alleles.tsv.gz  sj_1484.07.matches.tsv.gz         wc_1222.02.alleles.tsv.gz
cs_1335.15.alleles.tsv.gz  pcr_1211.04.matches.bam     sj_1484.07.snps.tsv.gz            wc_1222.02.matches.bam
cs_1335.15.matches.bam     pcr_1211.04.matches.tsv.gz  sj_1484.07.tags.tsv.gz            wc_1222.02.matches.tsv.gz
cs_1335.15.matches.tsv.gz  pcr_1211.04.snps.tsv.gz     sj_1819.36.alleles.tsv.gz         wc_1222.02.snps.tsv.gz
cs_1335.15.snps.tsv.gz     pcr_1211.04.tags.tsv.gz     sj_1819.36.matches.bam            wc_1222.02.tags.tsv.gz
```

Y no olvides que los logs están lleno de información preciada

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
  
**Nota:** este paso corre rápido.

Si estás siguiendo el método r80 (Paris et al 2017), filtra los loci que solo estén en al menos el 80% de tus muestras:

```
$ for M in $M_values ;do
	stacks_dir=../tests.denovo/stacks.M$M
	out_dir=$stacks_dir/populations.r80
	mkdir $out_dir
	log_file=$out_dir/populations.oe
	stacks populations -P $stacks_dir -O $out_dir -r 0.80
done

```

Si estás siguiendo el protocolo de replicados (Mastretta-Yanes et al 2015) puedes exportar todos los loci, o hacer un filtro como el de arriba. 

IMPORTANTE: Necesitarás además exportar los datos a plink, agregando el flag `--plink`.

```
$ stacks populations -P $stacks_dir -O $out_dir -r 0.80 --plink
```

* 4a.6. Compara los outputs.

La info que queremos está en los archivos output del paso anterior (`populations.r80/batch_1.populations.log`) y plink (para info replicados).

**Método r80**

Te interesa comparar: el % de loci compartido entre el 80% de las muestras, el número de SNPs por loci y el número de loci

Puedes hacer tus propias gráficas, o utilizar los scripts de R de Rochette [4.plot_n_loci.R](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/R_scripts/4.plot_n_loci.R) y [4.plot_n_snps_per_locus.R](https://bitbucket.org/rochette/rad-seq-genotyping-demo/src/default/demo_scripts/R_scripts/4.plot_n_snps_per_locus.R)   


**Método replicados**

Te interesa comparar: el número de loci y SNPs, % de missing data y valores de error de loci, alelos y SNPs, de los cuales el error en los SNPs es el más importante.

(no se puede hacer con este set de datos ejemplo)

Los scripts para comparar esto puedes obteneros en el repo [RAD-error-rates](https://github.com/AliciaMstt/RAD-error-rates)

##### Paso 4b) Pruebas con genoma de referencia


Script completo en el protocolo de Rochette: []()
Script completo en el protocolo de Rochette: []()
Script completo en el protocolo de Rochette: []()
Script completo en el protocolo de Rochette: []()
Script completo en el protocolo de Rochette: []()
Script completo en el protocolo de Rochette: []()