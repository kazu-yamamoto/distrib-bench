Benchmark for throughput to compare performance of Haskell and
that of Erlang

# "server" and "client" in Haskell

## server (172.16.1.1):

    % cabal install
    % server 172.16.1.1 8000
    Serving at pid://172.16.1.1:8000:0:3
    Copy the following to your client:
    AAAAAAAAABExNzIuMTYuMS4xOjgwMDA6MGhwMYwAAAAD

## client (172.16.1.2):

    % cabal install 
    % client 172.16.1.2 8000 AAAAAAAAABExNzIuMTYuMS4xOjgwMDA6MGhwMYwAAAAD 1000 1000
    (1000000,True)

    Note the last two arguments are the number of packets and their size.

# "bench" in Erlang

## server (172.16.1.1):

    % erl -name foo@172.16.1.1
    > c(erlserver).
    {ok,erlserver}
    > erlserver:start_server().
    true

## client (172.16.1.2):

    % erl -name bar@172.16.1.2
    > c(erlclient).
    {ok,erlclient}
    > erlclient:start_client(1000,1000,'foo@172.16.1.1').
    Did 1000000 pings ok

    Note the first two arguments are the number of packets and their size.

# Credits

Original one is from Edsko de Vries.
