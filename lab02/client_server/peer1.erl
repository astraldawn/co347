
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer1).
-export([start/0]).
 
start() -> 
  receive 
    {bind, Neighbours} -> next(Neighbours, 0) 
  end.
 
next(Neighbours, Mcount) ->
  % io:format("ID ~p, Neighbours ~p~n", [self(), Neighbours]),
  receive 
    {message, Dist} -> 
    if
      Mcount == 0 -> 
        io:format("ID: ~p, Dist: ~p~n", [self(), Dist]),
        timer:sleep(1000),
        [Neighbour ! {message, Dist+1} || Neighbour <- Neighbours];
      true -> ok
    end
  end,
  % io:format("ID: ~p, Count ~p~n", [self(), Mcount]),
  next(Neighbours, Mcount+1).

