/*
Vamos a leer nuestro archivo un archivo TXT

Se leen directamente dentro de un bloque DATA. Es más fácil que con los EXCEL
*/

DATA comunidades;

	INFILE '/home/ivanosunaayuste0/sasuser.v94/Datos/comunidades.txt';

    INPUT 
        Id                 1-2
        NombreComunidad    $3-37
        Ventas             38-46;

RUN;

/* NUESTRO OBJETIVO NUMERO 1: Generar un formato en AUTOMATICO para la columna ID
que formateé los números como el NOMBRE de la comunidad 
En este caso, tenemos un conjunto de datos que tienen tanto el ID (valor guardado en SAS) 
como el TEXTO que quiero usar en el formato (NOMBRE DE LA COMUNIDAD).
Hay un procedimiento en SAS que me permite generar un FORMATO EN AUTOMATICO
cuando se dan estas circustancias.
Eso lo hacer también con el PROC FORMAT, peeeero, en este caso, a ese procedimiento le pasamos
la tabla con esos valores... para que desde ella genere el formato.

En realidad es un poquito más complejo.
Ese procedimiento necesita una tabla que tenga una serie de columnas... muy particulares...
con nombres muy concretos:
- Label (que contenga la etiqueta-texto que se usará para renderizar un dato)
- Start (que contenga el valor (o el valor inicial)) del dato que se formaterá con esa etiqueta
- End: Cuando queremos generar unn formato que se aplique sobre INTERVALOS usaremos la etiqueta 
  END para el final del intervalo al que aplicar la etiqueta.
  En nuestro caso NO HAY RANGO... solo valores discretos. NO USAREMOS END

Este procedimiento me permite generar NO SOLO UN FORMATO, sino 87k formatos desde una única tabla.
Cada linea de esa tabla debe indicar a que FORMATO se va a aplciar (el nombre del formato)
- Eso se detalla en la columna FMTNAME.

- Type: Tipo de formato. En nuestro caso N (formato simple para números)

   LABEL                   START.            END       FMTNAME          TYPE
	Asturias                  2               -        Comunidades      N -> Formato simple para numeros
	Murcia                    3               -        Comunidades
	Hombre                    1               -        Sexo
	Mujer                     2               -        Sexo


*/  
 
DATA ListadoComunidadesParaFormato;
    FMTNAME = 'Comunidades'; ***1;
    TYPE = 'N';
    SET Comunidades;
    RENAME NombreComunidad = LABEL;
    RENAME Id = START;
    DROP Ventas;
RUN;

PROC FORMAT CNTLIN=ListadoComunidadesParaFormato;
RUN;

DATA comunidades;
	SET comunidades;
	*Peso = Ventas / Min(Ventas) Esto no funciona... devuelve 1;
	/* 
	Por qué?
    Por cómo SAS va procesando los bloques DATA.
    El procesamiento se hace FILA A FILA. Una vez procesada una fila... sus datos se pierden!
    Después de procesarse TODAS LAS FILAS (una a una),
    es cuando SAS Aplica operaciones a nivel de la TABLA COMPLETA, como por ejemplo: 
    DROP, KEEP, RENAME...
	
    Por la propia definición de la función MIN. Esa función, igual que MAX, o MEAN, o MEDIAN...
    Opera a nivel de FILA... no de COLUMNA.
    Me permitiría CALCULAR EL MINIMO de 6 columnas
	*/
	FORMAT Id Comunidades.; * NOTA... El nombre que ponemos aquí es: ***1 ;
	DROP NombreComunidad;
RUN;
/* 
Hemos pinchao en hueso... El tema lo tenemos que resolver de una forma... más compleja! 
De hecho tenemos varias opciones.
OPCION 1: √ Crear una tabla de datos que tenga el valor MINIMO a nivel de la COLUMNA COMPLETA: 15532
          √ Hacer un PRODUCTO CARTESIANO de esa tabla con nuestra tabla de comunidades.
          √ Hacer la división
          Esto es un desastre.. No lo haríamos nunca. Hay formas mejores (véase opción 2)
          Pero... de cara alcurso nos ha enseñado muchas cosas:
          - PROC MEANS -> Generar estadísticos
          - Sintaxis reducidad para operaciones a nivel de tabla
          - PROC SQL -> Para trabajar sobre los DATASETS con lenguaje SQL
OPCION 2: Ordenar la tabla por VENTAS ASCENDENTE
          Forzar a que se copie el valor de una columna a la fila siguiente <--- Esto es mucho más fácil, rápido (en según que escenario)
*/
  
  
/* OPCION 1 */
/* Calcular el MINIMO A NIVEL DE LA TABLA COMPLETA */
/*PROC MEANS DATA = comunidades MIN; * Nos permite extraer los estadísticos básicos de una tabla: MEDIA, MEDIANA, MIN, MAX, VARIANZA, DESVIACIÓN TIPICA, Q1, Q3; 
    * MIN, MAX, MEAN, MEDIAN, STD, VAR, N, NMMISS, Q1, Q3;
    VAR Ventas;
RUN;
*/
/* 
Problema... dónde está ese MIN ahora? En un informe... papel mojao.
Puedo sacar un dato de un informe para usarlo en cálculos? NO
Una gracia que tiene el PROC MEANS es que podemos pedir que la tabla que se genera como informe, 
se GUARDE también como DATASET.
*/

/*
PROC MEANS DATA = comunidades MIN; * Nos permite extraer los estadísticos básicos de una tabla: MEDIA, MEDIANA, MIN, MAX, VARIANZA, DESVIACIÓN TIPICA, Q1, Q3; 
    VAR Ventas;
    OUTPUT OUT=Minimo MIN=Valor;
RUN;
DATA Minimo;
    SET Minimo;
    DROP _TYPE_ _FREQ_;
RUN;
*/
/* 
Pero esto es un poco rollo, ya que SAS nos ofrece una sintaxis más simple para estas operaciones 

CADA VEZ que usamos el NOMBRE de una tabla, justo detrás podemos poner ()
Y dentro de esos parentesis poner: DROP, KEEP, RENAME...

*/
/*
PROC MEANS DATA = comunidades MIN; * Nos permite extraer los estadísticos básicos de una tabla: MEDIA, MEDIANA, MIN, MAX, VARIANZA, DESVIACIÓN TIPICA, Q1, Q3; 
    VAR Ventas;
    OUTPUT OUT=Minimo(DROP=_TYPE_ _FREQ_) MIN=Valor;
RUN;
*/
/*
 PRODUCTO CARTESIANO
 Muy fácil... lo que estamos haciendo es crear un conjunto nuevo de datos.

DATA comunidades;
    MERGE comunidades Minimo * Este merge es el que nos servirá para los JOINS NORMALES (INNER, OUTER... );
RUN;
*/
/*
PROC SQL;
   CREATE TABLE comunidades AS
   SELECT ID, VENTAS , VENTAS / VALOR AS PESO 
   FROM comunidades 
   CROSS JOIN Minimo;
QUIT;
*/

PROC SORT data = comunidades;
   *BY DESCENDING Ventas;
   BY Ventas;
RUN;
/*
Los ordenadores ordenan datos como el culo!
Es la peor cosa que le puedo pedir a un ordenador.
Les cuesta mucho... horrible!
A más datos -> MUCHO más tiempo de ordenación.
10 datos-> 1s
20 datos -> 2 segundos (NO) -> 30 segundos.
1000 datos =  500 segundos

Si tengo tablas con 50.000 datos... 500.000 dtos... no hay problema... eso es poco para una computadora.
Por ahí está el límite.

Cuando tengo conjuntos de datos muy grandes, el PROC MEANS es mucho MUCHISIMO más eficiente.
Para calcular el mínimo, el PROC MEANS lo que hace es leer todos los datos... 1 vez...
Y a más datos... más tiempo.
10 datos -> 1 segundo
1000 datos -> 100 segundos
ES PROPORCIONAL EL TIEMPO QUE TARDA EN FUNCION DE LA CANTIDAD DE DATOS.
*/
DATA WORK.comunidades;
	SET comunidades;
    RETAIN minimo 0;    * Mantiene el dato de una nueva columna que estoy generando entre una fila y la siguiente;
    					* Me asegura que en cada fila, el valor de esta columna empieza con el valor ;
						* que tenía esa columna en la fila anterior;
						* El 0 es un valor inicial;
    IF minimo= 0 THEN minimo = Ventas; * Esto nos asegura que el valorCopiado solo se establece en la primera fila, que es la única donde 'valor' esta asignado;
	Peso = Ventas / minimo;
	DROP minimo;
RUN;

