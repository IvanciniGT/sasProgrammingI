LIBNAME DATOS '/home/ivanosunaayuste0/sasuser.v94/Datos';


PROC FREQ data = DATOS.chucherias; * Sacamos una tabla de frecuencias de los productos;
* El único objetivo es tener un listado de los distintos valores que hay ahí;
* Pedimos que esa tabla no se genere solo como informe, sino que se guarde como tabla de datos;
 TABLE producto / out = ListadoProductos (DROP=PERCENT COUNT);
RUN;

DATA listadoProductos;
    SET listadoProductos;
    ID = _N_; * TRUCAZO ! _N_ es una variable que me permite obtener el número de fila(registro) que estoy procesando; 
RUN;

/* PASO 1: Generar un formato de salida automático desde listadoProductos*/


DATA ListadoProductosParaFormato;
    SET listadoProductos;
    FMTNAME = 'Productos'; ***1;
    TYPE = 'N';
    RENAME Producto = LABEL;
    RENAME Id = START;
RUN;

PROC FORMAT CNTLIN=ListadoProductosParaFormato;
RUN;
/* PASO 2: Hacer un join entre esa tabla y chucherias, para llevar el id que acabamos de generar, en reemplazo del 
nombre de la chuchería */

/* El join lo hago por la columna PRODUCTO (se llama así en ambas tablas).
Necesito ordenar primero ambas */
/*
Ya que lo hemos generado y tiene como id _N_ que es secuencial, no es necesario... esta preordenado.
PROC SORT data=listadoProductos;
 BY Producto;
RUN;
*/
PROC SORT data=DATOS.chucherias;
 BY Producto;
RUN;

/* Ya puedo hacer el merge/JOIN */
DATA chucheriasProcesadas;
	MERGE DATOS.chucherias listadoProductos;
	BY Producto;
	DROP Producto;
/* Una vez hecho esto, aplicar el formato que hemos creado en automático al nuevo campo ID en chucherias*/
	FORMAT ID productos.;
	RENAME ID=Producto;
RUN;


/* LO MISMO PARA COLOR */


PROC FREQ data = DATOS.chucherias;
 TABLE color / out = ListadoColores (DROP=PERCENT COUNT);
RUN;

DATA ListadoColores;
    SET ListadoColores;
    ID = _N_;
RUN;

DATA ListadoColoresParaFormato;
    SET ListadoColores;
    FMTNAME = 'Colores';
    TYPE = 'N';
    RENAME Color = LABEL;
    RENAME Id = START;
RUN;

PROC FORMAT CNTLIN=ListadoColoresParaFormato;
RUN;

PROC SORT data=chucheriasProcesadas;
 BY Color;
RUN;

DATA chucheriasProcesadas;
	MERGE chucheriasProcesadas ListadoColores;
	BY Color;
	
	fechaNueva = input(Fecha, ANYDTDTE10.);
	FORMAT fechaNueva DDMMYYD10. ;
	DROP Fecha;
	RENAME fechaNueva = Fecha;

	DROP Color;
	FORMAT ID Colores.;
	RENAME ID=Color;
RUN;

/* Combinamos esta tabla con la de clientes con peso */


PROC SORT data=chucheriasProcesadas;
 BY Cliente;
RUN;

PROC SORT data=DATOS.clientesconpeso;
 BY Identificador;
RUN;

DATA DATOS.chucheriasFinal ;
	MERGE chucheriasProcesadas DATOS.clientesconpeso (RENAME=(Identificador=Cliente));
	BY Cliente;
	DROP Nombre;
RUN;




