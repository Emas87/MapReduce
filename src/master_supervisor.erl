%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Nov 2020 01:43 PM
%%%-------------------------------------------------------------------
-module(master_supervisor).
-author("jdsalazar").

%% API
-export([start_link/0, init/1]).
-behaviour(supervisor).


start_link() ->
  io:format("starting master_supervisor... ~n"),
  supervisor:start_link({local, master_supervisor}, ?MODULE, []).

init([]) ->
  MaxRestart = 1,
  MaxTime = 3600,
  {ok, {{one_for_all, MaxRestart, MaxTime},
    [{handler_server,
      {handler_server, start_link, [self()]},
      permanent,
      5000, % Shutdown time
      worker,
      [handler_server]}]}}.