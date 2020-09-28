%%%-------------------------------------------------------------------
%%% @author Emmanuel Barrantes Chaves
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 27. Sep 2020 8:00 AM
%%%-------------------------------------------------------------------
%% code:add_pathz("out/production/trabajo").
-module(trabajo).
-author("ema87").

%% API
-export([print_keys/1, numeros/0, map/1, reduce/1, main/3, gen_keys/1]).

print_keys([])-> empty;
print_keys([H|T]) ->
    {K, _, _} = H,
    io:format("Key: ~p ~n", [K]),
    print_keys(T).

numeros() -> [{1,2,3}, {2,4,5}, {3,6,7}, {4,2,3}, {5,4,5}, {6,6,7}, {7,2,3}, {8,4,5}, {9,6,7}, {10,2,3}, {20,4,5},
{21,6,7}, {30,2,3}, {40,4,5}, {50,6,7}, {11,2,3}, {21,4,5}, {31,6,7}, {41,2,3}, {51,4,5}, {12,2,3}, {22,4,5},
{32,6,7}, {42,2,3}, {52,4,5}, {13,2,3}, {23,4,5}, {33,6,7}, {43,2,3}, {53,4,5}, {14,2,3}, {24,4,5}, {34,6,7},
{44,2,3}, {54,4,5}, {15,2,3}, {25,4,5}, {35,6,7}, {45,2,3}, {55,4,5}, {16,2,3}, {26,4,5}, {36,6,7}, {46,2,3},
{56,4,5}, {17,2,3}, {27,4,5}, {37,6,7}, {47,2,3}, {57,4,5}, {18,2,3}, {28,4,5}, {38,6,7}, {48,2,3}, {58,4,5},
{19,2,3}, {29,4,5}, {39,6,7}, {49,2,3}, {59,4,5}].

map(Llave) ->
    {Num1, Num2} = get_numbers(Llave, numeros()),
    Suma = if
               Num1 == notFound -> invalidKey;
               Num2 == notFound -> invalidKey;
               true -> Num1 + Num2
           end,
    io:format("Suma: ~p ~n", [Suma]),
    Suma.

get_numbers(_, []) -> {notFound, notFound};
get_numbers(Llave, [H|T]) ->
    {Key, Num1, Num2} = H,
    {Number1, Number2} = if
        Key == Llave -> {Num1, Num2};
        Key =/= Llave -> get_numbers(Llave, T)
    end,
    {Number1, Number2}.

gen_keys(SpecLotes) ->
    CantidadNumeros = length(numeros()),
    CantidadLlaves = CantidadNumeros / SpecLotes,
    lists:seq(1,CantidadLlaves).

main(NumMap, NumReduce, Chunks) ->
    CantidadNumeros = length(numeros()),
    SpecLotes = CantidadNumeros / NumReduce,
    mapreduce:start(trabajo, NumMap, SpecLotes , self()).

reduce(Lotes) -> ok.



