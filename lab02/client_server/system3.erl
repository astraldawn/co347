
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%% run client and server on different nodes on different hosts
 
-module(system3).
-export([start/0]).
 
start() ->  
  C  = spawn('node@172.19.0.1', client, start, []),
  S  = spawn('node@172.19.0.2', server, start, []),
  
  C  ! {bind, S},
  S  ! {bind, C}.

