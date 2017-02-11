%%% Mark Lee (cyl113)
-module(process).
-export([start/0]).

start() ->
  receive
    {create_pl, SYS, PID, PIDs} ->
      % Create the PL component
      PL = spawn(pl, start, []),
      PL ! {create_app, PID, PIDs},
      next(SYS, PID, PL)
  end.

next(SYS, PID, PL_ID) ->
  receive
    % Once PL is fully created, send back process_id, pl_id for mapping
    created -> SYS ! {pl_link, PID, PL_ID}
  end.