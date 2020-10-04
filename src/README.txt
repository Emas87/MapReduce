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
