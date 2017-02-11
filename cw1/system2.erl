%%% Mark Lee (cyl113)
 
-module(system2).
-export([start/0]).

start() ->
  N = 5,
  PIDs = [list_to_atom(integer_to_list(X)) || X <- lists:seq(1, N)],
  [init_process(Num, PIDs) || Num <- lists:seq(1, N)],
  [start_task1(Num, PIDs) || Num <- lists:seq(1, N)].

init_process(Num, PIDs) ->
% Initialise and register processes
  CID = lists:nth(Num, PIDs),
  register(CID, spawn(process, start, [])),
  CID ! {bind, CID, PIDs}.

start_task1(Num, PIDs) ->
% Start the task
  CID = lists:nth(Num, PIDs),
  CID ! {task1, start, 1000, 3000}.
  % CID ! {task1, start, 0, 3000}.
