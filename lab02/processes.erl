
%%% distributed algorithms, n.dulay, 4 jan 17
%%% time how long it takes to create N processes and then remove them

-module(processes).
-export([create/1]).

% --------------------------------------------------------------------

create(N) ->
  Start = erlang:monotonic_time(milli_seconds),

  P = range_map(1, N, fun() -> spawn(fun() -> wait() end) end),
  lists:foreach(fun(Pid) -> Pid ! exit end, P),

  Time = erlang:monotonic_time(milli_seconds) - Start,

  io:format("Process limit = ~p~n",[erlang:system_info(process_limit)]),
  io:format("Total   time  = ~p milliseconds (~p processes)~n", [Time, N]),
  io:format("Process time  = ~p microseconds~n", [Time * 1000 /N]).

wait() ->
  receive
    exit -> ok
  end.

range_map(N, N, F) -> [ F() ];
range_map(K, N, F) -> [ F() | range_map(K+1, N, F) ].