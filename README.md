# Introducción a la bioinformática e investigación reproducible para análisis genómicos

<!--[![Gitter](https://badges.gitter.im/ugenoma/Bioinfo2020.svg)](https://gitter.im/ugenoma/Bioinfo2020?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)-->

Mediante una colaboración entre el Posgrado en Ciencias Biológicas de la Universidad Nacional Autónoma de México, CONABIO y la U. de Chile, ofreceremos un curso intensivo de bioinformática, orientado a entregar las herramientas básicas para análisis de datos genómicos en el contexto de genética, especialmente la genética de poblaciones.

INSTRUCTORES ENCARGADOS:
**Dra. Alicia Mastretta Yanes, PhD.** (México)
Catedrática CONACYT-CONABIO,
[www.mastrettayanes-lab.org](www.mastrettayanes-lab.org)

**Dr. Ricardo Verdugo Salgado, PhD** (Chile)
Profesor Asistente, Programa de Genética Humana, ICBM, Facultad de Medicina, Universidad de Chile [http://genomed.med.uchile.cl](http://genomed.med.uchile.cl)

INSTRUCTURES PARTICIPANTES:

**Karen Oróstica Tapia, PhD.**
Investigadora Docente, Insitituto de Ciencia de Datos, Universidad del Desarrollo
[https://ingenieria.udd.cl/persona/karen-orostica](https://ingenieria.udd.cl/persona/karen-orostica)

**Constanza de la Fuente, PhD.**
Programa de Genética Humana, ICBM, Facultad de Medicina, Universidad de Chile
[https://orcid.org/0000-0002-2857-3615](https://orcid.org/0000-0002-2857-3615)

INSTRUCTORES de versiones pasadas:

**Dra. Camille Truong, PhD**.
Investigadora Instituto de Biología, UNAM
[camilletruong.wixsite.com](https://camilletruong.wixsite.com/home#!)

**Dr. Matthieu J. Miossec, PhD**
Bioinformatics Analyst, Wellcome Centre for Human Genetics de la Universidad de Oxford
[https://www.researchgate.net/profile/Matthieu-Miossec](https://www.researchgate.net/profile/Matthieu-Miossec)

**Dr. Luis Castañeda, PhD**
Profesor Asistente, Programa de Genética Humana, ICBM, Facultad de Medicina, Universidad de Chile
[https://sites.google.com/site/lecastane/](https://sites.google.com/site/lecastane/)

**Dr. Pablo Saenz Agudelo**
Profesor Asociado, Instituto de Ciencias Ambientales y Evolutivas, Facultad de Ciencias, Universidad Austral de Chile
[http://icaev.cl/academicos/pablo-saenz-agudelo/](http://icaev.cl/academicos/pablo-saenz-agudelo/)

Los materiales aquí presentados son de acceso libre. La transmisión online y videos de clases se pueden encontrar en [este canal de Youtube](https://www.youtube.com/channel/UCqrgi3eXb3J51QMO0LQrgOA)

<!--Sala de chat para **anuncios de la clase** y dudas si lo estás viendo remotamente: [en Gitter](https://gitter.im/Bioinfo_Mx-Cl/community)-->

## Objetivos

El **objetivo general es** brindar a los y las alumnas las herramientas computacionales de software libre, mejores prácticas y metodologías de reproducibilidad de la ciencia para efectuar, documentar y publicar proyectos bioinformáticos de análisis genómicos.

Los **objetivos particulares** son:

1. Formar a los y las alumnas en los principios de investigación reproducible y metodologías para organizar proyectos bioinformáticos
2. Introducir a los alumnos a bash, R y git
3. Presentar a los alumnos los tipos de datos genéticos producidos por la secuenciación de siguiente generación
4. Introducir a los y las alumnas al análisis e datos genómicos y genomas reducidos
5. Revisar  a  nivel teórico y  práctico los  métodos  bioinformáticos  clásicos  de  análisis secuencias genómicas
6. Asesorar a los alumnos en la realización de sus propios proyectos bioinformáticos

### Que sí es este curso

* Una introducción a los métodos y mejores prácticas de la biología computacional, los análisis bioinformáticos y la ciencia reproducible.
* Un resumen general de los tipos de datos utilizados en genómica y las herramientas computacionales para analizarlos.
* Una introducción para saber utilizar la línea de comandos y R de forma fluida a través de mucha práctica. **Muchos cursos enfocados en análisis de datos genómicos asumen que ya sabes esto, o dan una introducción flash y luego saltan al otro tema, lo que hace  _muy difícil_ realmente aprovechar el otro tema o te deja con malas prácticas difíciles de borrar.**
* El lenguaje para aprender a entender los manuales de cualquier software bioinformático para poder utilizarlo a fondo por cuenta propia.
* Un curso con mucha práctica de R enfocado en ciencia reproducible, limpieza y gráfica de datos biológicos y genéticos.
* El piso básico para poder tomar un curso más avanzado o adentrarse por uno mismo en algún análisis concreto (ensamblado de genomas, análisis transcriptómicos, filogenética con métodos bayesianos, etc).

### Que NO es este curso

* La respuesta a lo que tienes que hacer en tu proyecto de tesis.
* Una discusión profunda de los diferentes programas para analizar datos GBS, RAD, genomas, transcriptomas, metabarcoding, etc.

En otras palabras, en este curso no te vamos a decir qué programa utilizar ni discutir a profundidad métodos de ensamblado, etc. Para eso hay cursos especializados intensivos de un par de días que asumen ya saben usar la terminal.

Algunos ejemplos:

* [Curso Bioinformática Instituto de Biotecnología, Cuernavaca](http://uusmd.unam.mx/curso/).
* [Talleres Internacionales de Genómica del Centro de Ciencias Genómicas, Cuernavaca](http://congresos.nnb.unam.mx/TIB2017/)

## Dinámica del curso

### ¿Cómo serán las clases?

* Exposición + ejercicos y ejemplos en clase

* Todos los materiales de la clase los iremos subiendo/actualizando a GitHub conforme avance el semestre

* Dejaremos **lecturas** a casa antes o después de algunos temas. Es una muy buena idea sí leerlas.

* Ocuparemos Google Classroom para enviar tareas y hacer anuncios del curso. Debes recibir una invitación a tu correo.

* **¿Necesito una computadora?**

El curso es teórico-práctico, por lo que se requiere traigan su laptop con Mac o GNU/Linux (**no** Windows, sorry, lo intenté 2 años y es una pesadilla para todxs) y:

- [Docker](https://www.docker.com/) instalado y **FUNCIONANDO** (ocuparemos Docker dentro de un mes)
* **¿Necesito instalar algo más? Sí**
  
  1. Un editor de texto decente. Listo para la 2da clase. Recomendaciones:
     * Mac o Linux: [Atom](https://atom.io/)
     * Linux: [Gedit](http://sourceforge.net/projects/gedit/) u otro que te guste.
  2. Un editor de Markdown    
     * Mac: [MacDown](http://macdown.uranusjr.com/)
     * Mac o Linux: [Haroopad](http://pad.haroopress.com/) o [Typora](https://typora.io/)
  3. [R y RStudio](https://www.rstudio.com/products/rstudio/download/).
  
  **Si van a tomar notas, que sean ahí o en un editor de Markdown, nooooo en Word, de veritas de veritas**.

<!-- También necesitas abrir una **cuenta de Github** para unirte al [![Gitter](https://badges.gitter.im/BioinfinvRepro/Bioinfo2020.svg)](https://gitter.im/BioinfinvRepro/Bioinfo2020?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)-->

### Este repositorio

El repositorio está dividido en un folder por Unidad. Dentro de cada folder subiremos los apuntes y código utilizado en cada clase conforme los vayamos viendo en el semestre, así como los enlaces a las tareas.

Las notas de este repositorio están escritas en formato **Markdown** y, como notarás, el repositorio se encuentra hospedado en **GitHub**.

Cubriremos ambas herramientas en el curso, pero en resumen:

* Markdown es un procesador texto-a-HTML que de forma sencilla permite formatear texto `así`. Esto es útil para resaltar los los comandos y los resultados de la terminal del resto del texto en los documentos de clase (y en foros de ayuda).

* GitHub es un repositorio web especializado en software (pero se puede subir cualquier texto, como este). La parte de arriba enlista los archivos y carpetas dentro del repositorio. La nota de texto a su derecha es el comentario que yo realicé al subir o modificar (*commit*) el archivo de mi computadora a GitHub. En la parte de abajo puedes leer el contenido de dichos archivos en formato html. Y si los bajas los verás en formato Markdown.

En este mismo repositorio de github están las versiones de cursos que hemos dado los años pasados. Cada curso está en una "rama" de del repositorio (más adelante veremos qué es esto). Si estás siguiendo este curso en youtube en un año diferente al del curso, quizá sea necesario que cambies la rama para que los videos correspondan con los apuntes.

![](github-branches.png)

En la unidad 2 aprenderemos a utilizar github desde la línea de comando, pero por lo pronto, para hacer los ejercicios de la unidad 1: baja el respositorio y guárdalo en tu escritorio. Para bajarlo da click en el botón verde del lado derecho que dice "Clone or Download" y selecciona "Download zip".

![](github_download.png)

### Mecanismo de calificación

El curso se dividirá en tres secciones que se calificarán por separado. Se asiganarán tareas al final de cada sesión. El resultados de la tareas debe ser enviado para evaluación cada viernes hasta las 23:00 hrs. Cada tarea será evaluada con una nota del 1-7. La nota de la unidad será calculada como:

* 80% promedio aritmético entre las notas de las tareas de la unidad
* 20% Proyecto de la unidad, el cual se califica con:  
  * 15% Organización del repositorio
  * 15% README **(debe ser en inglés)**
  * 20% Análisis
  * 20% Resumen y discusión en formato Markdown 
  * 15% Gráfica(s) en R
  * 15% Scripts **deben estar comentados en inglés**

El "Proyecto" de la unidad consiste una carpeta dentro de un repositorio personal en Github donde el estudiante debe depositar sus tareas. Veremos cómo hacerlo en la sesión 2 de la Unidad 1.

Todas las unidades son obligatorias.

**Copiar o plagiar (tareas, exámenes, trabajo final, lo que sea) es motivo suficiente para reprobarte sin lugar a discusión.**

![](truestory.png)

## Temario

### [VIDEO: Bienvenida al curso](https://youtu.be/uHydMEk1biw)

### Unidad 1 Introducción a la programación

#### [**Sesión 1:  Mis primeros comandos**](Unidad1/Sesion1/Sesion1_Intro_programacion.md)

[**VIDEO: Sesión 1.1**](https://youtu.be/lxVjr32CQ98)

* Código en computación
* Cómo buscar ayuda (permanentemente)
* Introducción a la consola y línea de comando de bash
* Funciones básicas de navegación y manejo de archivos con bash
* Introducción a los scripts

Trabajo individual:

* Funciones básicas de exploración de archivos con bash
* Regular expressions y búsqueda de patrones (grep)
* Redirección con bash
* Loops con bash

#### [**Sesión 2: Organización de un proyecto bioinformático**](Unidad1/Sesion2/Sesion2_Organizacion_proyecto_bioinf.md)

[**VIDEO: Sesión 1.2**](https://youtu.be/6kpQ0PtIae0)

* Documentación de scripts y del proyecto
* Markdown
* git
* Github

Trabajo individual:

* Manejo de proyectos e issues en Github
* Creación de pipelines

#### [Sesión 1,3: Introducción a R con un enfoque bioinformático](Unidad1/Sesion3/Sesion3_Intro_a_R.md)

[**VIDEO: Sesión 1.3**](https://youtu.be/txXnnxVx21o)

* R y RStudio
* Funciones básicas de R más importantes para bioinformática
* Rmarkdown y R Notebook
* Funciones propias: crear funciones y utilizarlas con source ([Video opcional](https://www.youtube.com/watch?v=98AaKGzfdCw))

Trabajo individual:

* Graficar en R
* Bioconductor
* Manipulación y limpieza de datos en R ([Video opcional](https://www.youtube.com/watch?v=cvTvySyvG-s))

### Unidad 2 Genética de poblaciones con software especializado

#### [Sesión 1: Datos genéticos](Unidad2/Sesion1/Pop_genetics_software_especializado.md)

[**VIDEO: Sesión 2.1**](https://youtu.be/TYR9Xd_lIBA)

* Formatos VCF-tools y plink
* Paquetes de R y otros software para genética de poblaciones

#### [Sesión 2: Análisis genético de poblaciones](Unidad2/Sesion2/Tutorial_PopGeno.md)

[**VIDEO: Sesión 2.2**](https://youtu.be/LtxeavYa6sE)

* PCA exploratorios
* Análisis de estructura poblacional
* Análisis de mestizaje

#### [Sesión 3: Genética de Poblaciones 2](Unidad2/Sesion3/Tutorial_de_Genetica_de_Poblaciones_usado_estadisticos_F.md)

Profesora: Constanza de la Fuente, Programa de Genética Humana, Facultad de Medicina, Universidad de Chile
[**PPT: Sesión 2.3**](Unidad2/Sesion3/Genetica_de_Poblaciones_2.pdf)
[**VIDEO: Sesión 2.3**](https://youtu.be/BdNl7IJzCt0)

* Estadísticos F2, F3, F4

* qpWave – qpAdm

* Modelos pqGraph

### Unidad 3 Generación y alineamiento de datos NGS

#### [Sesión 1 Generación y QC de datos NGS](Unidad3/Sesion1/Tutorial_Control_de_calidad_de_lecturas_NGS.md)

[**PPT: Sesión 3.1**](Unidad3/Sesion1/Sesion1_Generacion_Analisis_de_datosNGS_RAV_2019.pdf)
[**VIDEO: Sesión 3.1**](https://www.youtube.com/watch?v=aoZ6o4silGk)

* Técnicas de secuenciación
* Errores de secuenciación
* Limpieza de datos crudos

Trabajo individual:

* Formatos fastq, bam, vcf

#### [Sesión 2: Introducción a las bases de datos](Unidad3/Sesion2/Tutorial_cBioPortal.md)

[**PPT: Sesión 3.2**](Unidad3/Sesion2/Sesion2_DBBiologicas_bioinfo.pdf)
[**VIDEO: Sesión 3.2**](https://youtu.be/h-IQFwbv7Cs)

* Datos de secuencias
* Bases de datos biológicas

#### [Sesión 3: Análisis de secuencias](Unidad3/Sesion3/README.md)

* [Alineamiento contra un genoma de referencia](Unidad3/Sesion3/Tutorial_filtro_alineamiento_lecturas_chilegenomicolab.md)
* [Llamado de variantes](Unidad3/Sesion3/Tutorial_para_el_llamado_de_variantes.md)
  [PPT: Sesión 3.3](Unidad3/Sesion3/Alineamiento_y_llamado_variantes_NGS_2025.pdf)

Trabajo individual:

* Predicción funcional de variantes
* Interpretación y anotación de variantes

#### [Sesión 4: Análisis de ADN con CLC](Unidad3/Sesion4/Analisis_con_CLC.md)

* Herramientoas de analisis de NGS de Qiagen
* Introducción al CLC Genomics Workbench
* Demostración análisis de datos NGS con CLC
  [VIDEO: Sesión 3.4](https://qiagen.zoom.us/rec/share/EkeRexxOe4uKvhc4qMgovZgsJItv3vvCeG6x80uXhFuJsdE0aFlTMQLva__DNmzE.Lfx8UQTsUdvnONR5) (Passcode: ^4BTqT6?)

#### [Sesión 5: Genómica del cáncer](Unidad3/Sesion5/Tutorial_Sarek.md)

* Llamado de mutaciones somáticas

* Aplicaciones para la precisión del diagnóstico
  
  ##### Material:

* [VIDEO: Sesión 3.5 Clase](https://youtu.be/qp91ZbavBfQ)

* [VIDEO: Sesión 3.5 Nomenclatura mutaciones](https://youtu.be/dFuxDvJlfNY)

* [VIDEO: Sesión 3.5 Tutorial](https://youtu.be/CrGRCj8p85k)

### [Unidad 4 Análisis de transcriptomas](Unidad4/Analisis_de_Transcriptomas.md)

#### [Sesión 1 Expresión diferencial](Unidad4/Sesion1/Tutorial_de_expresion_diferencial_en_R.md)

* Microarreglos

* Diseño experimental

* Análisis de expresión diferencial
  
  ##### Material:

* [Láminas proyectadas en clase](Unidad4/Sesion1/Sesion1_Expresion_diferencial.pdf)

* [VIDEO: Sesión 4.1 Clase](https://youtu.be/-GOh4KGDnVU)

* [VIDEO: Sesión 4.1 Tutorial](https://youtu.be/un-eTG0keXc)

#### [Sesión 2 Análisis funcional](Unidad4/Sesion2/Tutorial_Analisis_de_clustering.md)

* Clustering

* Enriquecimiento funcional

##### Material:

* [Láminas proyectadas en clase](Unidad4/Sesion2/Sesion2_Analisis_funcional_RAV_2025.pdf)
* [VIDEO: Sesión 4.2 Clase](https://youtu.be/f_9dWbyGN00)
* [VIDEO: Sesión 4.2 Tutorial](https://youtu.be/vOopjOpOhKA)

#### **Sesión 3 RNA-seq**

* Generación de datos RNAseq
* Modelamiento de datos
* Software