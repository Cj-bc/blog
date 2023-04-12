--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.String (fromString)
import           System.Environment (getArgs)
import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList, WriterOptions(..))
import           Text.Pandoc.Error (PandocError)
import           Text.Pandoc.Writers (writeMarkdown)
import           Text.Pandoc.Readers (readOrg)
import           Text.Pandoc.Class (runPure, modifyPureState, stFiles, FileInfo(FileInfo), insertInFileTree, PandocPure, getsPureState)
import           Text.Pandoc.Builder (setMeta)
import           Text.Pandoc.Templates (compileDefaultTemplate, Template)
import           Data.Default (def)
import qualified Data.Text as T
import qualified Data.Text.IO as TIO

import           MyBlog.Pandoc
import qualified MyBlog.MetaData as MD
--------------------------------------------------------------------------------

-- | File that represents markdown default template.
--
-- Content is retrived from output of @pandoc -D markdown@ command
defaultMarkdownTemplate :: FileInfo
defaultMarkdownTemplate = FileInfo (read "2023-06-03 0:00:00UTC") (fromString content)
  where
    content = unlines ["$if(titleblock)$"
                      , "$titleblock$"
                      , ""
                      , "$endif$"
                      , "$for(header-includes)$"
                      , "$header-includes$"
                      , ""
                      , "$endfor$"
                      , "$for(include-before)$"
                      , "$include-before$"
                      , ""
                      , "$endfor$"
                      , "$if(toc)$"
                      , "$table-of-contents$"
                      , ""
                      , "$endif$"
                      , "$body$"
                      , "$for(include-after)$"
                      , ""
                      , "$include-after$"
                      , "$endfor$"
                      ]

pandocMarkdownCfg :: ReaderOptions
pandocMarkdownCfg = def { readerExtensions = extensionsFromList [Ext_emoji, Ext_task_lists
                                                                , Ext_backtick_code_blocks, Ext_fenced_code_attributes
                                                                , Ext_header_attributes
                                                                , Ext_raw_html, Ext_yaml_metadata_block
                                                                ]
                        }

pandocWriterCfg :: Template T.Text -> WriterOptions
pandocWriterCfg tmpl = def { writerTemplate = Just tmpl
                           , writerExtensions = extensionsFromList [Ext_yaml_metadata_block]
                           }

-- | insert default template for markdown
setupMarkdownDefaultTemplate :: PandocPure ()
setupMarkdownDefaultTemplate = do
  -- Do not insert "/" at begining of path
  files <- (getsPureState stFiles)
  let dummyDataFiles = insertInFileTree "data/data/templates/default.markdown" defaultMarkdownTemplate files
  modifyPureState (\st -> st {stFiles = dummyDataFiles })


-- | Convert Org format into astro's markdown format
convertFormat :: T.Text -> Either PandocError T.Text
convertFormat original = runPure $ do
  setupMarkdownDefaultTemplate
  tmpl <- compileDefaultTemplate "markdown"
  ast <- readOrg pandocMarkdownCfg original
  writeMarkdown (pandocWriterCfg tmpl) (MD.setBlogMetaDataToPandoc (MD.collectMetaData ast) ast)

main :: IO ()
main = do
  args <- getArgs
  case args of
    [] -> putStrLn "Please give filepath"
    (fn:_) ->
      TIO.readFile fn
      >>= (return . either (T.pack . show) id . convertFormat)
      >>= TIO.putStrLn

--------------------------------------------------------------------------------
