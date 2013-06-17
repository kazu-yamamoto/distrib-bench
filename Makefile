all:
	erlc erlserver.erl
	erlc erlclient.erl

clean:
	rm -f *.beam
