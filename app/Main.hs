module Main where

import Prelude
import System.Environment
import System.IO.Unsafe
import Data
import Initialize
import Interactions 

main :: IO ()
main = do
    args <- getArgs
    if null args then do
        putStrLn "No file path"
    else do
        let src = argsToMaps args
        putStrLn $ mapPipe src Nothing

--seems like it
gameLoop :: Scene -> (Player, Bool)
gameLoop (p,_,[],_) = (p, True)
gameLoop (p,f,e,tmap)
    | isend         = (p, False)
    | otherwise     = gameLoop ret
  where
    isend = (pHp p) < 0
    ret   = doInteractions (p, f, e, tmap)

--Map pipeling
mapPipe :: [String] -> Maybe Player -> String
mapPipe [] _          = "Victory"
mapPipe (m:ms) Nothing
    | victory         = mapPipe ms (Just player)
    | otherwise       = "GameOver"
  where
    (player, victory) = gameLoop . createScene . createTilemap $ m
--new position, old stats
mapPipe (m:ms) (Just p)
    | victory         = mapPipe ms (Just player)
    | otherwise       = "GameOver"
  where
    (tmpp,f,e,tmap)   = createScene . createTilemap $ m
    newp              = Player
                            (pPosX tmpp)
                            (pPosY tmpp)
                            (pRadian tmpp)
                            (pHp p)
                            (pSpeed p)
                            (pASpeed p)
                            (pDamage p)
    (player, victory) = gameLoop (newp, f, e, tmap)

--create map list
argsToMaps :: [String] -> [String]
argsToMaps []     = []
argsToMaps (x:xs) = tmap : argsToMaps xs
  where
    tmap = unsafePerformIO . readFile $ x

--not used now
printEnemies :: [Enemy] -> IO()
printEnemies []     = putStrLn "end"
printEnemies (e:es) = do
    putStrLn $ "Enemy x=" ++ show (ePosX e) ++ " y=" ++ show (ePosY e)
    printEnemies es
