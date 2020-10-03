%%% File    : primos.erl
%%% Author  : Jose Castro <jose.r.castro@gmail.com>
%%% Description : 
%%% Created :  9 Sep 2009 by Jose Castro <>

-module(primos).

-export([gen_keys/1, map/1, reduce/1]).

% gen_keys ---------------------------------------------------------
gen_keys({NumStrips,Maximum}) -> gen_strips(2, Maximum, 0, NumStrips, []).

gen_strips(_, _, NumStrips, NumStrips, Result) -> Result;
gen_strips(I, Max, Strip, NumStrips, Result) ->
    Rem  = (Max-2) rem NumStrips,
    Size = if
	       Strip =< Rem -> (Max-2) div NumStrips + 1;
	       true         -> (Max-2) div NumStrips
	   end,
    gen_strips(I+Size, Max, Strip+1, NumStrips, [{I,I+Size-1}|Result]).

% map ---------------------------------------------------------------
map({Min, Max}) ->
    gen_primes(Min, Max, []).

gen_primes(I, Max, Primes) when I > Max -> Primes;
gen_primes(I, Max, Primes) ->
    case is_prime(I) of
	true  -> gen_primes(I+1, Max, [I|Primes]);
	false -> gen_primes(I+1, Max, Primes)
    end.

is_prime(I) -> is_prime(2, math:sqrt(I), I).

is_prime(I, Sqrt, _) when I > Sqrt -> true;
is_prime(I, Sqrt, Num) ->
    if
	(Num rem I) =:= 0 ->
	    false;
	true ->
	    is_prime(I+1, Sqrt, Num)
    end.

% reduce ------------------------------------------------------------
reduce(List) -> lists:sort(lists:append(lists:map(fun({_,X}) -> X end, List))).
