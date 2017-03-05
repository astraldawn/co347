-module(leader).
-export([start/0]).

start() ->
  receive
    {bind, Acceptors, Replicas} ->
      Ballot_Num = {0, self()},
      spawn(scout, start, [self(), Acceptors, Ballot_Num]),
      next(Acceptors, Replicas, Ballot_Num, false, maps:new())
  end.

next(Acceptors, Replicas, Ballot_Num, Active, Proposals) ->
  receive
    {propose, S, C} ->
      In_Proposals = maps:is_key(S, Proposals),
      if
        In_Proposals == false ->
          NewProposals = maps:put(S, C, Proposals),
          if 
            Active ->
              Pvalue = {Ballot_Num, S, C},
              spawn(commander, start, [self(), Acceptors, Replicas, Pvalue]);
            true -> ok
          end,
          next(Acceptors, Replicas, Ballot_Num, Active, NewProposals);
        true -> ok
      end;
    {adopted, RBallot_Num, Pvalues} ->
      if
        RBallot_Num == Ballot_Num -> % Ignore the old ballot number
          NewProposals = pmax(Proposals, Pvalues),
          ProposalList = maps:to_list(NewProposals),
          if 
            length(ProposalList) > 0 -> 
              [spawn(commander, start, [self(), Acceptors, Replicas, {Ballot_Num, S, C}]) || {S, C} <- ProposalList];
            true -> ok
          end,
          next(Acceptors, Replicas, Ballot_Num, true, NewProposals);
        true -> ok
      end;
    {preempted, B_Prime} ->
      {R_Prime, _} = B_Prime,
      if 
        B_Prime > Ballot_Num ->
          NewBallot_Num = {R_Prime + 1, self()},
          spawn(scout, start, [self(), Acceptors, NewBallot_Num]),
          next(Acceptors, Replicas, NewBallot_Num, false, Proposals);
        true -> ok
      end
  end,
  next(Acceptors, Replicas, Ballot_Num, Active, Proposals).

pmax(Proposals, Pvalues) ->
  PvaluesList = sets:to_list(Pvalues),
  Slots = sets:to_list(sets:from_list([S || {_, S, _} <- PvaluesList])),
  MaxSlotsList = lists:map(
    fun(Slot) ->
      CurSlotElems = lists:filter(
        fun({_, S, _}) ->
          if
            S == Slot -> true;
            true -> false
          end
        end,
        PvaluesList),
      MaxElem = lists:max(CurSlotElems), % Return maximum for indiv slot (exploiting lexi ordering)
      {_, S, C} = MaxElem,
      {S, C}
    end,
    Slots),
  MaxSlotsSet = sets:from_list(MaxSlotsList),
  ProposalSet = sets:from_list(maps:to_list(Proposals)),
  DiffSet = sets:subtract(ProposalSet, MaxSlotsSet),
  ResSet = sets:union(DiffSet, MaxSlotsSet),
  maps:from_list(sets:to_list(ResSet)).

