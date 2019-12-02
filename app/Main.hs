{-# LANGUAGE OverloadedStrings #-}

-- |
-- Author  : Nick Brandaleone <nbrand@mac.com>
-- Based upon example by Brendan Hay <https://github.com/brendanhay>
-- December 2019
--
module Main where

import           Control.Lens
import           Control.Monad.IO.Class
import           Control.Monad.Trans.AWS
import           Data.ByteString.Builder (hPutBuilder)
import           Data.Conduit
import qualified Data.Conduit.List       as CL
import           Data.Monoid
import           Network.AWS.Data
import           Network.AWS.EC2
import           System.IO
import           Control.Concurrent.Async

myRegions x = case x of Beijing -> False
                        GovCloud -> False
                        GovCloudFIPS -> False
                        NorthCalifornia -> False
                        otherwise -> True

-- Remove some AWS regions from inspection
regions = filter myRegions [NorthVirginia .. Beijing]

-- Print out EC2 information for a given Region
instanceOverview :: Region -> IO ()
instanceOverview r = do
    lgr <- newLogger Info stdout
    env <- newEnv Discover <&> set envLogger lgr

    let pp x = mconcat
          [ "[instance:" <> build (x ^. insInstanceId) <> "] {"
          , "\n  public-dns = " <> build (x ^. insPublicDNSName)
          , "\n  tags       = " <> build (x ^. insTags . to show)
          , "\n  state      = " <> build (x ^. insState . isName . to toBS)
          , "\n}\n"
          ]

    runResourceT . runAWST env . within r $
      runConduit $
        paginate describeInstances
             .| CL.concatMap (view dirsReservations)
             .| CL.concatMap (view rInstances)
             .| CL.mapM_ (liftIO . hPutBuilder stdout . pp)

main :: IO ()
main = do
  mapConcurrently instanceOverview regions
  return ()
