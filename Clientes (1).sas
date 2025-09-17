/*
Vamos a leer nuestro archivo EXCEL

Le indicamos un nombre (alias, apodo) a la ruta completa del archivo en el servidor.
Ese nombre podmos poner lo que queramos
*/
FILENAME ARCHIVO '/home/ivanosunaayuste0/sasuser.v94/Datos/clientes.xls';

/* 
Importamos el archivo gracias al procedimiento IMPORT.
- Le indicamos el nombre del archivo
- El formato (EXCEL)
- En qué conjunto de datos SAS queremos que lo importe.
- GETNAMES= Que tome los nombres de las columnas del EXCEL
*/
PROC IMPORT DATAFILE=ARCHIVO
	DBMS=XLS
	OUT=CLIENTES;
	GETNAMES=YES;
RUN;

/* Para sacar los valores diferentes que hay de sexos */
PROC FREQ data=CLIENTES; *Una tabla de frecuencias sobre el DATASET CLIENTES;
    TABLE sexo;
RUN;

/*
Definimos un formato de entrada y de salida para la variable sexo
*/
PROC FORMAT;

VALUE SEXO
     0 = 'Mujer'
     1 = 'Hombre'
;

INVALUE SEXO
	'Chica'      = 0
	'Mujer'      = 0
	'Mujercita'  = 0
	'Muujer'     = 0
	'Hombre'     = 1
	'Hombree'    = 1
	'Hoombre'    = 1
	'Varon'      = 1
	'Varoncillo' = 1
	 OTHER       = 9
;

RUN;

/*
Procesamos (limpiamos) el fichero de clientes
*/
DATA clientesProcesados;

SET Clientes;

/* Tratamiento de la columna sexo */
sexoNuevo = input(sexo, sexo.); * Aplicamos el formato de entrada a la columna sexo;
FORMAT sexoNuevo sexo.;         * Queremos ver los números cómo textos... según formato;
DROP sexo; 						* Esta, que es la vieja, a la basura;
RENAME sexoNuevo = Sexo;        * Renombro la nueva columna como "Sexo";

/* 
Tratamiento de la fecha de nacimiento 
Lo que viene en el fichero es un texto... y queremos leerlo como si fuera una fecha 
A nivel conceptual es la misma operación que hemos hecho al leer el sexo.
De nuevo lo haremos con la funcion INPUT... aplicando un formato.
Pero en este caso, no un formato que vamos a generar nosotros.
Usaremos un formato de los que SAS nos ofrece, en concreto de los que me ofrece para fechas!
Formatos de lectura de fechas disponibles en sas (INFORMATS): https://documentation.sas.com/doc/en/etsug/15.2/etsug_intervals_sect009.htm
Formatos de salida disponibles para fechas: https://documentation.sas.com/doc/en/ds2pg/3.2/p0bz5detpfj01qn1kz2in7xymkdl.htm
*/
fechaNueva = input('F. Nacimiento'n, ANYDTDTE10.);
FORMAT fechaNueva DDMMYYD10. ;
DROP 'F. Nacimiento'n;
LABEL fechaNueva = 'Fecha de Nacimiento';* En este caso, mantenemos el nombre de la columna, pero la mostramos por pantalla con otro texto;
RENAME fechaNueva = nacimiento;

/*
FUNCIONES DE SAS 
SAS tiene un montón de funciones, que me permiten hacer calculos más avanzados...
Para calculos simples puedo usar operadores matemáticos: + - / *
Pero hay cálculos más avanzados... es el mismo concepto que tengo en EXCEL (BuscarV, Suma, Concatenar, REDONDEO)
Funciones de SAS: https://documentation.sas.com/doc/en/pgmsascdc/9.4_3.5/lefunctionsref/n01f5qrjoh9h4hn1olbdpb5pr2td.htm
*/
*hoy = TODAY();
*diferencia = YRDIF( fechaNueva, hoy );
*diferencia = YRDIF( nacimiento, hoy );
/* En este momento de calcular la edad aún no se ha cambiado el nombre de la columna fechaNueva a nacimiento.
Si intentamos hacer el cálculo con ese nombre... no encontrará la columna */
/* SAS NO EJECUTA EL CODIGO EN EL ORDEN QUE LO ECRIBIMOS... es una cagadita con la que tenemos que lidiar */
/* Y ALGO A APRENDER */
/* LOS DROP, KEEP, RENAME, LABEL, FORMAT SE EJECUTAN AL FINAL DE TODO.... CON INDEPENDENCIA DE DÓNDE LOS HAYA ESCRITO */
edad = FLOOR( YRDIF( fechaNueva, TODAY(), 'AGE' ) );
LABEL edad = 'Edad (años cumplidos)';


RUN;



PROC PRINT data=clientesProcesados LABEL; * Imprime la tabla usando las etiquetas que tenga definidas para las columnas;
RUN;



/*
Enriquecer este fichero con los pesos que hemos calculado para cada comunidad.
Necesitamos hacer un JOIN.
Qué tipo de JOIN?
- FULL OUTER JOIN **
- LEFT OUTER JOIN
- RIGHT OUTER JOIN
- INNER JOIN
- (CROSS-JOIN)

Aunque en este caso me daría igual (No hay valores perdidos), nos quedamos con el FULL para garantizar que no perdemos datos.
Solo estamos preparando datos, no analizandolos. Cuando se analicen... que pelen los datos que quieran.

Como se hace en SAS En JOIN: MERGE
Pero... hay dos restricciones al usar el MERGE: 
- Necesitamos OBLIGATORIAMENTE tener los datos de ambas tablas ORDENADOS por la columna que queremos usar para el join.
- Necesitamos que la columna del join se llame igual en ambas tablas.
*/

PROC SORT data=clientesprocesados;
 BY COMUNIDAD;
RUN;

PROC SORT data=comunidades;
 BY ID;
RUN;

/*
Almacenado del resultado persistente
Hasta ahora todo lo hemos guardado en la librería WORK (que es efímera).
Esta tabla ya queda acabada... y queremos guardarla persistentemente.
Para ello definimos una librería!
Esa librería, en nuestro caso se llama DATOS, y apunta a una carpeta en el servidor
*/
LIBNAME DATOS '/home/ivanosunaayuste0/sasuser.v94/Datos';

/* Ahora que ya tengo los datos ordenados, podemos hacer el merge */
DATA DATOS.clientesConPeso;
    MERGE 
        clientesprocesados 
        WORK.comunidades (RENAME=(Id=Comunidad) DROP=Ventas );
    BY 
		Comunidad; * Esta es la columna que se usará para enriquecer los datos;
		           * Lo que queremos es que de cada fila de la tabla clientes se mire la comunidad.;
                   * Y después vamos a la tabla de Comunidades y buscamos ese valor, para traer el peso.;
                   * Ese dato está en ambas tablas;
                   * Es lo que usamos de nexo entre ellas;
	FORMAT Comunidad comunidades.;
RUN;