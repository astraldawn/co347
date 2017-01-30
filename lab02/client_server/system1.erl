
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system1).
-export([start/0]).
 
start() ->
  N = 10,
  Procs = lists:map(
    fun(Num) ->
        spawn(peer1, start, [])
    end,
    lists:seq(1, N)
    ),
  lists:map(
    fun(Proc) ->
        Neighbours = [X || X <- Procs, X /= Proc],
        Proc ! {bind, Neighbours}
    end,
    Procs),
  [H|T] = Procs,
  H ! {message}.


