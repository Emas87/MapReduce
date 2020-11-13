%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Oct 2020 06:33 PM
%%%-------------------------------------------------------------------
-module(problema1).
-author("jdsalazar").

%% API
-export([gen_keys_map/1, gen_keys_reduce/1, map/1, reduce/1]).

% gen_keys ---------------------------------------------------------
gen_keys_map({FileName, NumChunks}) ->
  Tuple_List = get_tuples_list_from_file(FileName),
  List_Length = length(Tuple_List),
  Base_num_elems = trunc(List_Length/NumChunks),
  Extra_elems = List_Length-Base_num_elems*NumChunks,
  gen_chunks(Tuple_List, Base_num_elems, Extra_elems, []).

gen_chunks(Tuple_List, Base_num_elems, Extra_elems, Chunk_List) when Extra_elems > 0 ->
  {Chunk, Rest_of_List} = lists:split(Base_num_elems+1,Tuple_List),
  gen_chunks(Rest_of_List, Base_num_elems, Extra_elems-1, [Chunk|Chunk_List]);

gen_chunks(Tuple_List, Base_num_elems, 0, Chunk_List) when length(Tuple_List) > Base_num_elems ->
  {Chunk, Rest_of_List} = lists:split(Base_num_elems,Tuple_List),
  gen_chunks(Rest_of_List, Base_num_elems, 0, [Chunk|Chunk_List]);

gen_chunks(Tuple_List, Base_num_elems, 0, Chunk_List) when length(Tuple_List) == Base_num_elems ->
  lists:reverse([Tuple_List|Chunk_List]).



gen_keys_reduce(Lotes) ->
  Flatten_List = lists:flatten(lists:append(lists:map(fun({_,X}) -> X end, Lotes))),
  Key_List = maps:to_list(lists:foldl(fun({K, V}, Map) -> maps:put(K, lists:append(maps:get(K, Map, []), [V]), Map) end, #{}, Flatten_List)),
  Key_List.

% map ---------------------------------------------------------------

map(Chunk) ->
  compute(Chunk, []).

compute(Tuple_List, Result_List) when length(Tuple_List) > 0 ->
  [Tuple | Rest_of_List] = Tuple_List,
  {Key, Num1, Num2} = Tuple,
  compute(Rest_of_List, [{Key, Num1+Num2}|Result_List]);

compute([], Result_List) -> Result_List.


% reduce ------------------------------------------------------------
reduce(Tuple) ->
  {Key, List} = Tuple,
  {Key, lists:sum(List)}.



get_tuples_list_from_file(File_Name) ->
  {ok, Tuple_List} = file:consult(File_Name),
  Tuple_List.
%  io:fwrite("~p~n", [Tuple_List]).
