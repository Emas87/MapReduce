%%%-------------------------------------------------------------------
%%% @author jdsalazar
%%% @copyright (C) 2020, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 11. Nov 2020 01:56 PM
%%%-------------------------------------------------------------------
-module(handler_server).
-author("jdsalazar").

%% API
-behaviour(gen_server).

-export([start_link/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3, terminate/2]).
-export([suma/5, kill_worker/1, mult/5]).


-define(SPEC(),
  {worker_supervisor,
    {worker_supervisor, start_link, [self()]},
    temporary,
    10000,
    supervisor,
    [worker_supervisor]}).

-record(state, {master_sup,
  worker_sup,
  mod_trab,
  spec_map,
  spec_reduce,
  map_status = pending,
  reduce_status = pending,
  map_refs,         %%TODO
  reduce_refs,      %%TODO
  map_worker_regsitry,  %%TODO                 %%map
  reduce_worker_regsitry, %%TODO
  map_batches,    %%TODO                    %%list
  reduce_batches, %%TODO
  map_results,    %%TODO                %%list
  reduce_results, %%TODO
  available_map_batches,    %%TODO          %%list:seq
  available_reduce_batches, %%TODO
  map_workers_active_cnt,   %%TODO                 %%int
  reduce_workers_active_cnt,
  send_to,
  killable_map,
  killable_reduce}).  %%int


start_link(Master_Sup_Pid) ->
  io:format("starting handler_server ... ~n"),
  gen_server:start_link({local, handler_server}, handler_server, Master_Sup_Pid, []).


init(Master_Sup_Pid) ->
  self() ! {start_worker_supervisor, Master_Sup_Pid},
  {ok, #state{master_sup=Master_Sup_Pid}}.


suma(ModuloTrabajo, FileName, NumChunks, SpecMap, SpecReduce) ->
  gen_server:call(handler_server, {suma, ModuloTrabajo, FileName, NumChunks, SpecMap, SpecReduce}).

mult(ModuloTrabajo, FileNameM,  FileNameV, N, K) ->
  gen_server:call(handler_server, {mult, ModuloTrabajo, FileNameM, FileNameV, N, K}).

kill_worker(map_task) ->
  gen_server:call(handler_server, {kill_worker, map_task});

kill_worker(reduce_task) ->
  gen_server:call(handler_server, {kill_worker, reduce_task}).




assign_batch_to_worker(Wrk_Pid, WrkMap, AvBat, Btchs, Refs, Killable_List) ->
  io:format("assigning batch to worker: ~p... ~n", [Wrk_Pid]),
  if
    length(AvBat) == 0 ->
      io:format("no more tasks for worker: ~p... ~n", [Wrk_Pid]),
      {no_more_tasks, WrkMap, AvBat, Refs, Killable_List};
    true ->  %%length(AvBat) > 0
      case maps:is_key(Wrk_Pid, WrkMap) of
        true ->
          [H|T] = AvBat,
          io:format("assigning batch: ~p to worker: ~p... ~n", [H, Wrk_Pid]),
          {lists:nth(H, Btchs), maps:put(Wrk_Pid, H, WrkMap), T, Refs, Killable_List};
        false ->
          io:format("worker: ~p was NOT registered, registiring right now so tasks can be assigned... ~n", [Wrk_Pid]),
          Ref = erlang:monitor(process, Wrk_Pid),
          Refs = gb_sets:add(Ref,Refs),
          [H|T] = AvBat,
          io:format("assigning batch: ~p to new registered worker: ~p... ~n", [H, Wrk_Pid]),
          {lists:nth(H, Btchs), maps:put(Wrk_Pid, H, WrkMap), T, Refs, [Wrk_Pid|Killable_List]}
      end
  end.

assign_batch_to_worker(mult, Wrk_Pid, WrkMap, AvBat, MapParameters, Refs, Killable_List) ->
  io:format("assigning batch to worker: ~p... ~n", [Wrk_Pid]),
  if
    length(AvBat) == 0 ->
      io:format("no more tasks for worker: ~p... ~n", [Wrk_Pid]),
      {no_more_tasks, WrkMap, AvBat, Refs, Killable_List};
    true ->  %%length(AvBat) > 0
      % Btchs = [Key, M, V , K, Blocks_per_row, Positions_listM, Positions_listV]
       [Keys, M, V , K, Blocks_per_row, M_Positions_list, V_Positions_list] = MapParameters,
      case maps:is_key(Wrk_Pid, WrkMap) of
        true ->
          [H|T] = AvBat,
          Key = lists:nth(H, Keys),
          Btch = [Key, M, V , K, Blocks_per_row, M_Positions_list, V_Positions_list],
          io:format("assigning batch: ~p to worker: ~p... ~n", [H, Wrk_Pid]),
          {Btch, maps:put(Wrk_Pid, H, WrkMap), T, Refs, Killable_List};
        false ->
          io:format("worker: ~p was NOT registered, registiring right now so tasks can be assigned... ~n", [Wrk_Pid]),
          Ref = erlang:monitor(process, Wrk_Pid),
          Refs = gb_sets:add(Ref,Refs),
          [H|T] = AvBat,
          Key = lists:nth(H, Keys),
          Btch = [Key, M, V , K, Blocks_per_row, M_Positions_list, V_Positions_list],
          io:format("assigning batch: ~p to new registered worker: ~p... ~n", [H, Wrk_Pid]),
          {Btch, maps:put(Wrk_Pid, H, WrkMap), T, Refs, [Wrk_Pid|Killable_List]}
      end
  end.


create_workers(0, Refs, WrkMap, _, Active, _, _, _) ->
  {Refs, WrkMap, Active};
create_workers(Worker_Spec, Refs, WrkMap, WrkSup, Active, ModuloTrabajo, Task_Type, Name_Helper) ->
  NameAux = string:concat(Name_Helper, "_worker_"),
  Name1 = string:concat(NameAux, integer_to_list(Worker_Spec)),
  Name = list_to_atom(Name1),
  {ok, Pid} = supervisor:start_child(WrkSup, [Name, ModuloTrabajo, Task_Type]),
  io:format("Worker: ~p created, ~p left ... ~n", [Pid, Worker_Spec - 1]),
  Ref = erlang:monitor(process, Pid),
  create_workers(Worker_Spec - 1, gb_sets:add(Ref,Refs), maps:put(Pid, 0, WrkMap), WrkSup, Active + 1, ModuloTrabajo, Task_Type, Name_Helper).


update_execution_status(map_task, Batches, Results) ->
  if
    length(Results) == length(Batches) ->
      io:format("Updating MAP status to COMPLETED, requesting EXECUTE_REDUCE to handler_server ... ~n"),
      gen_server:cast(handler_server, execute_reduce),
      {completed, Results};
    true ->  %%length(Results) < length(Batches)
      io:format("Updating MAP status to PROCESSING, ~p batches left to complete ... ~n", [length(Batches) - length(Results)]),
      {processing, Results}
  end;
update_execution_status(reduce_task, Batches, Results) ->
  if
    length(Results) == length(Batches) ->
      io:format("Updating REDUCE status to COMPLETED, requesting SEND_RESULT to handler_server ... ~n"),
      gen_server:cast(handler_server, send_result),
      {completed, Results};
    true ->  %%length(Results) < length(Batches)
      io:format("Updating REDUCE status to PROCESSING, ~p batches left to complete ... ~n", [length(Batches) - length(Results)]),
      {processing, Results}
  end.





handle_call({mult, ModuloTrabajo, FileNameM,  FileNameV, N, K}, From, S = #state{worker_sup=WrkSup}) ->
  io:format("Operation MULT requested at handler_server... ~n"),
  MT = ModuloTrabajo,
  Blocks_per_row = round(N/K),
  SpcMp = Blocks_per_row*Blocks_per_row,
  SpcRdc = Blocks_per_row,
  io:format("generating MAP batches ... ~n"),
  {ok,M} = file:open(FileNameM, read),
  {ok,V} = file:open(FileNameV, read),
  {ok, M_Positions_list} = ModuloTrabajo:get_position_list(K, M, K, [[0]]),
  {ok, V_Positions_list} = ModuloTrabajo:get_position_list(K, V, K, [[0]]),
  % figuring out how many blocks are per row
  MapBtchs = ModuloTrabajo:gen_keys_map(Blocks_per_row),
  MapParameters = [MapBtchs, M, V , K, Blocks_per_row, M_Positions_list, V_Positions_list],
  AvMapBat = lists:seq(1, length(MapBtchs)),
  io:format("creating ~p MAP workers ... ~n", [SpcMp]),
  {Map_Refs, Map_Reg, Map_Act_Cnt} = create_workers(SpcMp, gb_sets:empty(), #{}, WrkSup, 0, ModuloTrabajo, map_task, "map_@task"),
  {reply, ok, S#state{mod_trab = MT, spec_map=SpcMp, spec_reduce=SpcRdc, map_status = processing, reduce_status = pending,
    map_refs = Map_Refs, map_worker_regsitry = Map_Reg, map_batches=MapParameters, map_results = [], available_map_batches=AvMapBat,
    map_workers_active_cnt= Map_Act_Cnt, send_to = From, killable_map = maps:keys(Map_Reg)}};

handle_call({suma, ModuloTrabajo, FileName, NumChunks, SpecMap, SpecReduce}, From, S = #state{worker_sup=WrkSup}) ->
  io:format("Operation SUMA requested at handler_server... ~n"),
  MT = ModuloTrabajo,
  SpcMp = SpecMap,
  SpcRdc = SpecReduce,
  io:format("generating MAP batches ... ~n"),
  MapBtchs = ModuloTrabajo:gen_keys_map({FileName, NumChunks}),
  AvMapBat = lists:seq(1, length(MapBtchs)),
  io:format("creating ~p MAP workers ... ~n", [SpecMap]),
  {Map_Refs, Map_Reg, Map_Act_Cnt} = create_workers(SpecMap, gb_sets:empty(), #{}, WrkSup, 0, ModuloTrabajo, map_task, "map_task"),
  {reply, ok, S#state{mod_trab = MT, spec_map=SpcMp, spec_reduce=SpcRdc, map_status = processing, reduce_status = pending,
    map_refs = Map_Refs, map_worker_regsitry = Map_Reg, map_batches=MapBtchs, map_results = [], available_map_batches=AvMapBat,
    map_workers_active_cnt= Map_Act_Cnt, send_to = From, killable_map = maps:keys(Map_Reg)}};


%%handle_call({request_task, map_task}, From, S = #state{map_worker_regsitry = MapReg, available_map_batches = AvMapBat,
%%  map_batches = MapBtchs, map_status = Mp_St, map_refs = MapRefs, killable_map = KillMap}) ->
%%  {From_Pid, _} = From,
%%  io:format("MAP task requested from worker: ~p ... ~n", [From_Pid]),
%%  if
%%    Mp_St == pending ->
%%      io:format("MAP tasks NOT READY, WAIT response ... ~n"),
%%      {reply, not_ready_wait, S};
%%    Mp_St == completed ->
%%      io:format("MAP tasks already COMPLETED, no_more_tasks response ... ~n"),
%%      {reply, no_more_tasks, S};
%%    true ->
%%      io:format("MAP available batches (prior to assigning): ~p ... ~n", [length(AvMapBat)]),
%%      {Response, MR, AMB, MpRfs, Kll_Mp} = assign_batch_to_worker(From_Pid, MapReg, AvMapBat, MapBtchs, MapRefs, KillMap),
%%      io:format("MAP available batches (after assigning): ~p ... ~n", [length(AMB)]),
%%      {reply, Response, S#state{map_worker_regsitry = MR, available_map_batches = AMB, map_refs = MpRfs, killable_map = Kll_Mp}}
%%  end;

handle_call({request_task, map_task}, From, S = #state{map_worker_regsitry = MapReg, available_map_batches = AvMapBat,
  map_batches = MapParameters, map_status = Mp_St, map_refs = MapRefs, killable_map = KillMap}) ->
  {From_Pid, _} = From,
  io:format("MAP task requested from worker: ~p ... ~n", [From_Pid]),
  if
    Mp_St == pending ->
      io:format("MAP tasks NOT READY, WAIT response ... ~n"),
      {reply, not_ready_wait, S};
    Mp_St == completed ->
      io:format("MAP tasks already COMPLETED, no_more_tasks response ... ~n"),
      {reply, no_more_tasks, S};
    true ->
      io:format("MAP available batches (prior to assigning): ~p ... ~n", [length(AvMapBat)]),
      {Response, MR, AMB, MpRfs, Kll_Mp} = assign_batch_to_worker(mult, From_Pid, MapReg, AvMapBat, MapParameters, MapRefs, KillMap),
      io:format("MAP available batches (after assigning): ~p ... ~n", [length(AMB)]),
      {reply, Response, S#state{map_worker_regsitry = MR, available_map_batches = AMB, map_refs = MpRfs, killable_map = Kll_Mp}}
  end;

handle_call({request_task, reduce_task}, From, S = #state{reduce_worker_regsitry = RdcReg, available_reduce_batches = AvRdcBat,
  reduce_batches = RdcBtchs, reduce_status = Rdc_St, reduce_refs = RdcRefs, killable_reduce = KillRdc}) ->
  {From_Pid, _} = From,
  io:format("REDUCE task requested from worker: ~p ... ~n", [From_Pid]),
  if
    Rdc_St == pending ->
      io:format("REDUCE tasks NOT READY, WAIT response ... ~n"),
      {reply, not_ready_wait, S};
    Rdc_St == completed ->
      io:format("REDUCE tasks already COMPLETED, no_more_tasks response ... ~n"),
      {reply, no_more_tasks, S};
    true ->
      io:format("REDUCE available batches (prior to assigning): ~p ... ~n", [length(AvRdcBat)]),
      {Response, RR, ARB, RdcRfs, Kll_Rdc} = assign_batch_to_worker(From_Pid, RdcReg, AvRdcBat, RdcBtchs, RdcRefs, KillRdc),
      io:format("REDUCE available batches (after assigning): ~p ... ~n", [length(ARB)]),
      {reply, Response, S#state{reduce_worker_regsitry = RR, available_reduce_batches = ARB, reduce_refs = RdcRfs, killable_reduce = Kll_Rdc}}
  end;

handle_call({report_task, map_task, MapResult}, From, S = #state{map_worker_regsitry = MapReg, map_batches = MapBtchs,
  map_results = MapResults}) ->
  {From_Pid, _} = From,
  io:format("MAP task reported from worker: ~p ... ~n", [From_Pid]),
  io:format("MAP reported results (prior to updating): ~p ... ~n", [length(MapResults)]),
  {Map_Exec_St, MapRes} = update_execution_status(map_task, MapBtchs, [MapResult|MapResults]),
  io:format("MAP reported results (after update): ~p ... ~n", [length(MapRes)]),
  {reply, result_received, S#state{map_worker_regsitry = maps:put(From_Pid, 0, MapReg), map_results = MapRes, map_status = Map_Exec_St}};

handle_call({report_task, reduce_task, RdcResult}, From, S = #state{reduce_worker_regsitry = RdcReg, reduce_batches = RdcBtchs,
  reduce_results = RdcResults}) ->
  {From_Pid, _} = From,
  io:format("REDUCE task reported from worker: ~p ... ~n", [From_Pid]),
  io:format("REDUCE reported results (prior to updating): ~p ... ~n", [length(RdcResults)]),
  {Rdc_Exec_St, RdcRes} = update_execution_status(reduce_task, RdcBtchs, [RdcResult|RdcResults]),
  io:format("REDUCE reported results (after update): ~p ... ~n", [length(RdcRes)]),
  {reply, result_received, S#state{reduce_worker_regsitry = maps:put(From_Pid, 0, RdcReg), reduce_results = RdcRes,
    reduce_status = Rdc_Exec_St}};


handle_call({kill_worker, map_task}, _From, S = #state{worker_sup = WrkSup, killable_map = KillMap}) ->
  if
    length(KillMap) > 0 ->
      [ToKill|RestList] = KillMap,
      supervisor:terminate_child(WrkSup, ToKill),
      supervisor:delete_child(WrkSup, ToKill),
      {reply, killed, S#state{killable_map = RestList}};
    true ->
      {reply, no_killable_workers, S}
  end;

handle_call({kill_worker, reduce_task}, _From, S = #state{worker_sup = WrkSup, killable_reduce = KillRdc}) ->
  if
    length(KillRdc) > 0 ->
      [ToKill|RestList] = KillRdc,
      supervisor:terminate_child(WrkSup, ToKill),
      supervisor:delete_child(WrkSup, ToKill),
      {reply, killed, S#state{killable_reduce = RestList}};
    true ->
      {reply, no_killable_workers, S}
  end;


handle_call(stop, _From, State) ->
  io:format("stopping handler_server ... ~n"),
  {stop, normal, ok, State};
handle_call(_Msg, _From, State) ->
  {noreply, State}.



handle_cast(execute_reduce, S = #state{spec_reduce=SpcRdc, worker_sup=WrkSup, mod_trab = MT, map_results = MapResults}) ->
  io:format("EXECUTE_REDUCE at handler_server... ~n"),
  io:format("generating REDUCE batches ... ~n"),
  RdcBtchs = MT:gen_keys_reduce(MapResults),
  AvRdcBat = lists:seq(1, length(RdcBtchs)),
  io:format("creating ~p REDUCE workers ... ~n", [SpcRdc]),
  {Rdc_Refs, Rdc_Reg, Rdc_Act_Cnt} = create_workers(SpcRdc, gb_sets:empty(), #{}, WrkSup, 0, MT, reduce_task, "reduce_task"),
  {noreply, S#state{reduce_status = processing, reduce_refs = Rdc_Refs, reduce_worker_regsitry = Rdc_Reg, killable_reduce = maps:keys(Rdc_Reg),
    reduce_batches = RdcBtchs, reduce_results = [], available_reduce_batches = AvRdcBat, reduce_workers_active_cnt = Rdc_Act_Cnt,
    map_batches = [], map_results = [], map_refs = gb_sets:empty(), map_worker_regsitry = #{}, available_map_batches = [],
    map_workers_active_cnt = 0, killable_map = []}};

handle_cast(send_result, S = #state{mod_trab = MT, reduce_results = RdcRes, send_to = ST}) ->
  io:format("SEND_RESULT at handler_server... ~n"),
  Result = MT:process_final_result(RdcRes),
  gen_server:reply(ST, {pedido, Result}),
  io:format("RESULT sent to: ~p ... ~n", [ST]),
  {noreply, S#state{reduce_refs = gb_sets:empty(), reduce_worker_regsitry = #{}, reduce_batches = [], reduce_results = [],
    available_reduce_batches = [], reduce_workers_active_cnt = 0, map_status = pending}};

handle_cast({kill_me, Wrk_Pid}, S = #state{worker_sup = WrkSup}) ->
  io:format("KILL_ME requested from worker: ~p ... ~n", [Wrk_Pid]),
  supervisor:terminate_child(WrkSup, Wrk_Pid),
  supervisor:delete_child(WrkSup, Wrk_Pid),
  {noreply, S};

handle_cast(_Msg, State) ->
  {noreply, State}.


handle_down_worker(Pid, Reg, ActCnt, AvBtchs) ->

  case maps:is_key(Pid, Reg) of
    true ->
      Last_task = maps:get(Pid, Reg),
      if
        Last_task == 0 ->
          io:format("Dead worker was not processing any batch ... ~n"),
          {Reg, ActCnt - 1, AvBtchs};
        true -> %% Last_task > 0
          io:format("Re-assigning batch: ~p to the available batches list... ~n", [Last_task]),
          {maps:put(Pid, 0, Reg), ActCnt - 1, [Last_task | AvBtchs]}
      end;
    false ->
      io:format("Dead worker was not registered ... ~n"),
      {Reg, ActCnt, AvBtchs}
  end.



handle_info({'DOWN', _Ref, process, Pid, _}, S = #state{map_status = Mp_St, reduce_status = Rdc_St, map_worker_regsitry = MapReg,
  reduce_worker_regsitry = RdcReg, map_workers_active_cnt = MapActCnt, reduce_workers_active_cnt = RdcActCnt,
  available_map_batches = AvMapBtchs, available_reduce_batches = AvRdcBtchs, worker_sup = WrkSup, reduce_refs = RdcRefs,
  map_refs = MapRefs, mod_trab = MT}) ->
  io:format("DOWN NOTIFICATION from worker: ~p ... ~n", [Pid]),
  if
    Mp_St == completed ->
      io:format("MAP tasks completed ... ~n"),
      if
        Rdc_St == completed ->
          io:format("REDUCE tasks completed ... ~n"),
          {noreply, S};
        true ->
          io:format("REDUCE tasks NOT completed, Handling REDUCE worker down ... ~n"),
          {RR, RAC, ARB} = handle_down_worker(Pid, RdcReg, RdcActCnt, AvRdcBtchs),   %%handle down at reduce time
          if
            length(ARB) > 0 andalso RAC == 0 ->
              io:format("There are ~p available REDUCE tasks and no worker left, creating new worker... ~n", [length(ARB)]),
              {Rdc_Refs, Rdc_Reg, Rdc_Act_Cnt} = create_workers(1, RdcRefs, RR, WrkSup, RAC, MT, reduce_task, "reduce_task"),
              {noreply, S#state{reduce_worker_regsitry = Rdc_Reg, reduce_workers_active_cnt = Rdc_Act_Cnt,
                reduce_refs = Rdc_Refs, available_reduce_batches = ARB, killable_reduce = maps:keys(Rdc_Reg)}};
            true ->
              {noreply, S#state{reduce_worker_regsitry = RR, reduce_workers_active_cnt = RAC, available_reduce_batches = ARB}}
          end
      end;
    true ->
      io:format("MAP tasks NOT completed, Handling MAP worker down ... ~n"),
      {MR, MAC, AMB} = handle_down_worker(Pid, MapReg, MapActCnt, AvMapBtchs),     %%handle down at map time
      if
        length(AMB) > 0 andalso MAC == 0 ->
          io:format("There are ~p available MAP tasks and no worker left, creating new worker... ~n", [length(AMB)]),
          {Map_Refs, Map_Reg, Map_Act_Cnt} = create_workers(1, MapRefs, MR, WrkSup, MAC, MT, map_task, "map_task"),
          {noreply, S#state{map_worker_regsitry = Map_Reg, map_workers_active_cnt = Map_Act_Cnt,
            map_refs = Map_Refs, available_map_batches = AMB, killable_map = maps:keys(Map_Reg)}};
        true ->
          {noreply, S#state{map_worker_regsitry = MR, map_workers_active_cnt = MAC, available_map_batches = AMB}}
      end
  end;

handle_info({start_worker_supervisor, Master_Sup_Pid}, S = #state{}) ->
  io:format("requesting START of worker_supervisor from handler_server... ~n"),
  {ok, Worker_Sup_Pid} = supervisor:start_child(Master_Sup_Pid, ?SPEC()),
  link(Worker_Sup_Pid),
  {noreply, S#state{worker_sup=Worker_Sup_Pid}};

handle_info(_Info, State) ->
  {noreply, State}.



code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.
