/*
Esto nos permite escribir comentarios.
Los usamos para documentar o comentar el código que vamos haciendo.
Lo que escribamos en bloques como éste no se ejecuta por SAS.
*/

/*
Estamos en un curso de programación en SAS.
SAS no es un programa.
SAS es una empresa que crea programas (muchos) que nos permiten aplicar técnicas estadísticas sobre datos:
- Enterprise Guide
- Miner
- Viya
- ...

Adicionalmente a todo esto, SAS ofrece un lenguaje de programación.
Muchos de esos otros programas nos permiten usar este lenguaje... y algunos lo encubren... mediante formularios.

Cuando SAS comenzó como empresa.. hace 50 años, creó un primer lenguaje para manipulación de datos 
y técnicas estadísticas: SAS BASE

Es un lenguaje muy potente... pero un poquito complejo.

Con el tiempo, crearon un segundo lenguaje... Más bien ampliaron SAS BASE, con otro llamado SAS SQL.
SQL Es mucho menos potente (en general) que BASE... pero ... más sencillo.
*/

/*
Vamos a estar manejando conjuntos de datos es SAS: El equivalente a TABLAS de una BBDD o de un fichero EXCEL...
con sus columnas, filas...
En SAS a este concepto le denominamos un DATASET.
Esos conjuntos de datos (DATASETS) podemos leerlos desde archivos (XLSX, TXT, SASBDAT), 
también podemos leerlos de BBDD, incluso crearlos desde CERO.
*/

/*
En esos conjuntos de datos, tendremos columnas.
Y esas columnas tendrán asociado un tipo de datos (números, textos, ...)
Ese tipo de datos, tiene que ver con cómo SAS guarda los datos en Memoria RAM.. y en Disco.
PERO CUIDADO: Cuándo comencemos a analizar datos, esos tipos de datos NO NOS INTERESAN ... NADA!
Y en ese momento hablaremos de otros tipos de datos (QUE SAS NO CONTROLA): TIPOS DE DATOS ESTADISTICOS:
- Cualitativos (Nominales, Ordinales) 
- Cuantitativos

"Código postal" 
- Cómo lo guardo? Número
- Puedo calcular una media de los códigos postales? NO... las medias se pueden 
calcular sólo sobre datos CUANTITATIVOS (que disponga de una unidad de medida)

*/

DATA colores ; * Le indico a SAS que quiero crear un conjunto de datos, al que denomino "colores";
/* Le tengo que indicar a SAS qué columnas va a tener ese conjunto de datos 
En este momento, hemos de indicarle a SAS la naturaleza de los datos... cómo debe guardarlos/procesarlos:
Si son textos, si son números... Thge de darlo los TIPOS DE DATOS.
Por defecto, si no indico nada, SAS entiende que los datos son de tipo NUMERICO.
Si queremos indicarle que un dato lo que albergará son textos, hemos de definirlo explicitamente.
Para ello usamos la sintaxis: "$<CANTIDAD>."
*/
INPUT id nombre $20. ; * Queremos 2 columnas en el conjunto de datos: "id", "nombre" (texto con hasta 20 caracteres);
/*
En este caso, vamos a darle manualmente a SAS los datos de este conjunto de datos
Eso lo hacemos con la palabra CARDS */
CARDS;
1 Blanco
2 Negro
3 Violeta
4 Amarillo
5 Azul
6 Rojo
7 Verde
; /* Este punto y coma significa que ya no le voy a dar más datos */

/* 
Eso es todo 
Oye... esto de ahi arriba es un trozo de código ejecutable : RUN
*/
RUN;

/* 
Dónde se ha guardo esa tabla? 
Toda tabla de SAS se guarda dentro de lo que llamamos una LIBRERIA (LIBRARY).
Esas librerías, pueden guardarse realmente en distintos sitios:
- BBDD
- MEMORIA RAM
- Disco Duro (dentro de una carpeta)

Si a SAS no le indico dónde guardar un conjunto de datos (DATASET) por defecto se guarda en RAM.
La memoria RAM no tiene persistencia REAL (se borra al salir del programa).
Esa librería que SAS usa por defecto, y que se guarda en RAM, se llama WORK.
Podemos escribirlo explicitamente o no. Si no escribo nada, SAS supone que lo quiero guardar en esa librería.
DATA colores ; 
DATA WORK.colores ;
DATA LIBRERIA.colores; 
*/

/*
Ese bloque que tenemos arriba de código es lo que llamamos un bloque DATA
Los bloques data me sirven para crear o leer conjuntos de datos (TABLAS).

Pero en SAS tenemos más tipos de bloques: PROC
Cualquier operación que quiera realizar sobre un conjunto de datos, irá dentro de un bloque PROC.
El más sencillo es el PROC PRINT. Eso lo imprime en la pantalla.
Cada bloque PROC va a ir acabado de la palabra RUN;
*/

PROC PRINT DATA=colores;
RUN;

PROC PRINT DATA=WORK.colores;
RUN;

/*
Hemos dicho que SAS tiene distintos "TIPOS DE DATOS"... formas en la que los datos se guardan en Disco y RAM...
Hemos hablado ya de 2 tipos de datos (hay más): TEXTOS y NUMEROS.
En los ficheros de datos queremos la menor cantidad posible de TEXTOS, si puedo no tener ninguno, mejor que mejor!
Pero... textos hay.... cómo lo hacemos? CODIFICÁNDOLOS.
Imaginemos por ejemplo un conjunto de datos que tenga los siguientes campos (columnas):
PERSONAS:
- ID						NUMERO
- NOMBRE / APELLIDOS.       codificarlo.. pero... cuíántas veces se repite un nombre / apellidos (muy pocas) NO COMPENSA CODIFICARLO
- Edad						NUMERO (feo)
- DNI                       TEXTO 9 bytes      NUMERO + LETRA (5 bytes)
- Sexo                      TEXTO 6 bytes "hombre" => 0 vs "mujer" => 1              => NUMERO (1bit)
- Dirección                 TEXTO (se repite muy pocas veces) NO COMPENSA CODIFICARLO
- Población                 TEXTO (en España hay 20.000 poblaciones y se repetirán mucho. Si me compensa codificar
- CP                        NUMERO


Cómo lo veís eso que hemos hecho para la columna SEXO (CODIFICARLA)?
- Parte positiva:
  Al final, el dato se guarda en RAM o en DISCO... es más, también se transmite por la RED.
  Los ordenadores por dentro no guardan TEXTOS o NUMEROS... internamente hablando con CEROS y UNOS (Binario).
  La menor cantidad posible de información que puedo representar en una computadora sería eso: Un CERO o un UNO.
  BIT: Es un espacio dende puedo tener un CERO o un UNO... solo uno de ellos.
       En un bit puedo guardar cuántos datos? 1
       Ahora, cuántos valores diferentes puedo guardar en ese BIT? 2: El 0 o el 1
  Normalmente 2 potenciales valores se nos hacen poco. Lo que hacemos es agrupar los BITS de 8 en 8...
  Un grupo de 8 bits se denomina BYTE.
  _ _ _ _ _ _ _ _
  0 0 0 0 1 1 0 1
  
  Claro... una cosa es lo que guarda el ordenador... y otra lo que YO humano quiero entender por esa secuencia.
  Ahí entran los tipos de datos.
  
  0 0 0 0 0 0 0 0 -> Número 0
  0 0 0 0 0 0 0 1 -> Número 1
  
  0 0 0 0 0 0 0 0 -> Letra a
  0 0 0 0 0 0 0 1 -> Letra b
  
  
  0 0 0 0 0 0 0 0 -> Color blanco
  0 0 0 0 0 0 0 1 -> Color azul
  
  En un byte (8 bits) Cúantas combinaciones diferentes de 0/1 puedo hacer? 
  Cúantos datos diferentes podría representar? 2^8 = 256

  Si esas 256 combinaciones posibles, las utilizo para representar NUMEROS, 
  hasta qué número puedo llegar en un byte? 255
  
  Cuántos bits/bytes ocupa una letra/caracter? AQUI LA COSA SE COMPLICA.
  
  Cúantos caracteres diferentes usa la humanidad para comunicarse? Más de 140.000 caracteres.
  Están recopilados en un estandar llamado UNICODE.
  
  En un byte, hgemos dicho que podemos guardar cúantos valores diferentes ? 256... Entonces puedo guardar 140.000?
  Ni de coña.
  Claro... puede ser que no quiera usar caracteres chinos (-6000 caracteres), ni emojis (-5000), ni cirílicos (-50)...
  A lo mejor solo quiero letras de las que usamos en inglés. 
  
  Existen lo que se llaman JUEGOS DE CARACTERES. Un juego de caracteres es una tabla que contiene 2 cosas:
  - El caracter que quiero representar
  - La secuencia de bits con l a que lo represento.
  Y en ese JUEGO De caracteres solo incluyo aquellos caracteres que necesito utilizar.
  
  ASCII -> 1 byte -> 256 caracteres diferentes (los que se usan en inglés.. y 3 cositas más)
  ISO-8859-1 -> 1 byte -> 256 caracteres que se usan mucho en paises de habla hispana/lusa.
  Hoy en día usamos mucho UTF:
  - UTF-8    Usa entre 1 y 4 bytes, dependiendo del caracter (MAS HABITUAL)
  				01010011                          letra A
  				0101000101010001                  letra	 Á
                11010001010100011101000101010001  emoji/caracteres asiáticos
  - UTF-16   Usa 2/4 bytes, dependiendo del caracter
  				0000000001010011                          letra A
  - UTF-32.  Usa siempre 4 bytes para representar cada caracter
  				00000000000000000000000001010011           letra A
  				
  	SEXO: hombre / mujer	 
  	    Uso letras / caracteres raros? NO... con 1 byte (UTF-8, ASCII, ISO-8859-1)
        Cuánto espacio necesito para ese campo? 6 bytes (hombre=6; mujer son 5 caracteres=5 bytes)
     
    Si lo codifico: 
    0 (= Hombre)
    1 (= Mujer)
    Cuántos bytes necesito? De hecho ninguno... con un bit es suficiente
    6 bytes = 6x8 = 48 bits vs 1.
    Acabo de meterle una reducción de espacio a esa columna de 1/48 = 2% del espacio original 
    para representar los mismos datos.
    
    Sexo: _______ ________ ________ ________ ________ ________
          0101011 00001101 11101110 11010111 00000100 00000000
          M       U        J        E        R        NADA

    Sexo: _
          0
          Mujer
    
    IMPACTO:
    - Espacio que ocupa el dato. 
      El almacenamiento es barato o caro? ES LO MAS CARO CON MUCHA DIFERENCIA 
                                          DE UN ENTORNO INFORMATICO EN UNA EMPRESA!
                                          
      En casa, un HDD de 2Tbs me cuesta 62€
      En la empresa necesito un HDD de más calidad. El HDD me cuesta x4 - x10
      Pero... es peor.. mucho peor.
      El dato es lo más valioso que tiene la empresa!
      En cualuier emprsa, cualquier dato se guarda en al menos 3 HDD diferentes, para prevenir problemas.
      Esos 2 Tbs que tengo en casa... en la empresa tengo que comprar 3 HDD de 2 TBs . Y cada disco es un x4- x10
      Tenemos copias de las 2 últimas semanas o más. x2 - x4
      Eso implica que esos 2 Tbs que en casa me cuestan 62€, en la empresa me cuentan: 8000€
      
      Pero esto es la punta del iceberg.   No es solo la pasta que ahorro en almacenamiento.
      Si los datos que quiero guardar me ocupan 48 veces más... eso implica que
      mandarlos por la red tardará 48 veces más.
      Leerlos del disco tardará 48 veces más. 
      Escribirlos a disco tardará 48 veces más.
      Subirlos a memoria RAM tardará 48 veces más.
      Procesarlos tardará 48 veces más.
      Y esto solo con una columna.
  				
- Parte negativa:
  - Acordarnos que el 0 es "hombre" y el 1 es "mujer".
    Eso tendrá impacto en las búsquedas... también en los informes.
    Necesito alguna especie de leyenda!
    COMODO NO PARECE... parece mucho mejor tener los textos.


EJEMPLO CON EL DNI: 99999999+LETRA
Esa letra, hace que si lo voy a guardar.. a priori lo guarde el campo como un campo de tipo TEXTO
Cúanto ocupa eso? 9 caracteres/9 bytes

Alternativas?
1. Guardar los dígitos juntos como un número => 4 bytes
	1 bytes puedo representar 256
	2 bytes puedo representar: 256 x 256 = 65000
	4 bytes puedo representar >4kM (256x256x256x256)
   Y la letra como texto                       => 1 byte
   TOTAL = 5 bytes... casi la mitad eh!
2. Solo guardar el número... La letra se genera en automático del número.
   Eso lo dejaría en 4 bytes. mejor aún..
   AUNQUE en este caso, cuando necesite la letra hay que calcularla... y eso consume CPU (que también cuesta)

CUANDO LLEGA UN CONJUNTO DE DATOS, lo primero es preparar los datos.
Y dentro de esa prepararación, lo primero es CODIFICAR los datos de tipo TEXTO.
*/

DATA colores ;
/* 
Estoy creando una tabla llamada colores en la librería WORK...
Y no existía ya? SI... CUIDADO... esto la va a reemplazar... y SAS no pide confirmación.
*/
INPUT nombre $20. ; 
CARDS;
Blanco
Negro
Violeta
Amarillo
Azul
Rojo
Verde
Blanco
Negro
Violeta
Amarillo
Azul
Rojo
Verde
Morado
Verde
; 
RUN;

/*
Una primera forma de codificar estos valores
*/
DATA coloresCodificados;
SET colores; * Para generar esta tabla parto de los valores de la tabla de COLORES ;
/* Aqui no usamos CARDS. Lo que hace SET es coger FILA A FILA de la tabla que le indiquemos, 
e ir aplicando sobre CADA FILA las operaciones que indicamos abajo */

IF nombre = 'Blanco' THEN codigo = 1; * CODIFICACION;
ELSE IF nombre = 'Negro' THEN codigo = 2;
ELSE IF nombre = 'Rojo' THEN codigo = 3;
ELSE IF nombre = 'Azul' THEN codigo = 4;
ELSE IF nombre = 'Verde' THEN codigo = 5;
ELSE codigo = 99;

/* 
Además de trabajar sobre las columnas que ya tengo en el conjunto original (del que parto = SET) 
Puedo crear columnas nuvas.. como la de codigo, que usa valores de la tabla original para su cálculo
O incluso crear columnas que no usen valores de esa tabla.
*/

nueva = 33;

/* Puedo crear columnas calculadas desde varios columnas */

otra = codigo + nueva;

/* 
Esto tendrá mucha más gracia, cuando usemos FORMULAS.
Sas nos da muchas fórmulas... como excel.
YA LO VEREMOS!
*/

/* DROP nombre; * Me permite quitar columnas en la tabla de salida;*/
/* DROP columna_1 columna_2 ... ; */
KEEP codigo nueva otra; *En lugar de drop (son excluyentes) me permite indicar las columnas que quiero mantener; 
/* KEEP columna_1 columna_2 ... ; */
                       /*FORMAT codigo nombresDeColores.; VEASE REFERENCIA **1 */
RUN;

/*
Ya no tenemos TEXTOS... EUREKA !!!!
Tenemos solo númeritos en la tabla (DATASET)... 
para la computadora está guay....
Para que tarde poco tiempo está guay...
Para mi leerlo... ES UNA RUINA !!!!!
Cómo resolvemos esta situación:                     FORMATOS

Una cosa es cómo sas guarda un dato... otra cosa es COMO LO QUEREMOS VER EN PANTALLA o en un INFORME.
Eso lo podemos modificar con la ayuda de un FORMATO (igual que en EXCEL).
SAS tiene muchos formatos predefinidos... que ya veremos!
Nosotros podemos definir nuestros propios FORMATOS !
*/

PROC FORMAT ;* Me permite definir un formato personalizado;
/* Este es el nombre del formato que voy a crear;*/
value nombresDeColores 
1 = 'Blanco'
2 = 'Negro'
3 = 'Rojo'
4 = 'Azul'
5 = 'Verde'
99 = 'Otro';
RUN;

PROC PRINT data=colorescodificados;
FORMAT codigo nombresDeColores.; /* OJO AL PUNTO*/
/* Al imprimir, aplica el formato llamado nombresDeColores a la columna codigo */
RUN;

/*
Esto es algo que podemos hacer... y funciona!
Al usar (por ejemplo, imprimir) una tabla, indicar qué formatos queremos aplicar a sus columnas.
En la mayor parte de los casos, las tablas que creemos las vamos a usar 50 veces.
Y no quiero estar indicando de continuo el formato... cada vez que use la tabla.
Tenemos otra opción... Directamente vincular en la tabla el formato que queremos aplicar (por defecto) a cada columna.
Eso lo podemos cambiar después (es el formato por defecto).
Lo puedo hacer al crear la tabla (**1)
O posteriormente
*/
DATA coloresCodificados;
SET coloresCodificados; 
/* 
En este caso, estoy "modificando la tabla"...
Realmente estamos creando una tabla nueva con el mismo nombre que la tabla de la que partimos.. reescribiéndola...
En la práctica, modificándola
*/
FORMAT codigo nombresDeColores.;
RUN;



PROC PRINT data=colorescodificados;
RUN;

/*
Lo que hemos hecho es crear lo que se llama un FORMATO DE SALIDA!
    dato guardado en SAS ---> le aplicamos un formato de salida ----> VERLO EN PANTALLA
Pero no es el único tipo de formato que tiene SAS.
Sas también define el concepto de FORMATO DE ENTRADA.

   DATO ORIGINAL --> al leerlo aplicarle. ---> Dato guardado en SAS --> al visualizarlo.    ---> INFORME
                     UN FORMATO DE ENTRADA                              UN FORMATO DE SALIDA

SAS También predefine muchos formatos de entrada (lo veremos!)
Y me permite definir mis propios formatos de ENTRADA!
Esto es una alternativa GUAY a los puñeteros IF / ELSE IF que hemos escrito arriba!
*/


PROC FORMAT ;* Me permite definir un formato personalizado;
/* 
Este es el nombre del formato DE ENTRADA que voy a crear.
Aquí indico cómo quiero visualizar un dato.
*/
/*(1)*/
value nombresDeColores 
1 = 'Blanco'
2 = 'Negro'
3 = 'Rojo'
4 = 'Azul'
5 = 'Verde'
99 = 'Otro';
/*
Aquí indico como quiero leer un dato antes de guardarlo.*/
/*(2)*/
invalue nombresDeColores
'Blanco' = 1
'Negro' = 2
'Rojo' = 3
'Azul' = 4
'Verde' = 5
OTHER = 99;
RUN;



DATA coloresCodificados; /* Reescribimos coloresCodificados... ya existía */
SET colores;
codigo = input( nombre , nombresDeColores.) ; /* (2) INPUT = LEE EL CAMPO ... APLICANDO EL FORMATO DE ENTRADA nombresDeColores */
DROP nombre; 
FORMAT codigo nombresDeColores.; /* (1) */
RUN;

/*
Más adelante en el curso os enseñaré a crear en AUTOMATICO el formato, asignando CODIGOS NUMERICOS SECUENCIALES a los textos
*/

/* Una variante de estos informats */
DATA personas;
INPUT nombre $10. edad;
CARDS;
Federico   35
Menchu     43
Felipe     67
Emilio     16
;
RUN;

PROC FORMAT;
value rangosEdad
1 = 'Joven'
2 = 'Adulto'
3 = 'Tercera edad';

/* 
En este caso también estamos haciendo una codificación... pero además una agrupación de datos
*/
invalue rangoEdad
0 - <20 = 1 
20 - 65 = 2
OTHER   = 3;
RUN;

DATA personas;
SET personas;
rangoEdad = input(edad, rangoEdad. );
FORMAT rangoEdad rangosEdad.;
RUN;

/*
	/home/ivanosunaayuste0/sasuser.v94
*/