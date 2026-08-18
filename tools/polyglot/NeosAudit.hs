-- NeOS Profile Auditor in Haskell (GHC)
module Main where

import System.Directory (doesFileExist)
import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import System.FilePath ((</>))
import Data.List (nub)

requiredFiles :: [FilePath]
requiredFiles =
  [ "profile/profiledef.sh"
  , "profile/pacman.conf"
  , "profile/grub/grub.cfg"
  , "profile/syslinux/syslinux.cfg"
  , "profile/packages.x86_64"
  , "profile/airootfs/etc/pacman.d/neos-mirrorlist"
  ]

main :: IO ()
main = do
  args <- getArgs
  let root = if null args then "." else head args
  putStrLn "\ESC[1;36m[Haskell::Audit]\ESC[0m Auditing NeOS profile invariants..."

  -- Check required files
  missing <- filterM' (\f -> not <$> doesFileExist (root </> f)) requiredFiles
  if not (null missing)
    then do
      putStrLn $ "❌ Missing required files: " ++ show missing
      exitFailure
    else do
      -- Parse package list
      content <- readFile (root </> "profile/packages.x86_64")
      let rawPkgs = filter (not . null) . map strip . lines $ content
      let pkgs = filter (not . isComment) rawPkgs
      if length pkgs /= length (nub pkgs)
        then do
          putStrLn "❌ Duplicate package entries found in Haskell audit"
          exitFailure
        else do
          putStrLn $ "\ESC[1;32m✓ Haskell Audit Passed! Verified " ++ show (length pkgs) ++ " packages.\ESC[0m"
          exitSuccess
  where
    strip = reverse . dropWhile (`elem` " \t\r\n") . reverse . dropWhile (`elem` " \t\r\n")
    isComment ('#':_) = True
    isComment _       = False

filterM' :: Monad m => (a -> m Bool) -> [a] -> m [a]
filterM' _ [] = return []
filterM' p (x:xs) = do
  flg <- p x
  ys <- filterM' p xs
  return $ if flg then x:ys else ys
