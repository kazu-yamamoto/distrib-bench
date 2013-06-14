all:
	ghc -O -threaded -Wall -rtsopts cloudhaskell.hs

clean:
	rm -f cloudhaskell *.o *.hi
