%%%-------------------------------------------------------------------
%%% @author ema
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 13. Nov 2020 12:18
%%%-------------------------------------------------------------------
-module(multiplication).
-author("ema").

%% API
-export([m_mult_v/5, test/0]).

m_mult_v(_, _, N, Iteration, Output_vector) when Iteration > N ->
  Output_vector;
m_mult_v(Matrix, Vector, N, Iteration, Output_vector) ->
  Matrix_vector = lists:nth(round(Iteration), Matrix),
  Row = v_mult_v(Matrix_vector, Vector, N, 1, 0),
  Output = lists:append(Output_vector, [number_to_string(Row)]),
  Final_vector = m_mult_v(Matrix, Vector, N, Iteration + 1, Output),
  Final_vector.

v_mult_v(_, _, N, Iteration, Sum) when Iteration > N ->
  Sum;
v_mult_v(Matrix_vector, Vector, N, Iteration, Sum) ->
  M_element = lists:nth(round(Iteration), Matrix_vector),
  V_element = lists:nth(round(Iteration), Vector),
  Suma = Sum + (string_to_number(M_element) * string_to_number(V_element)),
  Sum_final = v_mult_v(Matrix_vector, Vector, N, Iteration + 1, Suma),
  Sum_final.

test() ->
  Matrix = [["1","0","0","1","0","0"],
    ["1","1","0","0","0","1"],
    ["0","1","1","1","0","1"],
    ["0","1","1","1","0","0"],
    ["0","0","0","0","0","0"],
    ["0","0","0","1","0","0"]],
  Vector = ["80","79","59", "15", "24", "17"],
  New_vector = m_mult_v(Matrix, Vector, 6, 1, []),
  New_vector.

string_to_number(String) when is_float(String) ->
  list_to_float(String);
string_to_number(String) ->
  list_to_integer(String).

number_to_string(Number) when is_float(Number) ->
  float_to_list(Number);
number_to_string(Number) ->
  integer_to_list(Number).