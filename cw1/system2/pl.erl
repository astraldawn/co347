%%% Mark Lee (cyl113)
-module(pl).
-export([start/0]).

start() ->
  receive
    {create_app, PID, PIDs} ->
      % Create associated app 
      App = spawn(app, start, []),
      App ! {bind, PID, self(), PIDs},
      PID ! created,
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
    {pl_deliver, Message} ->
      % Deliver message to app
      App ! Message;
    {pl_send, Message, Dest} ->
      % Send a message to the PL component of dest process
      Dest_PL_ID = maps:get(Dest, LinkMap),
      Dest_PL_ID ! {pl_deliver, Message}
  end,
  next(App, LinkMap).