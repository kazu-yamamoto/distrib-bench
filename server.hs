{-# LANGUAGE BangPatterns #-}

module Main where

import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Monad (unless)
import Data.Binary (encode)
import qualified Data.ByteString.Base64.Lazy as B64 (encode)
import qualified Data.ByteString.Lazy.Char8 as B (putStrLn)
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import System.Environment (getArgs)
import System.Exit (exitFailure)

import SizedList

counter :: Process ()
counter = go 0
  where
    go :: Int -> Process ()
    go !n = do
      msg <- receiveWait
        [ match $ \xs   -> return . Left . size $ (xs :: SizedList Int)
        , match $ \them -> return . Right $ them
        ]
      case msg of
        Left n' -> go (n + n')
        Right them -> send them n >> go 0

main :: IO ()
main = do
  args <- getArgs
  unless (length args == 2) $ do
      putStrLn "server <myaddr> <myport>"
      exitFailure
  let [myaddr, myport] = args
  et <- createTransport myaddr myport defaultTCPParameters
  case et of
      Right transport -> do
          node <- newLocalNode transport initRemoteTable
          runProcess node $ do
              us <- getSelfPid
              liftIO $ putStr "Serving at "
              liftIO $ print us
              liftIO $ putStrLn "Copy the following to your client:"
              liftIO $ B.putStrLn $ B64.encode $ encode us
              counter
      Left _ -> putStrLn "Bad address or port"
