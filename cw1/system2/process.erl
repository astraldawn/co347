%%% Mark Lee (cyl113)
-module(process).
-export([start/0]).

start() ->
  receive
    {create_pl, SYS, PID, PIDs} ->
      % Create the PL component
      PL = spawn(pl, start, []),
      App = spawn(app, start, []),
      PL ! {bind_app, App},
      App ! {bind, PID, PL, PIDs},
      SYS ! {pl_link, PID, PL}
  end.