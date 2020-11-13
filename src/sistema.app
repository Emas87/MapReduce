%%%-------------------------------------------------------------------
%%% @author ema87
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 07. Oct 2020 9:21 PM
%%%-------------------------------------------------------------------
{application, sistema, [
  {description, "MapReduce system that distribute sums of numbers, and they are summed in reduce by key"},
  {vsn, "1"},
  {module, {sistema, mapreduce_supervisor, servidor, cliente, problema1, mapreduce_modified}},
  {registered, []},
  {applications, [kernel, stdlib]},
  {mod, {sistema, []}},
  {env, []}
]}.