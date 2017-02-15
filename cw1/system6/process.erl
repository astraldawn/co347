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
      RB = spawn(rb, start, []),
      PL ! {bind, BEB, LinkRel},
      App ! {bind, PID, RB, PIDs},
      BEB ! {bind, PIDs, RB, PL},
      RB ! {bind, App, BEB, PID},
      SYS ! {pl_link, PID, PL}
  end.