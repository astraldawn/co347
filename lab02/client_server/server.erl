
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(server).
-export([start/0]).
 
start() ->  
  next(0).
 
next(C) ->
  receive
    {circle, Radius, CID} ->  CID ! {result, 3.14159 * Radius * Radius};
    {square, Side, CID}   ->  CID ! {result, Side * Side}
  end,
  next(C).

