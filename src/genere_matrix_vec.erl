%%% @author MacBook Air <macbookair@MacBooks-MacBook-Air.local>
%%% @copyright (C) 2020, José Castro-Mora
%%% @doc
%%%    Programa para generar tuplas en el formato requerido por
%%%    la primera parte de la tarea, las tuplas consisten de 
%%%    tres números, donde el primero es la llave y los otros dos
%%%    son los valores que se deben sumar,
%%%
%%%    Ejemplo, generar un millón de tuplas con 1000 llaves
%%%    (el rango de los valores sumados no es parámetro):
%%%
%%%    > erl
%%%    1> c(tuplas).
%%%    {ok,genere}
%%%    2> genere:tuplas(1000000, 1000, "tuplas.dat").
%%%
%%% @end
%%% Created : 20 Sep 2020 by José Castro-Mora  <jose.r.castro@gmail.com>

-module(genere_matrix_vec).

-export([matrix/3, vector/2]).

matrix(M, N, Archivo) ->
    % empezar el generador de números aleatorios
    <<I1:32/unsigned-integer, I2:32/unsigned-integer, I3:32/unsigned-integer>> = crypto:strong_rand_bytes(12),
    rand:seed(exsplus, {I1, I2, I3}),
    {ok,S} = file:open(Archivo, write),
    loop(M, N, M, S).

loop(_, 0, _, S) -> file:close(S);
loop(0, 1, M, S) ->
    loop(0, 0, M, S);
loop(0, J, M, S) ->
    io:format(S, "~n", []),
    loop(M, J - 1, M, S);
loop(1, J, M, S) ->
    Rand_num = rand:uniform(100),
    if
        Rand_num > 70 ->
            io:format(S, "~p", [1]);
        true ->
            io:format(S, "~p", [0])
    end,
    loop(0, J, M, S);
loop(I, J, M, S) ->
    Rand_num = rand:uniform(100),
    if
        Rand_num > 70 ->
            io:format(S, "~p ", [1]);
        true ->
            io:format(S, "~p ", [0])
    end,
    loop(I-1, J, M, S).

vector(N, Archivo) ->
    % empezar el generador de números aleatorios
    <<I1:32/unsigned-integer, I2:32/unsigned-integer, I3:32/unsigned-integer>> = crypto:strong_rand_bytes(12),
    rand:seed(exsplus, {I1, I2, I3}),
    {ok,S} = file:open(Archivo, write),
    loopv(N, S).

loopv(0, S) -> file:close(S);
loopv(1, S) ->
    Rand_num = rand:uniform(100),
    io:format(S, "~p", [Rand_num]),
    loopv(0, S);
loopv(I, S) ->
    Rand_num = rand:uniform(100),
    io:format(S, "~p~n", [Rand_num]),
    loopv(I-1, S).


