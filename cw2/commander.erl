-module(commander).
-export([start/4]).

start(Leader, Acceptors, Replicas, Pvalue) ->
  [ Acceptor ! {p2a, self(), Pvalue} || Acceptor <- Acceptors ],
  next(Leader, Acceptors, Replicas, Pvalue, Acceptors).

next(Leader, Acceptors, Replicas, Pvalue, WaitFor) ->
  {B, S, C} = Pvalue,
  receive
    {p2b, Acceptor, B_Prime} ->
      if
        B == B_Prime ->
          NewWaitFor = sets:del_element(Acceptor, WaitFor),
          S_WaitFor = sets:size(WaitFor),
          S_Acceptors = sets:size(Acceptors),
          if 
            S_WaitFor < S_Acceptors / 2 ->
              [Replica ! {decision, S, C} || Replica <- Replicas],
              exit(normal);
            true -> false
          end,
          next(Leader, Acceptors, Replicas, Pvalues, NewWaitFor);
        true ->
          Leader ! {preempted, B_Prime},
          exit(normal)
      end
  end,
  next(Leader, Acceptors, Replicas, Pvalues, WaitFor).