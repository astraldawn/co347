%%% Mark Lee (cyl113)
%%% Links can be lossy (given reliability param)
-module(lossyp2plinks).
-export([start/0]).

start() ->
  receive
    {bind, BEB, LinkRel} ->
      % Bind BEB, then wait for the link map
      wait_links(BEB, LinkRel)
  end.

wait_links(BEB, LinkRel) ->
% Wait for map of links (to the PL components of other processes)
  receive
    {pl_link_map, SYS, LinkMap} ->
      % Everything is ready
      SYS ! pl_link_received,
      next(BEB, LinkMap, LinkRel)
  end.

next(BEB, LinkMap, LinkRel) ->
  receive
    {pl_transmit, Message} ->
      % Deliver message to BEB
      BEB ! {pl_deliver, Message};
    {pl_send, Dest, Message} ->
      % Random number
      Send = random:uniform(100),
      % Simulate unreliable tranmission across network
      if 
        Send =< LinkRel ->
          % Send a message to the PL component of dest process
          Dest_PL_ID = maps:get(Dest, LinkMap),
          % Override to send the first message
          Dest_PL_ID ! {pl_transmit, Message};
        true -> ok
      end
  end,
  next(BEB, LinkMap, LinkRel).