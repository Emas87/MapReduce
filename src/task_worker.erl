%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Nov 2020 07:47 PM
%%%-------------------------------------------------------------------
-module(task_worker).
-author("jdsalazar").

%% API
-behaviour(gen_server).

-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).
-export([start_link/4]).


-define(SERVER, ?MODULE).

-record(state, {}).



start_link(Server_Pid, Name, ModuloTrabajo, Task_Type) ->
  io:format("starting task_worker name: ~p ... ~n", [Name]),
  gen_server:start_link({local, Name}, task_worker, {Server_Pid, ModuloTrabajo, Task_Type}, []).


init({Server_Pid, ModuloTrabajo, Task_Type}) ->
  io:format("INIT task_worker: ~p with task: ~p ... ~n", [self(), Task_Type]),
  self() ! {start_worker, Server_Pid, ModuloTrabajo, Task_Type},
  {ok, #state{}}.



starting(Server_Pid, ModuloTrabajo, map_task) ->
  map(Server_Pid, ModuloTrabajo);

starting(Server_Pid, ModuloTrabajo, reduce_task) ->
  reduce(Server_Pid, ModuloTrabajo).

map(Server_Pid, ModuloTrabajo) ->
  io:format("requesting map task from worker: ~p  ... ~n", [self()]),
  Response = gen_server:call(Server_Pid, {request_task, map_task}),
  process_map_response(Server_Pid, ModuloTrabajo, Response).

reduce(Server_Pid, ModuloTrabajo) ->
  io:format("requesting reduce task from worker: ~p  ... ~n", [self()]),
  Response = gen_server:call(Server_Pid, {request_task, reduce_task}),
  process_reduce_response(Server_Pid, ModuloTrabajo, Response).



process_map_response(Server_Pid, ModuloTrabajo, not_ready_wait) ->
  io:format("MAP tasks NOT READY in handler_server, waiting ~p seconds before requesting again ... ~n", [3]),
  timer:sleep(3000),
  map(Server_Pid, ModuloTrabajo);

process_map_response(Server_Pid, _, no_more_tasks) ->
  io:format("requesting KILL from map worker: ~p  ... ~n", [self()]),
  gen_server:cast(Server_Pid, {kill_me, self()});

process_map_response(Server_Pid, ModuloTrabajo, Batch) ->
  Result = ModuloTrabajo:map(Batch),
  io:format("WINDOW TO KILL MAP of ~p seconds ~n", [10]),
  timer:sleep(10000),
  io:format("WINDOW TO KILL MAP ENDS ... ~n"),
  io:format("reporting map task from worker: ~p  ... ~n", [self()]),
  gen_server:call(Server_Pid, {report_task, map_task, {Batch, Result}}),
  map(Server_Pid, ModuloTrabajo).



process_reduce_response(Server_Pid, ModuloTrabajo, not_ready_wait) ->
  io:format("REDUCE tasks NOT READY in handler_server, waiting ~p seconds before requesting again ... ~n", [3]),
  timer:sleep(3000),
  reduce(Server_Pid, ModuloTrabajo);

process_reduce_response(Server_Pid, _, no_more_tasks) ->
  io:format("requesting KILL from reduce worker: ~p  ... ~n", [self()]),
  gen_server:cast(Server_Pid, {kill_me, self()});

process_reduce_response(Server_Pid, ModuloTrabajo, Batch) ->
  Result = ModuloTrabajo:reduce(Batch),
  io:format("WINDOW TO KILL REDUCE of ~p seconds ~n", [10]),
  timer:sleep(10000),
  io:format("WINDOW TO KILL REDUCE ENDS ... ~n"),
  io:format("reporting reduce task from worker: ~p  ... ~n", [self()]),
  gen_server:call(Server_Pid, {report_task, reduce_task, {Batch, Result}}),
  reduce(Server_Pid, ModuloTrabajo).



handle_call(stop, _From, State) ->
  io:format("stopping task_worker ... ~n"),
  {stop, normal, ok, State};

handle_call(_Msg, _From, State) ->
  {noreply, State}.


handle_cast(_Msg, State) ->
  {noreply, State}.


handle_info({start_worker, Server_Pid, ModuloTrabajo, Task_Type}, S = #state{}) ->
  io:format("HANDLE INFO WORKER: starting... ~n"),
  io:format("Waiting ~p seconds before starting ... ~n", [5]),
  timer:sleep(5000),
  starting(Server_Pid, ModuloTrabajo, Task_Type),
  {noreply, S};

handle_info(_Info, State) ->
  {noreply, State}.


code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.