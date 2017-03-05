%%% Chu Lee (cyl113) and Royson Lee (dsl114)
-module(commander).
-export([start/4]).

start(Leader, Acceptors, Replicas, Pvalue) ->
  [ Acceptor ! {p2a, self(), Pvalue} || Acceptor <- Acceptors ],
  next(Leader, sets:from_list(Acceptors), Replicas, 
      Pvalue, sets:from_list(Acceptors)).

next(Leader, Acceptors, Replicas, Pvalue, WaitFor) ->
  {B, S, C} = Pvalue,
  receive
    {p2b, Acceptor, B_Prime} ->
      if
        B == B_Prime ->
          NewWaitFor = sets:del_element(Acceptor, WaitFor),
          S_WaitFor = sets:size(NewWaitFor),
          S_Acceptors = sets:size(Acceptors),
          if 
            S_WaitFor < S_Acceptors / 2 ->
              [Replica ! {decision, S, C} || Replica <- Replicas],
              exit(normal);
            true -> ok
          end,
          next(Leader, Acceptors, Replicas, Pvalue, NewWaitFor);
        true ->
          Leader ! {preempted, B_Prime},
          exit(normal)
      end
  end,
  next(Leader, Acceptors, Replicas, Pvalue, WaitFor).