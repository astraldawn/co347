
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system1).
-export([start/0]).
 
start() ->
  S  = spawn(server, start, []),
  N = 10,
  lists:map(
    fun(Num) ->
        C = spawn(client, start, []),
        C ! {bind, S}
    end,
    lists:seq(1, N)
    ).
