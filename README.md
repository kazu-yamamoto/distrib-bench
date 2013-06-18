# distrib-bench

Benchmark for throughput to compare performance of Haskell and
that of Erlang

## "server" and "client" in Haskell

### server (172.16.1.1):

    % cabal install
    % server 172.16.1.1 8000
    Serving at pid://172.16.1.1:8000:0:3
    Copy the following to your client:
    AAAAAAAAABExNzIuMTYuMS4xOjgwMDA6MGhwMYwAAAAD

### client (172.16.1.2):

    % cabal install 
    % client 172.16.1.2 8000 AAAAAAAAABExNzIuMTYuMS4xOjgwMDA6MGhwMYwAAAAD 1000 1000
    (1000000,True)

Note the last two arguments are the number of packets and their size.

## "start_server" and "start_client" in Erlang

### server (172.16.1.1):

    % make
    % erl -noshell -name foo@172.16.1.1 -setcookie abc -run erlserver start_server

### client (172.16.1.2):

    % make
    % erl -noshell -name bar@172.16.1.2 -setcookie abc -run erlclient start_client foo@172.16.1.1 1000 1000

Note the last two arguments are the number of packets and their size.

## Credits

Original one is from Edsko de Vries.
