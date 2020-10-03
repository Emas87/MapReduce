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

-module(genere).

-export([tuplas/3]).

tuplas(NumTuplas, NumLlaves, Archivo) ->
    % empezar el generador de números aleatorios
    <<I1:32/unsigned-integer, I2:32/unsigned-integer, I3:32/unsigned-integer>> = crypto:strong_rand_bytes(12),
    rand:seed(exsplus, {I1, I2, I3}),
    {ok,S} = file:open(Archivo, write),
    loop(NumTuplas, NumLlaves, S).

loop(0,_,S) -> file:close(S);
loop(N, NKeys, S) when N > 0 ->
    io:format(S, "{~p,~p,~p}.~n", [rand:uniform(NKeys), rand:uniform(1000), rand:uniform(1000)]),
    loop(N-1,NKeys,S).

