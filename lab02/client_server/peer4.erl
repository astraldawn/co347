
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer4).
-export([start/0]).
 
start() -> 
  receive 
    {bind, Neighbours} -> next(Neighbours, 0, 0, null, length(Neighbours), 0) 
  end.
 
next(Neighbours, Mcount, Ccount, Parent, RepliesNeeded, CReplies) ->
  % io:format("ID ~p, RepliesNeeded ~p CReplies ~p~n", [self(), RepliesNeeded, CReplies]),
  if RepliesNeeded /= CReplies ->
    receive
      {message, Dist, Source} ->
        if
          Mcount == 0 -> 
            [Neighbour ! {message, Dist+1, self()} || Neighbour <- Neighbours, Neighbour /= Source],
            if 
              Source /= null -> Source ! child;
              true -> ok
            end,
            if
              Source /= null -> next(Neighbours, Mcount+1, Ccount, Source, RepliesNeeded-1, CReplies);
              true -> next(Neighbours, Mcount+1, Ccount, Source, RepliesNeeded, CReplies)
            end;
        true ->
          Source ! no,
          next(Neighbours, Mcount+1, Ccount, Parent, RepliesNeeded, CReplies)
        end;
      % Child message received
      child -> next(Neighbours, Mcount, Ccount+1, Parent, RepliesNeeded, CReplies+1);
      % Not a child, but send back to meet expectations
      no -> next(Neighbours, Mcount, Ccount, Parent, RepliesNeeded, CReplies+1)
  end;
  true ->
    io:format("Peer ~p Parent ~p Children ~p~n", [self(), Parent, Ccount])
  end.

