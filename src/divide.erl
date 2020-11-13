%%%-------------------------------------------------------------------
%%% @author ema87
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 12. Nov 2020 12:37 PM
%%%-------------------------------------------------------------------
-module(divide).
-author("ema87").

%% API
-export([divide_m/3, divide_v/3, get_position_list/4, get_chunk_matrix_from_file/8, get_chunk_vector_from_file/3]).

get_position_list(K, S, 0, Pos_list) ->
    {ok, Last_Position} = file:position(S, cur),
    Last_element = lists:last(Pos_list),
    Prev_list = lists:droplast(Pos_list),
    New_element = lists:append(Last_element,[Last_Position-1]),
    New_Pos_List = lists:append(Prev_list,[New_element]),
    % io:format("K reached : ~p ~n", [Position]),
    % Last_Position + 1 es la primera posicion del siguiente
    get_position_list(K, S, K, lists:append( New_Pos_List, [[Last_Position]]));
get_position_list(K, S, Count, Pos_list) ->
    {ok, MP} = re:compile("\n"),
    case file:read(S, 1) of
        eof ->
            {ok, Last_Position} = file:position(S, cur),
            Last_element = lists:last(Pos_list),
            Prev_list = lists:droplast(Pos_list),
            New_element = lists:append(Last_element,[Last_Position]),
            New_Pos_List = lists:append(Prev_list,[New_element]),
            {ok, New_Pos_List};
        {ok, Character} ->
            Is_space = string:equal(Character, " "),
            if
                Is_space ->
                    get_position_list(K, S, Count - 1, Pos_list);
                true ->
                    Match = re:run(Character, MP),
                    case Match of
                        {match, _} ->
                            % io:format("Position: ~p ~n", [file:position(S, cur)]),
                            get_position_list(K, S, Count - 1, Pos_list);
                        nomatch ->
                            get_position_list(K, S, Count, Pos_list)
                    end
            end;
        {error, Reason} ->
            io:format("Razon: ~p ~n", [Reason])
    end.

divide_m(K, Filename, N) ->
    {ok,S} = file:open(Filename, read),
    {ok, Positions_list} = get_position_list(K, S, K, [[0]]),
    % figuring out how many blocks are per row
    Blocks_per_row = N/K,
    get_all_chunks(Blocks_per_row, K, S, N, 1, 1, Positions_list).

get_all_chunks(Blocks_per_row, _, _, _, I, _, _) when I > Blocks_per_row ->
    ok;
get_all_chunks(Blocks_per_row, K, S, N, I, J, Positions_list) when J > Blocks_per_row ->
    get_all_chunks(Blocks_per_row, K, S, N, I + 1, 1, Positions_list);
get_all_chunks(Blocks_per_row, K, S, N, I, J, Positions_list) ->
    Chunk = get_chunk_matrix_from_file(S, I, J, K, Blocks_per_row, [], 1, Positions_list),
    io:format("Chunk i=~p, j=~p: ~p ~n", [I,J,Chunk]),
    get_all_chunks(Blocks_per_row, K, S, N, I, J + 1, Positions_list).


divide_v(K, Filename, N) ->
    {ok,S} = file:open(Filename, read),
    {ok, Positions_list} = get_position_list(K, S, K, [[0]]),
    % figuring out how many blocks are per row
    Blocks_per_row = N/K,
    get_all_chunks(Blocks_per_row, K, S, N, Positions_list, 1).

get_all_chunks(Blocks_per_row, _, _, _, _, Iteration) when Iteration > Blocks_per_row ->
    ok;
get_all_chunks(Blocks_per_row, K, S, N, Positions_list, Iteration) ->
    Chunk = get_chunk_vector_from_file(S, Iteration, Positions_list),
    io:format("Chunk i=~p: ~p ~n", [Iteration,Chunk]),
    get_all_chunks(Blocks_per_row, K, S, N, Positions_list, Iteration+1).

get_chunk_matrix_from_file(_, _, _, K, _, Chunk_list, Iteration, _) when Iteration > K->
    Chunk_list;
get_chunk_matrix_from_file(S, ChunkI, ChunkJ, K, Blocks_per_row, Chunk_list, Iteration, Positions_list) ->
    Position_in_list = (ChunkJ-1) + (ChunkI-1) * Blocks_per_row * K + ((Iteration-1)*Blocks_per_row) + 1,
    [Starting_pos|Ending_pos_list] = lists:nth(round(Position_in_list), Positions_list),
    [Ending_pos|_] = Ending_pos_list,
    {ok, String} = file:pread(S, Starting_pos, Ending_pos-Starting_pos),
    New_Chunk_list = lists:append(Chunk_list, [string:split(String, " ")]),
    get_chunk_matrix_from_file(S, ChunkI, ChunkJ, K, Blocks_per_row, New_Chunk_list, Iteration + 1, Positions_list).

get_chunk_vector_from_file(S, Iteration, Positions_list) ->
    Position_in_list = Iteration,
    [Starting_pos|Ending_pos_list] = lists:nth(round(Position_in_list), Positions_list),
    [Ending_pos|_] = Ending_pos_list,
    {ok, String} = file:pread(S, Starting_pos, Ending_pos - Starting_pos),
    New_Chunk_list = string:split(String, "\n"),
    New_Chunk_list.
