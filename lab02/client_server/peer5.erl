
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(peer5).
-export([start/0]).
 
start() -> 
  receive 
    {bind, Neighbours, SensorValue} -> next(Neighbours, 0, 0, null, length(Neighbours), 0, SensorValue, 0) 
  end.
 
next(Neighbours, Mcount, Ccount, Parent, RepliesNeeded, CReplies, SensorValue, SensorReplies) ->
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
              Source /= null -> next(Neighbours, Mcount+1, Ccount, Source, RepliesNeeded-1, CReplies, SensorValue, SensorReplies);
              true -> next(Neighbours, Mcount+1, Ccount, Source, RepliesNeeded, CReplies, SensorValue, SensorReplies)
            end;
          true ->
            Source ! no,
            next(Neighbours, Mcount+1, Ccount, Parent, RepliesNeeded, CReplies, SensorValue, SensorReplies)
        end;
      % Child message received
      child -> next(Neighbours, Mcount, Ccount+1, Parent, RepliesNeeded, CReplies+1, SensorValue, SensorReplies);
      % Not a child, but this is used to indicate leaf nodes
      no -> next(Neighbours, Mcount, Ccount, Parent, RepliesNeeded, CReplies+1, SensorValue, SensorReplies)
    end;
  Ccount /= SensorReplies ->
    receive
      {sensor, Value} ->
        next(Neighbours, Mcount, Ccount, Parent, RepliesNeeded, CReplies, SensorValue+Value, SensorReplies+1)
    end;
  true ->
    io:format("Peer ~p Parent ~p Children ~p SensorValue ~p~n", [self(), Parent, Ccount, SensorValue]),
    if
      Parent /= null -> Parent ! {sensor, SensorValue};
      true -> ok
    end
  end.

