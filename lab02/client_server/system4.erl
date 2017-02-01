
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system4).
-export([start/0]).
 
start() ->
  N = 10,
  NeighbourList = [
    [2, 7], [1, 3, 4], [2, 4, 5], [2, 3, 6], [3],
    [4], [1, 8], [7, 9, 10], [8, 10], [8, 9]
  ],
  Procs = [spawn(peer3, start, []) || _ <- lists:seq(1, N)],
  lists:map(
    fun(Num) ->
        Neighbours = [lists:nth(X, Procs) || X <- lists:nth(Num,NeighbourList)],
        lists:nth(Num, Procs) ! {bind, Neighbours}
    end,
    lists:seq(1, N)),
  Start = lists:nth(5, Procs),
  Start ! {message, 0, null}.


