-module(acceptor).
-export([start/0]).

start() ->
  next({-1, self()}, sets:new()).

next(Ballot_num, Accepted) ->
  receive
    {p1a, Leader, B} ->
      if 
        B > Ballot_num ->
          Leader ! {p1b, self(), B, Accepted},
          next(B, Accepted);
        true -> false
      end;
    {p2a, Leader, Pvalue} ->
      {B, _, _} = Pvalue,
      if
        B == Ballot_num ->
          NewAccepted = sets:add_element(Pvalue),
          Leader ! {p2b, self(), Ballot_num},
          next(Ballot_num, NewAccepted);
        true -> false
      end,
      Leader ! {p2b, self(), Ballot_num}
  end,
  next(Ballot_num, Accepted).

