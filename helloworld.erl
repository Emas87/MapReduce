%%%-------------------------------------------------------------------
%%% @author ema87
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Sep 2020 9:16 AM
%%%-------------------------------------------------------------------
%% code:add_pathz("out/production/trabajo").
-module(helloworld).
-author("ema87").

%% API
-export([print_hello/0]).

print_hello() ->
  io:format("Hello World ~n").
