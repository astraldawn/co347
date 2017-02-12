%%% Mark Lee (cyl113)
-module(pl).
-export([start/0]).

start() ->
  receive
    {bind_app, App} ->
      % Bind
      wait_links(App)
  end.

wait_links(App) ->
% Wait for map of links (to the PL components of other processes)
  receive
    {pl_link_map, SYS, LinkMap} ->
      % Everything is ready
      SYS ! pl_link_received,
      next(App, LinkMap)
  end.

next(App, LinkMap) ->
  receive
    {pl_transmit, Message} ->
      % Deliver message to app
      App ! {pl_deliver, Message};
    {pl_send, Dest, Message} ->
      % Send a message to the PL component of dest process
      Dest_PL_ID = maps:get(Dest, LinkMap),
      % Simulate tranmission across network
      Dest_PL_ID ! {pl_transmit, Message}
  end,
  next(App, LinkMap).