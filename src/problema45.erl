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
  List = get_key_lists(Parameters),
  % Dict1 = dict:from_list(List),
  Dict = initialize_dict(List, dict:new()),
  New_List = dict:to_list(Dict),
  New_List.

initialize_dict(List, Dict) when length(List) > 0 ->
  [{Key, Vector}| Rest_of_list] = List,
  Dict2 = append(Key,Vector, Dict),
  initialize_dict(Rest_of_list, Dict2);

initialize_dict([], Dict) -> Dict.

append(Key, Val, D) ->
  dict:update(Key, fun (Old) -> Old ++ [Val] end, [Val], D).

get_key_lists(Parameters) when length(Parameters) > 1->
  [Tuple| Rest_of_List] = Parameters,
  MapResult = element(2,Tuple),
  % {ReduceKey,Vector} = MapResult,
  lists:append([MapResult],get_key_lists(Rest_of_List));

get_key_lists(Parameters) ->
  [Tuple| _] = Parameters,
  % MapParameters = element(1,Tuple),
  MapResult = element(2,Tuple),
  % {ReduceKey,Vector} = MapResult,
  % [Key, M, V , K, Blocks_per_row, Positions_listM, Positions_listV] = MapParameters,
  [MapResult].

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
  Resultado = {Key, suma_vectores(Vector_list)},
  Resultado.

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
  List = get_real_result(Lotes, []),
  Dict = dict:from_list(List),
  New_List = order_dict(dict:size(Dict), Dict, [], 1),
  New_List.

order_dict(Size, Dict, Output_list, Iter) when Iter =< Size ->
  {ok, Value} = dict:find(Iter, Dict),
  New_OutputList = order_dict(Size, Dict, Output_list, Iter + 1),
  lists:append(Value, New_OutputList);

order_dict(_, _, _, _) -> [].

get_real_result(List, OutputList) when length(List) > 0 ->
  [First_Tuple| Rest_of_list] = List,
  {_, Real_result} = First_Tuple,
  New_OutputList = get_real_result(Rest_of_list, OutputList),
  lists:append([Real_result], New_OutputList);

get_real_result([], OutputList) -> OutputList.
%%Lotes = [
%%	{
%%		{1,[["0","96"],["0","69"],["80","79"]]},
%%		{1,["80","244"]}
%%	},
%%	{
%%		{2,[["98","0"],["79","159"],["60","60"]]},
%%		{2,["237","219"]}
%%	},
%%	{
%%		{3,[["0","0"],["96","0"],["0","0"]]},
%%		{3,["96","0"]}
%%	}
%%]


get_position_list(K, S, Count, Pos_list) ->
  divide:get_position_list(K, S, Count, Pos_list).