-module(erlserver).

-export([start_server/0, counter/0]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

counter() ->
  counter(0).

counter(N) ->
  receive
    {count, List} ->
      counter(N + length(List));
    {get, From} ->
      From ! N,
      counter(0)
  end.

start_server() ->
  register(server, spawn(erlserver, counter, [])).
