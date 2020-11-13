%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Nov 2020 01:52 PM
%%%-------------------------------------------------------------------
-module(worker_supervisor).
-author("jdsalazar").

%% API
-export([start_link/1, init/1]).
-behaviour(supervisor).


start_link(Server_Pid) ->
  io:format("starting worker_supervisor... ~n"),
  supervisor:start_link(?MODULE, Server_Pid).

init(Server_Pid) ->
  MaxRestart = 1,
  MaxTime = 3600,
  {ok, {{simple_one_for_one, MaxRestart, MaxTime},
    [{task_worker,
      {task_worker,start_link, [Server_Pid]},
      temporary, 5000, worker, [task_worker]}]}}.
