%%% Mark Lee (cyl113)
-module(beb).
-export([start/0]).

start() ->
  receive
    {bind, Processes, RB, PL} -> next(Processes, RB, PL)
  end.

next(Processes, RB, PL) ->
  receive
    {beb_broadcast, Message} ->
      [ PL ! {pl_send, Q, Message} || Q <- Processes];
    {pl_deliver, Message} ->
      RB ! {beb_deliver, Message}
  end,
  next(Processes, RB, PL).