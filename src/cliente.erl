%%%-------------------------------------------------------------------
%%% @author ema87
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. Oct 2020 6:31 PM
%%%-------------------------------------------------------------------
%%% cliente:suma(problema1, "tuplas.dat", 10, 5, 3, self()).
%%% Ver Respuesta:
%%% Paquete = receive P -> P end.
-module(cliente).
-author("ema87").

%% API
-export([suma/6]).


suma(ModuloTrabajo, FileName, NumChunks, SpecTrabajoMap, SpecTrabajoReduce, Cliente) ->
  servidor:suma(ModuloTrabajo, FileName, NumChunks, SpecTrabajoMap, SpecTrabajoReduce, Cliente).
