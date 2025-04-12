module Main where

-- banner :: String
-- banner  = "\ESC[1G\ESC[2K━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\nEnter your name: "

main :: IO ()
main = do
    -- putStr (banner)
    name <- getLine
    hprint (map atom ["hi there", name])

pair :: a -> b -> (a, b)
pair fst snd = (fst, snd)

fst :: (a, b) -> a
fst (x, y) = x

snd :: (a, b) -> b
snd (x, y) = y

atom :: String -> String
atom s = "(" ++ s ++ ")"


-- list = pair 1 (pair 2 (pair 3 (pair 4 ())

hprint :: [String] -> IO ()
hprint x = do
    mapM_ putStr x
