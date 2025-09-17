
LIBNAME DATOS '/home/ivanosunaayuste0/sasuser.v94/Datos';



DATA NUEVO; *Crea una nueva tabla llamada NUEVO ;
    SET DATOS.chucheriasFinal;
	/* 
	Cada fila de chucheriasFinal se va procesando de forma indepdiente... UNA A UNA.
	PROCESAMIENTO: */
	dobleCantidad = cantidad * 2;
	/*Y una vez procesada, se guarda el resultado en la tabla clientesSinCompra 
	Y ya vamos a por otra fila.
	Estamos diciendole EXPLICITAMENTE que guarde la fila en el nuevo DATASET?
	*/
	OUTPUT NUEVO; * Guarda la fila en la tabla NUEVO; 
	/*
	SAS POR DEFECTO AÑADE ESTA LINEA SIEMPRE AL FINAL... AUNQUE YO NO LA PONGA.
	SIEMPRE ESTA... solo que no me hace falta escribirla explicitamente!
	*/
RUN;


DATA DUPLICADO TRIPLICADO;
    SET DATOS.chucheriasFinal;
	OUTPUT DUPLICADO;	
	OUTPUT TRIPLICADO;
RUN;


DATA 
	clientesSinCompra
	ventasGrandes
	ventasNegras
	ventasEnCantabria
;
    SET DATOS.chucheriasFinal;
    IF MISSING(cantidad) THEN OUTPUT clientesSinCompra;
    IF COLOR = 5 THEN OUTPUT ventasNegras;
    IF cantidad > 4 THEN OUTPUT ventasGrandes;
    IF comunidad = 5 THEN OUTPUT ventasEnCantabria;
RUN;

/* OTRO TEMA */
/* 
Hemos aprendido a hacer JOINS ... realmente solo hemos aprendido a hacer 1 join: FULL OUTER JOIN
*/

DATA Tabla1;
INPUT Nombre $1. Comunidad $1.;
CARDS;
Aa
Ba
Cb
Dc
;
RUN;

DATA Tabla2;
INPUT Ventas $1. Comunidad $1.  ;
CARDS;
1a
2b
3d
;
RUN;

PROC SORT data= Tabla1;
BY comunidad;
RUN;
PROC SORT data= Tabla2;
BY comunidad;
RUN;

DATA FULLOUTERJOIN
     LEFTOUTERJOIN
     RIGHTOUTERJOIN
     INNERJOIN
     NOMBRES_SIN_VENTAS
     VENTAS_SIN_NOMBRE;
     /* Estas variables in indican si la fila que stoy procesando en este momento estéá en la tabla de turno o no */
   MERGE Tabla1 (in=entabla1) 
         Tabla2 (in=entabla2)
   ;
   BY comunidad;
   OUTPUT FullOuterJoin;
   IF entabla1 THEN OUTPUT LeftOuterJoin;
   IF entabla2 THEN OUTPUT RightOuterJoin;
   IF entabla1 and entabla2 THEN OUTPUT InnerJoin;
   IF entabla1 and NOT entabla2 THEN OUTPUT NOMBRES_SIN_VENTAS;   
   IF entabla2 and NOT entabla1 THEN OUTPUT VENTAS_SIN_NOMBRE;
RUN;

PROC SORT data= DATOS.chucheriasFinal;
BY comunidad;
RUN;
/*ACUMULADOS*/
DATA NUEVO
     ACUMULADO; 
    SET DATOS.chucheriasFinal;
    BY Comunidad; * Quiero procesar los datos agrupados por COMUNIDAD;
    * Realmente lo que estas diciendo aqui es que cada vez que empiece una comunidad haya una nueva;
    * variable que podamos usar: FIRST;
    * IGUAL QUE FIRST, tenemos LAST;
    RETAIN cantidadAcumulada 0;
    IF FIRST.Comunidad THEN cantidadAcumulada=0;
    IF NOT MISSING(cantidad) THEN cantidadAcumulada = cantidadAcumulada + cantidad;
	IF LAST.Comunidad THEN OUTPUT NUEVO;
	KEEP cantidadacumulada comunidad;
RUN;

