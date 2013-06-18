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

client(Packets, Size, Node) ->
  replicate(Packets, fun() -> {server, Node} ! {count, nats(Size)} end),
  {server, Node} ! {get, self()},
  receive
    N -> io:format("Did ~B pings ", [N])
  end.

start_client([Packets, Size, Node]) ->
	client(list_to_integer(atom_to_list(Packets)), 
		list_to_integer(atom_to_list(Size)), 
		Node).
