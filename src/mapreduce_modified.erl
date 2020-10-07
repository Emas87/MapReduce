%%%-------------------------------------------------------------------
%%% File    : mapreduce.erl
%%% Author  : Jose Castro <jose.r.castro@gmail.com>
%%% Description :
%%%
%%% Created :  5 Sep 2009 by Jose Castro <>
%%%-------------------------------------------------------------------
-module(mapreduce_modified).
-export([start/6, trabajador_map/3, trabajador_reduce/3]).

start(ModuloTrabajo, FileName, NumChunks, SpecTrabajoMap, SpecTrabajoReduce, Cliente) ->
  jefe(ModuloTrabajo, FileName, NumChunks, SpecTrabajoMap, SpecTrabajoReduce, Cliente).

% Jefe ---------------------------------------------------------------
jefe(ModuloTrabajo, FileName, NumChunks, SpecTrabajoMap, SpecTrabajoReduce, Cliente) ->

  {ListaTrabajadores, NumTrabajadores} = get_trabajadores(SpecTrabajoMap),

  Llaves     = ModuloTrabajo:gen_keys_map({FileName, NumChunks}),
  Repartidor_Map = spawn_link(fun() -> repartidor(Llaves, NumTrabajadores) end),
  Recolector_Map = spawn_link(fun() -> recolector_map(ModuloTrabajo, SpecTrabajoReduce, length(Llaves), Cliente, []) end),
  spawn_link(fun() -> spawn_trabajadores(ModuloTrabajo, Repartidor_Map, Recolector_Map, trabajador_map, ListaTrabajadores) end).

get_trabajadores(SpecTrabajo) ->
  ListaTrabajadores = lista_trabajadores(SpecTrabajo),
  NumTrabajadores   = lists:sum(lists:map(fun({_,X}) -> X end, ListaTrabajadores)),
  {ListaTrabajadores, NumTrabajadores}.

lista_trabajadores(N) when is_integer(N) -> [{node(), N}];
lista_trabajadores(L) when is_list(L)    -> L.

spawn_trabajadores(Trabajo, Repartidor, Recolector, Funcion_Trabajador, ListaTrabajadores) ->
  lists:map(
    fun({Host, N}) ->
      spawn(fun() ->
        io:format("generando ~p trabajadores en el nodo ~p\n", [N, Host]),
        crear_trabajadores_nodo({Host, N}, Trabajo, Repartidor, Recolector, Funcion_Trabajador)
            end)
    end,
    ListaTrabajadores
  ).

crear_trabajadores_nodo({_,0}, _, _, _, _) -> ok;
crear_trabajadores_nodo({Host, N}, Trabajo, Repartidor, Recolector, Funcion_Trabajador) when N > 0 ->
  spawn_link(Host, mapreduce_modified, Funcion_Trabajador, [Trabajo, Repartidor, Recolector]),
  crear_trabajadores_nodo({Host, N-1}, Trabajo, Repartidor, Recolector, Funcion_Trabajador).

% Repartidor ----------------------------------------------------------
repartidor([], 0) ->
  io:format("repartidor termino ~n"),
  finished;
repartidor([], N) when N > 0 ->
  receive
    {Worker, mas_trabajo} ->
      Worker ! no_hay,
      repartidor([], N-1)
  end;
repartidor([Llave|Llaves], NumTrabajadores) ->
  receive
    {Worker, mas_trabajo} ->
      Worker ! Llave,
      repartidor(Llaves, NumTrabajadores)
  end.

% Recolector Map----------------------------------------------------------
recolector_map(ModuloTrabajo, SpecTrabajoReduce, 0, Cliente, Lotes) ->
  io:format("recolector de map termino, generando trabajadores para reduce ~n"),

  Key_List = ModuloTrabajo:gen_keys_reduce(Lotes),

  {ListaTrabajadores, NumTrabajadores} = get_trabajadores(SpecTrabajoReduce),

  Repartidor_Reduce = spawn_link(fun() -> repartidor(Key_List, NumTrabajadores) end),
  Recolector_Reduce = spawn_link(fun() -> recolector_reduce(length(Key_List), Cliente, []) end),
  spawn_link(fun() -> spawn_trabajadores(ModuloTrabajo, Repartidor_Reduce, Recolector_Reduce, trabajador_reduce, ListaTrabajadores) end);


recolector_map(Trabajo, SpecTrabajoReduce, Pendientes, Cliente, Lotes) when Pendientes > 0 ->
  receive
    {Llave, Lote} ->
      % io:format("recolector ~p ~n", [Pendientes-1]),
      recolector_map(Trabajo, SpecTrabajoReduce, Pendientes-1, Cliente, [{Llave, Lote}| Lotes])
  end.

% Trabajador Map----------------------------------------------------------
trabajador_map(Trabajo, Repartidor, Recolector) ->
  Repartidor ! {self(), mas_trabajo},
  receive
    no_hay -> finished;
    Llave  ->
      Recolector ! {Llave, Trabajo:map(Llave)},
      trabajador_map(Trabajo, Repartidor, Recolector)
  end.



% Recolector Reduce----------------------------------------------------------
recolector_reduce(0, Cliente, Lotes) ->
  io:format("recolector de reduce termino, enviando paquete al Cliente ~n"),
  Result = lists:append(lists:map(fun({_,X}) -> [X] end, Lotes)),
  Cliente ! {pedido, Result};

recolector_reduce(Pendientes, Cliente, Lotes) when Pendientes > 0 ->
  receive
    {Llave, Lote} ->
      % io:format("recolector ~p ~n", [Pendientes-1]),
      recolector_reduce(Pendientes-1, Cliente, [{Llave, Lote}| Lotes])
  end.

% Trabajador Reduce----------------------------------------------------------
trabajador_reduce(Trabajo, Repartidor, Recolector) ->
  Repartidor ! {self(), mas_trabajo},
  receive
    no_hay -> finished;
    Llave  ->
      Recolector ! {Llave, Trabajo:reduce(Llave)},
      trabajador_reduce(Trabajo, Repartidor, Recolector)
  end.
