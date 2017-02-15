%%% Mark Lee (cyl113)
-module(app).
-export([start/0]).

start() ->
  receive
    {bind, ID, RB, Peers} -> 
      % Initialise the map
      Broadcast = maps:from_list([{Peer, {0, 0}} || Peer <- Peers]),
      next(ID, RB, Broadcast)
  end.

next(ID, RB, Broadcast) ->
% Separated out to use after -> 0 to broadcast
  receive
    {rb_deliver, _, Message} ->
      {task1, start, Max_messages, Timeout} = Message,
      % Delay sending of terminate message
      % if 
      %   Timeout == 5 -> timer:exit_after(Timeout, kill);
      %   true -> timer:send_after(Timeout, terminate)
      % end,
      timer:send_after(Timeout, terminate),
      task1(ID, RB, Broadcast, Max_messages, 0) % Actually being the task
  end.

task1(ID, RB, Broadcast, Max_messages, Seq) ->
  receive
    terminate ->
      % Receive and handle the timeout message
      print_output(ID, Broadcast);
    {rb_deliver, Source, Message} ->
      case Message of
        {task1, message, _} ->
        % Handle receiving messages
          receive_message(ID, RB, Broadcast, Max_messages, Source, Seq)
      end
  after
    0 -> % If there are no more messages to receive, broadcast
      attempt_broadcast(ID, RB, Broadcast, Max_messages, Seq)
  end.

attempt_broadcast(ID, RB, Broadcast, Max_messages, Seq) ->
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
      Message = {task1, message, Seq},
      RB ! {rb_broadcast, Message},
      task1(ID, RB, NewBroadcast, Max_messages, Seq+1);
    true ->
      % No broadcast
      task1(ID, RB, Broadcast, Max_messages, Seq)
  end.

receive_message(ID, RB, Broadcast, Max_messages, Source, Seq) ->
  {Sent, Received} = maps:get(Source, Broadcast),
  NewBroadcast = maps:update(Source, {Sent, Received+1}, Broadcast),
  task1(ID, RB, NewBroadcast, Max_messages, Seq).

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

