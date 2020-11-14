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
-export([gen_keys_map/1, gen_keys_reduce/1, map/1, reduce/1, process_final_result/1, get_position_list/4, test/0]).

% gen_keys ---------------------------------------------------------
gen_keys_map(Blocks_per_row) ->
  get_keys(Blocks_per_row, 1, 1, []).

test() ->
  Vect_List = gen_keys_map(3),
  Vect_List.

get_keys(Blocks_per_row, I, J, Key_list) when J > Blocks_per_row ->
  get_keys(Blocks_per_row, I+1, 1, Key_list);
get_keys(Blocks_per_row, I, _, Key_list) when I > Blocks_per_row ->
  Key_list;
get_keys(Blocks_per_row, I, J, Key_list) ->
  Output_list = get_keys(Blocks_per_row, I, J+1, Key_list),
  lists:append([{I,J}], Output_list).

gen_keys_reduce(Parameters) ->
  [Tuple|_] = Parameters,
  MapParameters = element(1,Tuple),
  MapResult = element(2,Tuple),
  {ReduceKey,Vector} = MapResult,
  [Key, M, V , K, Blocks_per_row, Positions_listM, Positions_listV] = MapParameters,
  lists:seq(1, length(Blocks_per_row)).
  %lists:seq(1, length(Blocks_per_row)).


% map ---------------------------------------------------------------

map([Key, M, V , K, Blocks_per_row, Positions_listM, Positions_listV]) ->
  compute(Key, M, V , K, Blocks_per_row, Positions_listM, Positions_listV).

compute(Key, M, V , K, Blocks_per_row, Positions_listM, Positions_listV) ->
  {I, J} = Key,
  ChunkM = divide:get_chunk_matrix_from_file(M, I, J, K, Blocks_per_row, [], 1, Positions_listM),
  ChunkV = divide:get_chunk_vector_from_file(V, J, Positions_listV),
  {I, multiplication:m_mult_v(ChunkM, ChunkV, K, 1, [])}.


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



process_final_result(Lotes) ->
  Lotes.


get_position_list(K, S, Count, Pos_list) ->
  divide:get_position_list(K, S, Count, Pos_list).