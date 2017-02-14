%%% Mark Lee (cyl113)
-module(beb).
-export([start/0]).

start() ->
  receive
    {bind, Processes, App, PL} -> next(Processes, App, PL)
  end.

next(Processes, App, PL) ->
  receive
    {beb_broadcast, Message} ->
      [ PL ! {pl_send, Q, Message} || Q <- Processes];
    {pl_deliver, Message} ->
      App ! {beb_deliver, Message}
  end,
  next(Processes, App, PL).