%%% Chu Lee (cyl113) and Royson Lee (dsl114)
%%% distributed algorithms, n.dulay 27 feb 17
%%% coursework 2, paxos made moderately complex

-module(replica).
-export([start/1]).

start(Database) ->
  receive
    {bind, Leaders} ->
      next(Database, 1, 1, sets:new(), sets:new(), sets:new(), Leaders)
  end.

next(Database, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders) ->
  receive
    {request, C} ->
      NewRequests = sets:add_element(C, Requests),
      propose(Database, Slot_in, Slot_out, NewRequests, 
              Proposals, Decisions, Leaders);
    {decision, S, C} ->
      NewDecisions = sets:add_element({S, C}, Decisions),
      decide(Database, Slot_in, Slot_out, Requests, 
             Proposals, NewDecisions, Leaders)
  end,
  next(Database, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders).

propose(Database, Slot_in, Slot_out, Requests, 
        Proposals, Decisions, Leaders) ->
  WINDOW = 5,
  RequestsSize = sets:size(Requests),
  % Go back to waiting if there are no more requests
  if 
    RequestsSize == 0 -> next(Database, Slot_in, Slot_out, Requests,
                              Proposals, Decisions, Leaders);
    true -> ok
  end,
  if 
    Slot_in < Slot_out + WINDOW ->
      DecisionsMap = maps:from_list(sets:to_list(Decisions)),
      In_Decisions = maps:is_key(Slot_in, DecisionsMap),
      [C | _] = sets:to_list(Requests),
      if 
        In_Decisions == false ->
          NewRequests = sets:del_element(C, Requests),
          NewProposals = sets:add_element({Slot_in, C}, Proposals),
          [Leader ! {propose, Slot_in, C} || Leader <- Leaders],
          propose(Database, Slot_in + 1, Slot_out, NewRequests, 
                  NewProposals, Decisions, Leaders);
        true -> ok
      end;
    true -> ok
  end,
  next(Database, Slot_in, Slot_out, Requests, Proposals, Decisions, Leaders).

decide(Database, Slot_in, Slot_out, Requests, 
       Proposals, Decisions, Leaders) ->
  DecisionsMap = maps:from_list(sets:to_list(Decisions)),
  In_Decisions = maps:is_key(Slot_out, DecisionsMap),
  % Go back to waiting if there is no decision in Slot_out
  if 
    In_Decisions == false -> next(Database, Slot_in, Slot_out, Requests, 
                                  Proposals, Decisions, Leaders);
    true -> ok
  end,
  C_Prime = maps:get(Slot_out, DecisionsMap),
  ProposalsList = sets:to_list(Proposals),
  NewProposals = [{S, C} || {S, C} <- ProposalsList, S /= Slot_out],
  RemovedProposals = [{S, C} || {S, C} <- ProposalsList, S == Slot_out],
  AdditionalRequests = [ C || {_, C} <- RemovedProposals, C /= C_Prime],
  NewRequests = sets:union(sets:from_list(AdditionalRequests), Requests),
  perform(Database, Slot_in, Slot_out, NewRequests,
          sets:from_list(NewProposals), Decisions, Leaders, C_Prime).

perform(Database, Slot_in, Slot_out, Requests, 
        Proposals, Decisions, Leaders, Command) ->
  % Check if command is already executed
  DecisionsList = sets:to_list(Decisions),
  CommandExecuted = [ {S, C} || {S, C} <- DecisionsList, 
                    S < Slot_out, C == Command],
  if 
    CommandExecuted == [] -> 
      {Client, Cid, Op} = Command,
      Database ! {execute, Op},
      Client ! {response, Cid, ok};
    true -> ok
  end,
  next(Database, Slot_in, Slot_out + 1, Requests, 
       Proposals, Decisions, Leaders).
