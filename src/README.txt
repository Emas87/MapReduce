Estudiantes:

Froilán Moya
José Daniel Salazar
Emmanuel Barrantes


Solución al Problema #1

Terminamos de implementar el archivo "mapreduce.erl", pero para no caerle encima hicimos una copia que fue la que modificamos "mapreduce_modified.erl" y este último es el que hay que usar en esta solución.
El archivo que implementa las funciones de "gen_keys", "map" y "reduce" para el problema específico se llama "problema1.erl".

Estos 2 archivos son los que hay que compilar para correr la solución.



La cantidad de parámetros de "mapreduce_modificed:start" aumentó a 6 parámetros:

ModuloTrabajo: Mismo significado que en el arhcivo "mapreduce.erl" original.

FileName: El archivo de donde se van a leer las tuplas de la forma {Key, Num1, Num2} que van a ser la entrada del problema.

NumChunks: La cantidad de chunks en que se va a dividir la lista de tuplas leída de FileName, cada uno de estos chunks va a ser suministrado a una tarea Map.

SpecTrabajoMap: Mismo significado que el parámetro "SpecTrabajo" en el arhcivo "mapreduce.erl" original, que sería el número de workers a crear en el nodo local, o una lista de tuplas donde se indica el número de workers por cada nodo.

SpecTrabajoReduce: Homólogo al parámetro anterior, pero en este caso es para indicar el número de workers para ejecutar las tareas Reduce, mientras que el parámetro anterior serían los workers que ejecutarían las tareas Map.

Cliente: Mismo significado que en el arhcivo "mapreduce.erl" original.

Problema #2
Para correr se debe usar el servidor, luego ejecutar el cliente, esperar la respuesta y detener el servidor:

>servidor:start_link().
>cliente:suma(problema1, "tuplas.dat", 10, 5, 3, self()).
>receive P -> P end.
> servidor:stop().

Problema #3
Para correr se debe usar el sistema, luego ejecutar el cliente, esperar la respuesta y detener el sistema,
(Al usar el comando del cliente se puede usar valores trampa, para povocar un fallo, la aplicacion va a seguir ejecutandose correctamente, si luego se pasa valores correctos,
el resultado va a ser correcto):

>sistema:start().
>cliente:suma(problema1, "tuplas.dat", 10, 5, 3, self()).
>receive P -> P end.
> sistema:stop().

Prueba de falla:
>sistema:start().
>cliente:suma(problema1, "tuplas.dat", valor, malo, falla, self()).
% Aqui ya se usan valores correctos de nuevo, y debe funcionar bien.
>cliente:suma(problema1, "tuplas.dat", 10, 5, 3, self()).
>receive P -> P end.
> sistema:stop().




PROBLEMA 3


application:start(suma_app).


handler_server:suma(problema1, "tuplas.dat", 10, 3, 2).


handler_server:kill_worker(map_task).

handler_server:kill_worker(reduce_task).


application:stop(suma_app).



PROBLEMA 45


application:start(suma_app).


handler_server:mult(problema45, "matrix2.dat", "vector2.dat", 6, 2).

receive P -> P end.


handler_server:kill_worker(map_task).

handler_server:kill_worker(reduce_task).


application:stop(suma_app).
