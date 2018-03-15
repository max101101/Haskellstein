module Haskellstein.Initialize where

import Prelude
import Haskellstein.Data

createPlayer :: CellCoord -> Player
createPlayer (y, x) =
    Player
        (((fromIntegral x) + 0.5)
      , ((fromIntegral y) + 0.5)) -- pPos
        0 -- pRadian
        11 -- pHp
        1 -- pSpeed
        (Just 1, 1) -- pASpeed
        1 -- pDamage

createEnemy :: CellCoord -> EnemyType -> Enemy
--melee
createEnemy (y, x) Melee =
    Enemy
        (((fromIntegral x) + 0.5)
      , ((fromIntegral y) + 0.5)) -- ePos
        3 -- eHp
        1 -- eDamage
        1 -- eRange
        1 -- eSpeed
        (Just 2, 2) -- eASpeed
        Melee -- eModel
        1 -- eTex
        32 -- eVision
        False -- eAgro
--range
createEnemy (y, x) Range =
    Enemy
        (((fromIntegral x) + 0.5)
      , ((fromIntegral y) + 0.5)) -- ePos
        3 -- eHp
        1 -- eDamage
        1 -- eRange
        1 -- eSpeed
        (Just 2, 2) -- eASpeed
        Range -- eModel
        1 -- eTex
        32 -- eVision
        False -- eAgro
--spike
createEnemy (y, x) Mage =
    Enemy
        (((fromIntegral x) + 0.5)
      , ((fromIntegral y) + 0.5)) -- ePos
        3 -- eHp
        1 -- eDamage
        1 -- eRange
        1 -- eSpeed
        (Just 2, 2) -- eASpeed
        Mage -- eModel
        1 -- eTex
        32 -- eVision
        False -- eAgro

createFireball ::
  Position
  -> Float -- player angle
  -> Int -- damage
  -> Fireball
createFireball (x,y) a d =
    Fireball
        ((x + (0.7 * cos a))
      , (y + (0.7 * sin a))) -- fPos
        a -- fRadian
        d -- fDamage
        0.7 -- fRadius
        1.0 -- fSpeed
        Small -- fModel

--split string by symbol
splitString :: Char -> String -> (String, String)
splitString _ [] = ([], [])
splitString c (x:xs)
    | x == c     = ([], xs)
    | otherwise  = (x : fst ret, snd ret)
      where
        ret = splitString c xs

--substrnigs from symbol
subStrings :: Char -> String -> [String]
subStrings _ []  = []
subStrings c str = first : subStrings c rest
  where
    result = splitString c str
    first  = fst result
    rest   = snd result

createTilemap :: String -> Tilemap
createTilemap str = map (subStrings ' ') $ subStrings '\n' str

--create player from tilemap position
findPlayer :: Tilemap -> Player
findPlayer = findPlayer2 0

--help function
findPlayer2 :: Int -> Tilemap -> Player
findPlayer2 _ []   = createPlayer (0, 0)
findPlayer2 y (str:rest)
    | findP == len = findPlayer2 (y + 1) rest
    | otherwise    = createPlayer (y, findP)
      where
        len   = length str
        findP = len - (length (dropWhile (\x -> head x /= 'p') str))

--create enemies from tilemap positions
findEnemies :: Tilemap -> [Enemy]
findEnemies = findEnemies2 0

--numberToObjectType
genEnemy :: Int -> EnemyType
genEnemy 1 = Melee
genEnemy 2 = Range
genEnemy _ = Mage

--help function
findEnemies2 :: Int -> Tilemap -> [Enemy]
findEnemies2 _ []  = []
findEnemies2 y (str:rest)
    | findE == len = findEnemies2 (y + 1) rest
    | otherwise    = createEnemy (y, findE) (genEnemy t) :
                     findEnemies2 y ((sl ++ ["v00"] ++ (tail sr)) : rest)
      where
        len   = length str
        sr    = dropWhile (\x -> head x /= 'e') str
        t     = read . tail . head $ sr
        sl    = takeWhile (\x -> head x /= 'e') str
        findE = len - (length sr)

createScene :: Tilemap -> Scene
createScene tmap =
    Scene
        (findPlayer tmap)
        []
        (findEnemies tmap)
        edit
  where
    rewrite p
        | head p == 'e' = "v00"
        | head p == 'p' = "v00"
        | otherwise     = p
    edit = map (map (rewrite)) tmap