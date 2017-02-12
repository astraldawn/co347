%%% Mark Lee (cyl113)
 
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  PIDs = [list_to_atom(integer_to_list(X)) || X <- lists:seq(1, N)],
  [init_process(PID, PIDs) || PID <- PIDs],
  wait_links(maps:new(), 0, N),
  receive
    {setup_done, LinkMap} -> [start_task1(PID, LinkMap) || PID <- PIDs]
  end.

init_process(CID, PIDs) ->
% Initialise and register processes
  register(CID, spawn(process, start, [])),
  CID ! {create_pl, self(), CID, PIDs}.

wait_links(LinkMap, Count, N) ->
% Wait for processes to return the IDs of its PL component
  if 
    Count == N ->
      [X ! {pl_link_map, self(), LinkMap} || X <- maps:values(LinkMap)],
      wait_links_received(0, N, LinkMap);
    true -> 
      receive
        {pl_link, PID, PL_ID} ->
          NewLinkMap = maps:put(PID, PL_ID, LinkMap),
          wait_links(NewLinkMap, Count+1, N)
      end
  end.

wait_links_received(Count, N, LinkMap) ->
% Wait for all PLs to confirm they have received link mapping
  if
    Count == N ->
      self() ! {setup_done, LinkMap};
    true ->
      receive
        pl_link_received -> wait_links_received(Count+1, N, LinkMap)
      end
  end.

start_task1(CID, LinkMap) ->
% Start the task by using pl_deliver to PL components
  PL_ID = maps:get(CID, LinkMap),
  Message = {task1, start, 0, 1000},
  PL_ID ! {pl_send, CID, Message}.
