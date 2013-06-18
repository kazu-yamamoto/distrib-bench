-module(erlclient).

-export([start_client/1]).

nats(0) ->
  [];
nats(N) ->
  [N | nats(N - 1)].

replicate(0, _) ->
  ok;
replicate(N, What) ->
  What(),
  replicate(N - 1, What).

client(Node, Packets, Size) ->
  replicate(Packets, fun() -> {server, Node} ! {count, nats(Size)} end),
  {server, Node} ! {get, self()},
  receive
    N -> io:format("Did ~B pings ", [N])
  end.

start_client([Arg1,Arg2,Arg3]) ->
  Node    = list_to_atom(Arg1),
  Packets = list_to_integer(Arg2),
  Size    = list_to_integer(Arg3),
  client(Node, Packets, Size),
  init:stop().
