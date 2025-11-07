{-# LANGUAGE OverloadedStrings #-}

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import System.FilePath ((</>), takeDirectory)
import System.FilePath.Glob (glob)
import System.Directory (createDirectoryIfMissing, doesDirectoryExist)
import Control.Monad (forM_)
import System.Exit (exitFailure)

import MyBlog.ZennExport

main :: IO ()
main = do
  let postsDir = "posts"
      outputDir = "zenn-articles"

  -- Check if posts directory exists
  postsExist <- doesDirectoryExist postsDir
  if not postsExist
    then do
      putStrLn $ "Error: posts directory not found: " ++ postsDir
      exitFailure
    else return ()

  -- Create output directory if it doesn't exist
  createDirectoryIfMissing True outputDir

  -- Find all org and md files in posts directory
  orgFiles <- glob (postsDir </> "*.org")
  mdFiles <- glob (postsDir </> "*.md")
  let allFiles = orgFiles ++ mdFiles

  putStrLn $ "Found " ++ show (length allFiles) ++ " files to convert"

  -- Process each file
  forM_ allFiles $ \inputFile -> do
    putStrLn $ "Processing: " ++ inputFile

    -- Read the file
    content <- TIO.readFile inputFile

    -- Convert to Zenn markdown
    case convertToZenn content of
      Left err -> do
        putStrLn $ "  ERROR: " ++ show err
      Right zennMarkdown -> do
        -- Generate output filename (remove date prefix)
        let outputFile = outputDir </> removeDataPrefix inputFile

        -- Write the output
        TIO.writeFile outputFile zennMarkdown
        putStrLn $ "  ✓ Exported to: " ++ outputFile

  putStrLn $ "\nExport complete! Files saved to: " ++ outputDir
