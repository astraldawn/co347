%%% Chu Lee (cyl113) and Royson Lee (dsl114)
-module(scout).
-export([start/3]).

start(Leader, Acceptors, B) ->
  [ Acceptor ! {p1a, self(), B} || Acceptor <- Acceptors ],
  next(Leader, Acceptors, B, Acceptors, []).

next(Leader, Acceptors, B, WaitFor, Pvalues) ->
  receive
    {p1b, Acceptor, B_Prime, Accepted} ->
      if
        B == B_Prime ->
          NewPvalues = Pvalues ++ Accepted,
          NewWaitFor = WaitFor -- [Acceptor],
          S_WaitFor = length(NewWaitFor),
          S_Acceptors = length(Acceptors),
          if 
            S_WaitFor < S_Acceptors / 2 ->
              Leader ! {adopted, B, NewPvalues},
              exit(normal);
            true -> ok
          end,
          next(Leader, Acceptors, B, NewWaitFor, NewPvalues);
        true ->
          Leader ! {preempted, B_Prime},
          exit(normal)
      end
  end,
  next(Leader, Acceptors, B, WaitFor, Pvalues).
