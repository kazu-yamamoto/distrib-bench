-module(bench).

-export([start_server/0, start_client/2, counter/0, count/2, nats/1]).

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
  register(server, spawn(bench, counter, [])).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nats(0) ->
  [];
nats(N) ->
  [N | nats(N - 1)].

replicate(0, _) ->
  ok;
replicate(N, What) ->
  What(),
  replicate(N - 1, What).

count(Packets, Size) ->
  replicate(Packets, fun() -> server ! {count, nats(Size)} end),
  server ! {get, self()},
  receive
    N -> io:format("Did ~B pings ", [N])
  end.

start_client(Packets, Size) ->
  count(Packets, Size).
