# Analisis funcional de datos de microarreglos

Ricardo Verdugo y Karen Oróstica

## Datos

Para este tutorial, utilizaremos la matriz datos normalizados que generamos en el tutorial Análisis de expresión diferencial en R

En el tutorial pasado, generamos un objeto normdata. Vaya la carpeta DE_tutorial, vuelva a importar los datos y normalizarlos. Una vez generada la matrix de datos, expórtela como un archivo plano separado por tabulaciones.

```R
outdir     <- "output"

if(!file.exists(outdir)) {
  dir.create(outdir, mode = "0755", recursive=T)
 }

Data.Raw  <- read.delim("../data/Illum_data_sample.txt")
signal    <- grep("AVG_Signal", colnames(Data.Raw)) # vector de columnas con datos 
detection <- grep("Detection.Pval", colnames(Data.Raw))

annot     <- read.delim("../data/MouseRef-8_annot.txt")
probe_qc  <- ifelse(annot$ProbeQuality %in% c("Bad", "No match"), "Bad probes",
  "Good probes")

design    <- read.csv("../data/YChrom_design.csv")
print(design)

Data.Raw <- Data.Raw[probe_qc %in% "Good probes",]
annot    <- annot[probe_qc %in% "Good probes",]

rawdata           <- as.matrix(Data.Raw[,signal])
rownames(rawdata) <- Data.Raw$PROBE_ID
colnames(rawdata) <- design$Sample_Name

library(preprocessCore)
normdata           <- normalize.quantiles(rawdata) 
colnames(normdata) <- colnames(rawdata)
rownames(normdata) <- rownames(rawdata)

probe_present      <- Data.Raw[,detection] < 0.04
detected_per_group <- t(apply(probe_present, 1, tapply, design$Group, sum))

present  <- apply(detected_per_group >= 2, 1, any)
normdata <- normdata[present,]
annot    <- annot[present, ]

write.table(file.path(outdir, "normdata.txt", sep="\t", row.names=T))
```

Luego cree una nueva carpeta para este tutorial e inicie una sesión de R usado esa capeta como directorio de trabajo.

```R
## Importe los datos

mydata <- read.delim("normdata.txt", as.is=T)
Cambie los nombres de las columnas para que sea más fácil identificar el grupo experimental en los siguientes gráficos.

design <- read.csv("../data/YChrom_design.csv")
colnames(mydata) <- design$Group
```

## Tutorial

Este tutorial está basado en el Cluster Analysis, Quick-R, DataCamp.

```R
Preparar los datos

mydata <- na.omit (mydata) # eliminación en forma de lista de faltantes mydata <- scale (mydata) # estandarizar variables
```

## Particionamiento (Clustering)

K-means clustering es el método de partición más popular. Requiere que el analista especifique la cantidad de clusters que extraer. Una gráfica de la suma de cuadrados dentro de los grupos por número de grupos extraídos puede ayudar a determinar el número apropiado de grupos. El analista busca una curva en la gráfica similar a una prueba de evaluación en el análisis factorial. Ver Everitt y Hothorn (pág. 251).

```R
# Determinar el número de grupos
wss <- (nrow(mydata)-1)*sum(apply(mydata,2,var))
for (i in 2:15) wss[i] <- sum(kmeans(mydata,
   centers=i)$withinss)
plot(1:15, wss, type="b", xlab="Number of Clusters",
  ylab="Within groups sum of squares") 

# K-Means Cluster Analysis
fit <- kmeans(mydata, 5) # 5 cluster solution
# get cluster means
aggregate(mydata,by=list(fit$cluster),FUN=mean)
# append cluster assignment
mydata <- data.frame(mydata, fit$cluster) 

```
Se puede invocar una versión robusta de K-means basada en mediods usando pam () en lugar de kmeans (). La función pamk () en el paquete fpc es una envoltura para pam que también imprime el número sugerido de grupos en función del ancho de silueta promedio óptimo. Aglomerante jerárquico

Hay una amplia gama de enfoques de agrupamiento jerárquico. He tenido buena suerte con el método de Ward que se describe a continuación.

### Clúster jerárquico

```R
d <- dist(mydata, method = "euclidean") # distance matrix
fit <- hclust(d, method="single")
plot(fit) # display dendogram
groups <- cutree(fit, k=5) # cut tree into 5 clusters
# draw dendogram with red borders around the 5 clusters
rect.hclust(fit, k=5, border="red") 
```

La función pvclust () en el paquete pvclust proporciona valores p para el agrupamiento jerárquico basado en el remuestreo bootstrap multiescala. Los clusters que son altamente compatibles con los datos tendrán valores p grandes. Detalles de la interpretación se proporcionan Suzuki. Tenga en cuenta que pvclust agrupa columnas, no filas. Transponer sus datos antes de usar.

La función pvclust () en el paquete pvclust proporciona valores p para el agrupamiento jerárquico basado en el remuestreo bootstrap multiescala. Los clusters que son altamente compatibles con los datos tendrán valores p grandes. Detalles de la interpretación se proporcionan Suzuki. Tenga en cuenta que pvclust agrupa columnas, no filas. Transponer sus datos antes de usar.

```R
# Particionamiento jerárquico con valores p a partir de Bootstraps
library(pvclust)
fit <- pvclust(mydata, method.hclust="single",
   method.dist="euclidean")
plot(fit) # dendograma con valores p
# agregar rectángulos alrededor de grupos altamente soportados por los datos
pvrect(fit, alpha=.95) 
```

### Particionamiento basado en un modelo

Los enfoques basados en modelos asumen una variedad de modelos de datos y aplican la estimación de máxima probabilidad y los criterios de Bayes para identificar el modelo más probable y el número de conglomerados. Específicamente, la función Mclust () en el paquete mclust selecciona el modelo óptimo de acuerdo con BIC para EM inicializado por agrupación jerárquica para modelos de mezcla Gaussianos parametrizados. (¡Uf!). Uno elige el modelo y la cantidad de conglomerados con el BIC más grande. Consulte la ayuda (mclustModelNames) para obtener detalles sobre el modelo elegido como el mejor.

```R
library(mclust)
fit <- Mclust(mydata)
plot(fit) # graficar resultados
summary(fit) # muestra el mejor modelo
```

### Generación de gráficos para el resultados del particionamiento

Siempre es una buena idea mirar los resultados del particionamiento resultante.

```R
# Particionamiento K-means con 5 agrupamientos
fit <- kmeans (mydata, 5)

## Gráfico de clúster contra los 2 primeros componentes principales

# variar los parámetros para el gráfico más legible
library(cluster)
clusplot(mydata, fit$cluster, color=TRUE, shade=TRUE,
   labels=2, lines=0)

```
Tarea

Usando el set de datos normalizados de la tarea de expresión diferencial (con los 5000 sondas seleccionadas por usted), y seleccionados por expresión diferencial para cualquiera de los contrastes:

Realice un particionamiento jerárquico de sus muestras con la medida de distancia euclideana
Realice un particionamiento jerárquico de sus sondas usando el complemento de la correlación de pearson como la medida de distancia.
Genere gráficos de suma de cuadrados para sondas y para muestras
Basándose en los gráficos de sumas de cuadrados, elija el k más apropiado en su criterio para sondas y para muestras
Agregue rectángulos a los particionamiento jerárquicos (nota, en su informe puede mostrar solo el arbolo final, con los rectángulos).
Guarde su trabajo como un informe en formato Markdown.




