# Tutorial Sarek

Incluye scripts germinal y somático y tarea al final.

## Activación del ambiente de sarek

```
pyenv activate sarek_taller-pyenv
```

## Directorio de trabajo

Te recomendamos crear una carpeta de trabajo que tenga subdirectorios con los datos de input y la salida del pipeline sarek. 

```
# Crear directorio de trabajo
mkdir pipeline_sarek

# Dentro del directorio pipeline_sarek crear carpeta data
# (esto solo se sugiere para mantener un orden, pero no es requisito. Si
# estás ejecutando el tutorial en el servidor genoma, no copies los archivos,
# léelos desde su original ubicación)

cd pipeline_sarek

mkdir data

# Además debes crear carpeta code. Ahí tienes que almacenar los script sarek_germinal.sh y sarek_somatic.sh

mkdir code

# Crear directorio de salida del pipeline (acá se almacenará los resultados del pipeline)
mkdir results
```

## Scripts

Te presentamos un script para ejecutar el pipeline sarek para datos germinales.

A continuación te mostramos en qué consiste el script `sarek_germinal.sh`. El llamador de variantes que debes usar para variantes germinales es haplotypecaller.

Entra al directorio `code` 

```
cd code
```

Luego, con un editor de texto ,por ej. nano, crear un archivo bash para ejecutar el modo germinal de sarek:

```
#!/bin/bash
# Ejecuta nf-core/sarek en modo GERMINAL para una sola muestra (normal/germinal).
# Uso:
#   A) Nombre de muestra automático (recomendado para alumnos):
#        bash sarek_germinal.sh R1.fastq.gz R2.fastq.gz /ruta/output
#   B) Nombre de muestra explícito:
#        bash sarek_germinal.sh R1.fastq.gz R2.fastq.gz /ruta/output nombre_muestra
#
# El script crea internamente un samplesheet CSV como requiere nf-core/sarek
# y luego llama a:
#   nextflow run nf-core/sarek --input samplesheet.csv ...

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Uso: bash sarek_germinal.sh R1.fastq.gz R2.fastq.gz /ruta/output [nombre_muestra]"
    exit 1
fi

R1=$1
R2=$2
OUT=$3

mkdir -p "$OUT"

# Si se entrega un cuarto argumento, se usa como nombre de muestra
if [ "$#" -eq 4 ]; then
    SAMPLE=$4
else
    # Detección automática del nombre de muestra desde R1
    base=$(basename "$R1")

    # Elimina sufijos comunes de R1
    sample=${base%%_R1.fastq.gz}
    sample=${sample%%_R1.fq.gz}
    sample=${sample%%_1.fastq.gz}
    sample=${sample%%_1.fq.gz}
    sample=${sample%%.fastq.gz}
    sample=${sample%%.fq.gz}

    SAMPLE=$sample
    echo "Detectado nombre de muestra automáticamente: ${SAMPLE}"
fi

# Intentar obtener rutas absolutas (si readlink -f está disponible)
if command -v readlink >/dev/null 2>&1; then
    R1_ABS=$(readlink -f "$R1")
    R2_ABS=$(readlink -f "$R2")
else
    R1_ABS="$R1"
    R2_ABS="$R2"
fi

SHEET="${OUT}/samplesheet_germline_${SAMPLE}.csv"

echo "Creando samplesheet: $SHEET"
cat > "$SHEET" <<EOF
patient,sex,status,sample,lane,fastq_1,fastq_2
${SAMPLE},NA,0,${SAMPLE},L1,${R1_ABS},${R2_ABS}
EOF

echo "Lanzando nf-core/sarek en modo germinal..."
nextflow run nf-core/sarek \
    --input "$SHEET" \
    --genome GATK.GRCh38 \
    --outdir "$OUT" \
    --tools haplotypecaller \
    -profile singularity \
      -c /home/bioinfo1/korostica/test_tutorial/code/local_sarek_8cpus.config \
    -resume 
```

A continuación te mostramos en qué consiste el script `sarek_somatic.sh`. El llamador de variantes que debes utilizar es mutect2.

```
#!/bin/bash
# Ejecuta nf-core/sarek en modo SOMÁTICO (tumor-only).
# Uso:
#   A) Nombre de muestra automático:
#        bash sarek_somatic.sh R1.fastq.gz R2.fastq.gz /ruta/output
#   B) Nombre de muestra explícito:
#        bash sarek_somatic.sh R1.fastq.gz R2.fastq.gz /ruta/output nombre_muestra
#
# El script crea internamente un samplesheet CSV como requiere nf-core/sarek.

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Uso: bash sarek_somatic.sh R1.fastq.gz R2.fastq.gz /ruta/output [nombre_muestra]"
    exit 1
fi

R1=$1
R2=$2
OUT=$3

mkdir -p "$OUT"

# Si se entrega un cuarto argumento, se usa como nombre de muestra
if [ "$#" -eq 4 ]; then
    SAMPLE=$4
else
    base=$(basename "$R1")

    sample=${base%%_R1.fastq.gz}
    sample=${sample%%_R1.fq.gz}
    sample=${sample%%_1.fastq.gz}
    sample=${sample%%_1.fq.gz}
    sample=${sample%%.fastq.gz}
    sample=${sample%%.fq.gz}

    SAMPLE=$sample
    echo "Detectado nombre de muestra automáticamente: ${SAMPLE}"
fi

# Rutas absolutas
if command -v readlink >/dev/null 2>&1; then
    R1_ABS=$(readlink -f "$R1")
    R2_ABS=$(readlink -f "$R2")
else
    R1_ABS="$R1"
    R2_ABS="$R2"
fi

SHEET="${OUT}/samplesheet_somatic_${SAMPLE}.csv"

echo "Creando samplesheet: $SHEET"
cat > "$SHEET" <<EOF
patient,sex,status,sample,lane,fastq_1,fastq_2
${SAMPLE},NA,1,${SAMPLE},L1,${R1_ABS},${R2_ABS}
EOF

echo "Lanzando nf-core/sarek en modo somático (tumor-only)..."
nextflow run nf-core/sarek \
    --input "$SHEET" \
    --genome GATK.GRCh38 \
    --outdir "$OUT" \
    --tools mutect2 \
    -profile singularity \
    -c /home/bioinfo1/korostica/test_tutorial/code/local_sarek_8cpus.config \
    -resume 
```

Los dos script son capaces de:

* Detecta nombre_muestra desde R1 si no se lo das

* Crea samplesheet_germline_<muestra>.csv en el outdir

* Llama a Sarek con ese CSV

Debemos crear un archivo de configuración para indicarle a nextflow la capacidad de memoria que debe utilizar. Para esto creamos el archivo `local_sarek_8cpus.config` que debe estar en el directorio `code`.

```
// Config local para correr Sarek en un servidor con 16 CPUs

executor {
    name = 'local'
    cpus = 16      // lo que realmente tiene tu maquina
}

// Limite global: ningun proceso puede usar mas de 8 CPUs
process {
    resourceLimits = [ cpu: 8 ]
}

// (opcional, pero mas explicito)
// Forzar especificamente el proceso de alineamiento BWAMEM1_MEM a 8 CPUs
process {
    withName: 'NFCORE_SAREK:SAREK:FASTQ_PREPROCESS_GATK:FASTQ_ALIGN:BWAMEM1_MEM' {
        cpus = 8
    }
}
```

## Asignar permisos de ejecución

Una vez que se haya creado ambos script debes darles permisos de ejecución.

```
# Estando dentro del directorio code
chmod +x sarek_germinal.sh
chmod +x sarek_somatic.sh
```

## Ejecución

Para correr ambos scripts debes ejecutar el siguiente código entregando como parámetro la ruta del read 1 y read 2 y el directorio de salida. Reemplaza los nombres de archivos de acuerdo a lo necesario.

El script germinal se ejecuta de la siguiente forma:

```
bash sarek_germinal.sh ../data/SRR1663550_1.fastq.gz ../data/SRR1663550_2.fastq.gz ../results
```

El script Somático se ejecuta de la siguiente forma:

```
bash sarek_somatic.sh  ../data/SRR1663550_1.fastq.gz ../data/SRR1663550_2.fastq.gz ../results
```

Nota: muestre los comandos usados y desde qué directorio se ejecutaron en su informe.

---

## Trabajo práctico: Análisis germinal y somático con nf-core/sarek + interpretación en OncoKB y gnomAD

### 1. Objetivos de la actividad

En este trabajo práctico aplicarás el pipeline **nf-core/sarek** para:

1. Ejecutar un **análisis germinal** (variantes constitucionales) a partir de un FASTQ.
2. Ejecutar un **análisis somático** (variantes adquiridas en el tumor) usando la misma muestra tumoral.
3. Comparar cuantitativamente los resultados germinales vs somáticos.
4. Realizar una **búsqueda e interpretación de variantes** usando:
   - **OncoKB** (base de conocimiento oncológica somática).
   - **gnomAD** (frecuencias poblacionales germinales).
5. Elaborar un **informe corto** discutiendo las diferencias observadas y la posible relevancia biológica/clínica de las variantes seleccionadas obtenidas a apartir del análisis germinal versus el somático.

---

### 2. Datos y recursos

- Conjunto de datos (FASTQ) **Cada estudiante analizará su muestra**.
- Pipeline: **nf-core/sarek** (versión indicada en el tutorial).
- Recursos online:
  - https://www.oncokb.org
  - https://gnomad.broadinstitute.org

---

### 3. Análisis germinal y somático con sarek

#### 3.1. Ejecución del pipeline germinal

1. Ejecutar **sarek** en modo germinal sobre la muestra provista.
   Comando sugerido (recuerde dar el nombre de sus muestras y su ruta correspondiente):
   
   ```
   bash sarek_germinal.sh ../data/R1.fastq.gz ../data/R2.fastq.gz ../results
   ```

#### 3.2. Resultados esperados

- revisar VCF de variantes germinales y somáticas detectadas
- Reportes de calidad (MultiQC).

#### 3.3. Selección de variantes germinales

- Filtrar 10–20 variantes no sinónimas o con impacto moderado/alto.

---

### 4. Análisis somático con sarek

#### 4.1. Ejecución del pipeline somático

  Comando sugerido(recuerde dar el nombre de sus muestras y su ruta correspondiente)

```
 bash sarek_somatic.sh  ../data/R1.fastq.gz ../data/R2.fastq.gz ../results
```

#### 4.2. Resultados esperados

- VCF de variantes somáticas.
- MultiQC y métricas del pipeline.

#### 4.3. Selección de variantes somáticas

- Filtrar 10–20 variantes no sinónimas, preferentemente en genes de cáncer.

---

### 5. Comparación germinal vs somático

Comparar:

- Número total de variantes.
- Distribución de tipos (missense, nonsense, indels).
- Variantes compartidas.
- Implicancias biológicas y clínicas.

---

### 6. Búsqueda en OncoKB y gnomAD

#### 6.1. Somáticas → OncoKB

Registrar:

- Nivel de evidencia.
- Oncogenicidad.
- Cánceres asociados.
- Información terapéutica (si existe).

#### 6.2. Germinales → gnomAD

Registrar:

- Frecuencia global y por población.
- Rareza de la variante.

---

### 7. Informe final

Debe incluir:

- Introducción breve.
- Metodología (explique lo realizado, con qué software y muestre los comandos usados y desde qué directorio se ejecutaron)
- Resultados germinales y somáticos.
- Comparación en tablas y/o gráficos.
- Tablas de OncoKB y gnomAD.
- Discusión y conclusiones.

---

### 8. Entrega

- Informe en Markdown en su github.
- Carpetas con VCF filtrados y scripts utilizados en el repositorio de github.

---

### 9. Evaluación

- Ejecución del pipeline – 30%
- Comparación germinal vs somático – 25%
- Uso de OncoKB y gnomAD – 25%
- Calidad del informe – 20%
