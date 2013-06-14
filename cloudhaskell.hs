{-# LANGUAGE DeriveDataTypeable, BangPatterns #-}

import Control.Applicative
import Control.Distributed.Process
import Control.Distributed.Process.Node
import Control.Monad
import Data.Binary
import qualified Data.ByteString.Lazy as BSL
import Data.Typeable
import Network.Transport.TCP (createTransport, defaultTCPParameters)
import System.Environment
import System.Exit

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

count :: (Int, Int) -> ProcessId -> Process ()
count (packets, siz) them = do
  us <- getSelfPid
  replicateM_ packets $ send them (nats siz)
  send them us
  n' <- expect
  liftIO $ print (packets * siz, n' == packets * siz)

initialProcess :: String -> Process ()
initialProcess "SERVER" = do
  us <- getSelfPid
  liftIO $ BSL.writeFile "counter.pid" (encode us)
  counter
initialProcess "CLIENT" = do
  n <- liftIO $ getLine
  them <- liftIO $ decode <$> BSL.readFile "counter.pid"
  count (read n) them
initialProcess _ = error "initialProcess"

main :: IO ()
main = do
  [role, host, port] <- getArgs
  unless (role `elem` ["SERVER","CLIENT"]) $ do
      putStrLn $ "Bad role: " ++ role ++ ". Use either SERVER or CLIENT"
      exitFailure
  et <- createTransport host port defaultTCPParameters
  case et of
      Right transport -> do
          node <- newLocalNode transport initRemoteTable
          runProcess node $ initialProcess role
      Left _ -> putStrLn "Bad address or port"
