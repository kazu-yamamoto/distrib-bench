all:
	ghc -O -threaded -Wall -rtsopts server.hs
	ghc -O -threaded -Wall -rtsopts client.hs

clean:
	rm -f server client *.o *.hi
