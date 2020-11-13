%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 03. Oct 2020 06:33 PM
%%%-------------------------------------------------------------------
-module(problema45).
-author("emas87").

%% API
-export([gen_keys_map/1, gen_keys_reduce/1, map/4, reduce/1, process_final_result/1, get_position_list/4, test/0]).

% gen_keys ---------------------------------------------------------
gen_keys_map({N, K}) ->
  Blocks_per_row = round(N/K),
  Base_num_elems = Blocks_per_row*Blocks_per_row.

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

map(Key, ChunkM, ChunkV, N) ->
  compute(Key, ChunkM, ChunkV, N).

compute(Key, ChunkM, ChunkV, N) ->
  {Key, multiplication:m_mult_v(ChunkM, ChunkV, N, 1, [])}.


% reduce ------------------------------------------------------------
reduce(Tuple) ->
  {Key, Vector_list} = Tuple,
  {Key, suma_vectores(Vector_list)}.

suma_vectores(Vector_list) when length(Vector_list) > 1 ->
  [Vector1 | Rest_of_vectors] = Vector_list,
  Suma_total = suma_vectores(Rest_of_vectors),
  suma_2_vectores(Vector1, Suma_total, []);

suma_vectores(Vector_list) ->
  [Vector | _] = Vector_list,
  Vector.

suma_2_vectores(Vector1, Vector2, Output_vector) when length(Vector1) > 0 ->
  [Value1 | Rest_vector1] = Vector1,
  [Value2 | Rest_vector2] = Vector2,
  suma_2_vectores(Rest_vector1, Rest_vector2,
    lists:append(
      Output_vector,
      [multiplication:number_to_string(
        multiplication:string_to_number(Value1) + multiplication:string_to_number(Value2))]));

suma_2_vectores([], [], Output_vector) -> Output_vector.

test() ->
  Vect_List = [["1","2","3", "4", "5", "6"],["2","2","3", "4", "5", "6"],["3","2","3", "4", "5", "6"],
    ["4","2","3", "4", "5", "6"],["5","2","3", "4", "5", "6"],["6","2","3", "4", "5", "6"]],
  suma_vectores(Vect_List).

get_tuples_list_from_file(File_Name) ->
  {ok, Tuple_List} = file:consult(File_Name),
  Tuple_List.
%  io:fwrite("~p~n", [Tuple_List]).


process_final_result(Lotes) ->
  lists:append(lists:map(fun({_,X}) -> [X] end, Lotes)).


get_position_list(K, S, Count, Pos_list) ->
  divide:get_position_list(K, S, Count, Pos_list).