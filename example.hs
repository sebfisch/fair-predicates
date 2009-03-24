import Data.Answer

data Tree = Tip | Fork Tree Int Tree

isSorted :: Tree -> Answer
isSorted Tip          = true
isSorted (Fork l n r) = allEntries (<n) l
                     /\ allEntries (>n) r
                     /\ isSorted l
                     /\ isSorted r

allEntries :: (Int -> Bool) -> Tree -> Answer
allEntries _ Tip          = true
allEntries p (Fork l n r) = answer (p n) /\ allEntries p l /\ allEntries p r

decreasing :: Int -> Tree
decreasing n = Fork (decreasing (n-1)) n Tip

-- should answer 'false'
testInfiniteLeft :: Answer
testInfiniteLeft = isSorted (Fork (decreasing 0) 1 (Fork Tip 0 Tip))

increasing :: Int -> Tree
increasing n = Fork Tip n (increasing (n+1))

-- should answer 'false'
testInfiniteRight :: Answer
testInfiniteRight = isSorted (Fork (Fork Tip 2 Tip) 1 (increasing 2))

main = do putStrLn "The following tests should answer 'false':"
          putStrLn $ "infinite left subtree: " ++ show testInfiniteLeft
          putStrLn $ "infinite right subtree: " ++ show testInfiniteRight
