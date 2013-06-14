{-# LANGUAGE DeriveDataTypeable #-}

module SizedList where

import Data.Binary
import Data.Typeable

data SizedList a = SizedList { size :: Int , elems :: [a] }
  deriving (Typeable)

instance Binary a => Binary (SizedList a) where
  put (SizedList sz xs) = put sz >> mapM_ put xs
  get = do
    sz <- get
    xs <- getMany sz
    return (SizedList sz xs)

-- Copied from Data.Binary
getMany :: Binary a => Int -> Get [a]
getMany n = go [] n
 where
    go xs 0 = return $! reverse xs
    go xs i = do x <- get
                 x `seq` go (x:xs) (i-1)
{-# INLINE getMany #-}

nats :: Int -> SizedList Int
nats = \n -> SizedList n (aux n)
  where
    aux 0 = []
    aux n = n : aux (n - 1)
