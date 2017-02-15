%%% Mark Lee (cyl113)
-module(rb).
-export([start/0]).

start() ->
  receive
    {bind, App, BEB, ID} -> next(App, BEB, ID, [])
  end.

next(App, BEB, ID, Delivered) ->
  receive
    {rb_broadcast, M} ->
      BEB ! {beb_broadcast, {data, ID, M}},
      next(App, BEB, ID, Delivered);
    {beb_deliver, {data, S, M}} ->
      Contains = lists:member({S,M}, Delivered),
      if
        Contains ->
          next(App, BEB, ID, Delivered);
        true ->
          App ! {rb_deliver, S, M},
          case M of
            % Do not rebroadcast the start message
            {task1, start, _, _} -> 
              next(App, BEB, ID, Delivered);
            _Else ->
              BEB ! {beb_broadcast, {data, S, M}},
              next(App, BEB, ID, Delivered ++ [{S,M}])
          end
      end
  end.