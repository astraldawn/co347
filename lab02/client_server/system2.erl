
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

%%$ run client and server on different nodes on local host
 
-module(system2).
-export([start/0]).
 
start() ->  
  C  = spawn('node1@localhost.localdomain', client, start, []),
  S  = spawn('node2@localhost.localdomain', server, start, []),
  
  C  ! {bind, S},
  S  ! {bind, C}.

