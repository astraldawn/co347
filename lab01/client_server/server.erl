
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(server).
-export([start/0]).
 
start() ->  
  receive 
    {bind, C} -> next(C) 
  end.
 
next(C) ->
  receive
    {circle, Radius} ->  C ! {result, 3.14159 * Radius * Radius};
    {square, Side}   ->  C ! {result, Side * Side}
  end,
  next(C).

