%%% Mark Lee (cyl113)
-module(app).
-export([start/0]).

start() ->
  receive
    {bind, ID, BEB, Peers} -> 
      % Initialise the map
      Broadcast = maps:from_list([{Peer, {0, 0}} || Peer <- Peers]),
      next(ID, BEB, Broadcast)
  end.

next(ID, BEB, Broadcast) ->
% Separated out to use after -> 0 to broadcast
  receive
    {beb_deliver, Message} ->
      {task1, start, Max_messages, Timeout} = Message,
      % Delay sending of terminate message
      timer:send_after(Timeout, terminate),
      task1(ID, BEB, Broadcast, Max_messages) % Actually being the task
  end.

task1(ID, BEB, Broadcast, Max_messages) ->
  receive
    terminate ->
      % Receive and handle the timeout message
      print_output(ID, Broadcast);
    {beb_deliver, Message} ->
      case Message of
        {task1, message, Source} ->
        % Handle receiving messages
          receive_message(ID, BEB, Broadcast, Max_messages, Source)
      end
  after
    0 -> % If there are no more messages to receive, broadcast
      attempt_broadcast(ID, BEB, Broadcast, Max_messages)
  end.

attempt_broadcast(ID, BEB, Broadcast, Max_messages) ->
% Broadcast to all peers and update the map
% Check if a broadcast should be done
  MapCount = maps:size(maps:filter(
    fun(_, {Sent, _}) ->
      if 
        Sent < Max_messages -> true;
        Max_messages == 0 -> true;
        true -> false
      end
    end,     
    Broadcast
  )),
  if 
    MapCount > 0 ->
      % Broadcast should be done    
      NewBroadcast = maps:map(
        fun(_, {Sent, Received}) -> 
          {Sent+1, Received}
        end,
        Broadcast),
      Message = {task1, message, ID},
      BEB ! {beb_broadcast, Message},
      task1(ID, BEB, NewBroadcast, Max_messages);
    true ->
      % No broadcast
      task1(ID, BEB, Broadcast, Max_messages)
  end.

receive_message(ID, BEB, Broadcast, Max_messages, Source) ->
  {Sent, Received} = maps:get(Source, Broadcast),
  NewBroadcast = maps:update(Source, {Sent, Received+1}, Broadcast),
  task1(ID, BEB, NewBroadcast, Max_messages).

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

