%%% Mark Lee (cyl113)
-module(process).
-export([start/0]).

start() ->
  receive
    {create_pl, SYS, PID, PIDs, LinkRel} ->
      % Create the PL component
      PL = spawn(lossyp2plinks, start, []),
      App = spawn(app, start, []),
      BEB = spawn(beb, start, []),
      PL ! {bind, BEB, LinkRel},
      App ! {bind, PID, BEB, PIDs},
      BEB ! {bind, PIDs, App, PL},
      SYS ! {pl_link, PID, PL}
  end.