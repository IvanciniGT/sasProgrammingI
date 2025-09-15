

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