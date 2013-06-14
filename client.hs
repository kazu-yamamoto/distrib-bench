module Main where

import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Monad (unless, replicateM_)
import Data.Binary (decode)
import qualified Data.ByteString.Base64.Lazy as B64 (decodeLenient)
import Data.String (fromString)
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import System.Environment (getArgs)
import System.Exit (exitFailure)

import SizedList

count :: Int -> Int -> ProcessId -> Process ()
count packets siz them = do
  us <- getSelfPid
  replicateM_ packets $ send them (nats siz)
  send them us
  n' <- expect
  liftIO $ print (packets * siz, n' == packets * siz)

main :: IO ()
main = do
  args <- getArgs
  unless (length args == 5) $ do
      putStrLn "clinet <myaddr> <myport> <serverspec> <n> <size>"
      exitFailure
  let [myaddr, myport, serverspec, n', siz'] = args
      proid = decode $ B64.decodeLenient $ fromString serverspec
      n = read n'
      siz = read siz'
  et <- createTransport myaddr myport defaultTCPParameters
  case et of
      Right transport -> do
          node <- newLocalNode transport initRemoteTable
          runProcess node $ count n siz proid
      Left _ -> putStrLn "Bad address or port"
