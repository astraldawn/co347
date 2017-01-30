
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(client).
-export([start/0]).
 
start() -> 
  receive 
    {bind, S} -> next(S) 
  end.
 
next(S) ->
  Rand_req = rand:uniform(2),
  Rand_sleep = rand:uniform(10),
  if
    Rand_req == 1 -> S ! {circle, 1.0, self()};
    true -> S ! {square, 1.0, self()}
  end,
  receive 
    {result, Area} -> 
      io:format("ID: ~p, Area is ~p~n", [self(), Area]) 
  end,
  timer:sleep(1000 * Rand_sleep),
  next(S).

