%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Nov 2020 08:38 AM
%%%-------------------------------------------------------------------
-module(suma_app).
-author("jdsalazar").

%% API
-behaviour(application).

-export([start/2, stop/1, suma/5]).

start(_Type, _Args) ->
  io:format("starting suma_app... ~n"),
  master_supervisor:start_link().

stop(_State) ->
  io:format("stopping suma_app... ~n"),
  ok.

suma(ModuloTrabajo, FileName, NumChunks, SpecMap, SpecReduce) ->
  gen_Server:call(handler_server, {ModuloTrabajo, FileName, NumChunks, SpecMap, SpecReduce}).