
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run all processes on one node
 
-module(system1).
-export([start/0]).
 
start() ->  
  C  = spawn(client, start, []),
  S  = spawn(server, start, []),
  
  C  ! {bind, S},
  S  ! {bind, C}.

