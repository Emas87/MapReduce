%%%-------------------------------------------------------------------
%%% @author ema87
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Oct 2020 9:26 PM
%%%-------------------------------------------------------------------
-module(mapreduce_supervisor).
-author("ema87").

-behaviour(supervisor).

%% API
-export([start_link/0, start_link_shell/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API functions
%%%===================================================================

%% @doc Starts the supervisor
-spec(start_link() -> {ok, Pid :: pid()} | ignore | {error, Reason :: term()}).
start_link_shell() ->
  {ok, Pid} = supervisor:start_link({global, ?SERVER}, ?MODULE, []),
  unlink(Pid).
start_link() ->
  supervisor:start_link({global, ?SERVER}, ?MODULE, []).

%%%===================================================================
%%% Supervisor callbacks
%%%===================================================================

%% @private
%% @doc Whenever a supervisor is started using supervisor:start_link/[2,3],
%% this function is called by the new process to find out about
%% restart strategy, maximum restart frequency and child
%% specifications.
-spec(init(Args :: term()) ->
  {ok, {SupFlags :: {RestartStrategy :: supervisor:strategy(),
    MaxR :: non_neg_integer(), MaxT :: non_neg_integer()},
    [ChildSpec :: supervisor:child_spec()]}}
  | ignore | {error, Reason :: term()}).
init([]) ->
  io:format("~p (~p) Iniciando Supervisor ... ~n", [{global, ?MODULE}, self()]),
  RestartStrategy = one_for_one,
  MaxRestarts = 3,
  MaxSecondsBetweenRestarts = 10,
  Flags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
  Restart = permanent,
  Shutdown = infinity,
  Type = worker,
  ChildSpecifications = {mapreduceServerId, {servidor, start_link, []}, Restart, Shutdown, Type, [servidor]},
  {ok, {Flags, [ChildSpecifications]}}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
