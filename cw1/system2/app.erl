%%% Mark Lee (cyl113)
-module(app).
-export([start/0]).

start() ->
  receive
    {bind, ID, PL_ID, Peers} -> 
      % Initialise the map
      Broadcast = maps:from_list([{Peer, {0, 0}} || Peer <- Peers]),
      next(ID, PL_ID, Broadcast)
  end.

next(ID, PL_ID, Broadcast) ->
% Separated out to use after -> 0 to broadcast
  receive
    {pl_deliver, Message} ->
      {task1, start, Max_messages, Timeout} = Message,
      % Delay sending of terminate message
      timer:send_after(Timeout, PL_ID, {pl_send, ID, terminate}),
      task1(ID, PL_ID, Broadcast, Max_messages) % Actually being the task
  end.

task1(ID, PL_ID, Broadcast, Max_messages) ->
  receive
    {pl_deliver, Message} ->
      case Message of
        terminate ->
        % Receive and handle the timeout message
          print_output(ID, Broadcast);
        {task1, message, Source} ->
        % Handle receiving messages
          receive_message(ID, PL_ID, Broadcast, Max_messages, Source)
      end
  after
    0 -> % If there are no more messages to receive, broadcast
      attempt_broadcast(ID, PL_ID, Broadcast, Max_messages)
  end.

attempt_broadcast(ID, PL_ID, Broadcast, Max_messages) ->
% Broadcast to all peers and update the map
  NewBroadcast = maps:map(
    fun(Dest, V) ->
      {Sent, Received} = V,
      Message = {task1, message, ID},
      if
        Sent < Max_messages ->
          PL_ID ! {pl_send, Dest, Message},
          {Sent+1, Received};
        Max_messages == 0 ->
          PL_ID ! {pl_send, Dest, Message},
          {Sent+1, Received};
        true ->
          V
      end
    end,
    Broadcast),
  task1(ID, PL_ID, NewBroadcast, Max_messages).

receive_message(ID, PL_ID, Broadcast, Max_messages, Source) ->
  {Sent, Received} = maps:get(Source, Broadcast),
  NewBroadcast = maps:update(Source, {Sent, Received+1}, Broadcast),
  task1(ID, PL_ID, NewBroadcast, Max_messages).

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

