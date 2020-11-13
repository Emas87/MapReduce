%%%-------------------------------------------------------------------
%%% @author ema87
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Oct 2020 9:15 PM
%%%-------------------------------------------------------------------
-module(sistema).
-author("ema87").

-behaviour(application).

%% Application callbacks
-export([start/2, start/0, stop/0, stop/1]).

%%%===================================================================
%%% Application callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application is started using
%% application:start/[1,2], and should start the processes of the
%% application. If the application is structured according to the OTP
%% design principles as a supervision tree, this means starting the
%% top supervisor of the tree.
%%
%% @end
%%--------------------------------------------------------------------
-spec(start(StartType :: normal | {takeover, node()} | {failover, node()},
    StartArgs :: term()) ->
  {ok, pid()} |
  {ok, pid(), State :: term()} |
  {error, Reason :: term()}).
start() ->
  application:start(?MODULE).
start(_StartType, _StartArgs) ->
  mapreduce_supervisor:start_link().

%%--------------------------------------------------------------------
%% @private
%% @doc
%% This function is called whenever an application has stopped. It
%% is intended to be the opposite of Module:start/2 and should do
%% any necessary cleaning up. The return value is ignored.
%%
%% @end
%%--------------------------------------------------------------------

-spec(stop(State :: term()) -> term()).
stop() ->
  application:stop(?MODULE).
stop(_State) ->
  ok.

%%%===================================================================
%%% Internal functions
%%%===================================================================
