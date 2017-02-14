%%% Mark Lee (cyl113)
-module(pl).
-export([start/0]).

start() ->
  receive
    {bind, BEB} ->
      % Bind BEB, then wait for the link map
      wait_links(BEB)
  end.

wait_links(BEB) ->
% Wait for map of links (to the PL components of other processes)
  receive
    {pl_link_map, SYS, LinkMap} ->
      % Everything is ready
      SYS ! pl_link_received,
      next(BEB, LinkMap)
  end.

next(BEB, LinkMap) ->
  receive
    {pl_transmit, Message} ->
      % Deliver message to BEB
      BEB ! {pl_deliver, Message};
    {pl_send, Dest, Message} ->
      % Send a message to the PL component of dest process
      Dest_PL_ID = maps:get(Dest, LinkMap),
      % Simulate tranmission across network
      Dest_PL_ID ! {pl_transmit, Message}
  end,
  next(BEB, LinkMap).