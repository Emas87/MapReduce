%%% @author MacBook Air <macbookair@MacBooks-MacBook-Air.local>
%%% @copyright (C) 2020, MacBook Air
%%% @doc
%%%
%%% @end
%%% Created : 19 Sep 2020 by MacBook Air <macbookair@MacBooks-MacBook-Air.local>

-module(simple).

-export([funcion/1]).

funcion(Otro) -> Otro ! "Hola! Que tal?".

