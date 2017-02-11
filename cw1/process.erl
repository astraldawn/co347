
%%% distributed algorithms, n.dulay, 4 jan 17
%%% simple client-server, v1

-module(process).
-export([start/0]).

start() ->
  receive
    {bind, ID, Peers} -> 
      % Initialise the map
      Broadcast = maps:from_list([{Peer, {0, 0}} || Peer <- Peers]),
      next(ID, Broadcast)
  end.

next(ID, Broadcast) ->
% Separated out to use after -> 0 to broadcast
  receive
    {task1, start, Max_messages, Timeout} ->
      timer:send_after(Timeout, terminate), % Delay sending of the timeout
      task1(ID, Broadcast, Max_messages) % Actually being the task
  end.

task1(ID, Broadcast, Max_messages) ->
  receive
    terminate ->
      % Receive and handle the timeout message
      print_output(ID, Broadcast);
    {task1, message, Source} ->
      % Handle receiving messages
      receive_message(ID, Broadcast, Max_messages, Source)
  after
    0 -> % If there are no more messages to receive, broadcast
      attempt_broadcast(ID, Broadcast, Max_messages)
  end.

attempt_broadcast(ID, Broadcast, Max_messages) ->
% Broadcast to all peers and update the map
  NewBroadcast = maps:map(
    fun(K, V) ->
      {Sent, Received} = V,
      if
        Sent < Max_messages ->
          K ! {task1, message, ID},
          {Sent+1, Received};
        Max_messages == 0 ->
          K ! {task1, message, ID},
          {Sent+1, Received};
        true ->
          V
      end
    end,
    Broadcast),
  task1(ID, NewBroadcast, Max_messages).

receive_message(ID, Broadcast, Max_messages, Source) ->
  {Sent, Received} = maps:get(Source, Broadcast),
  NewBroadcast = maps:update(Source, {Sent, Received+1}, Broadcast),
  task1(ID, NewBroadcast, Max_messages).

print_output(ID, Broadcast) ->
  BroadcastList = maps:to_list(Broadcast),
  OutputList = lists:concat(lists:map(
    fun(Item) ->
      {_, {V1, V2}} = Item,
      "{" ++ integer_to_list(V1) 
          ++ "," 
          ++ integer_to_list(V2)
          ++ "} "
    end,
    BroadcastList)),
  io:format('~p: ~s~n', [list_to_integer(atom_to_list(ID)), OutputList]).

