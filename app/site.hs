--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.String (fromString)
import           System.Environment (getArgs)
import           System.FilePath (takeFileName, takeExtension, (</>))
import           System.FilePath.Glob (glob)
import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList, WriterOptions(..))
import           Text.Pandoc.Error (PandocError)
import           Text.Pandoc.Writers (writeMarkdown)
import           Text.Pandoc.Readers (readOrg, readMarkdown)
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
                           , writerExtensions = extensionsFromList [Ext_yaml_metadata_block, Ext_backtick_code_blocks]
                           }

-- | insert default template for markdown
setupMarkdownDefaultTemplate :: PandocPure ()
setupMarkdownDefaultTemplate = do
  -- Do not insert "/" at begining of path
  files <- (getsPureState stFiles)
  let dummyDataFiles = insertInFileTree "data/data/templates/default.markdown" defaultMarkdownTemplate files
  modifyPureState (\st -> st {stFiles = dummyDataFiles })


-- | Convert Org format into astro's markdown format
convertOrgFormat :: T.Text -> Either PandocError T.Text
convertOrgFormat original = runPure $ do
  setupMarkdownDefaultTemplate
  tmpl <- compileDefaultTemplate "markdown"
  ast <- readOrg pandocMarkdownCfg original
  writeMarkdown (pandocWriterCfg tmpl) (MD.setBlogMetaDataToPandoc (MD.collectMetaData ast) ast)

-- | Convert Markdown format (passthrough with Pandoc transformations)
-- Markdown files with YAML frontmatter are parsed directly by Pandoc
convertMarkdownFormat :: T.Text -> Either PandocError T.Text
convertMarkdownFormat original = runPure $ do
  setupMarkdownDefaultTemplate
  tmpl <- compileDefaultTemplate "markdown"
  ast <- readMarkdown pandocMarkdownCfg original
  writeMarkdown (pandocWriterCfg tmpl) ast

-- | Process a single file based on its extension
processFile :: FilePath -> FilePath -> IO ()
processFile distDir fn = do
  content <- TIO.readFile fn
  let converter = case takeExtension fn of
                    ".org" -> convertOrgFormat
                    ".md"  -> convertMarkdownFormat
                    _      -> convertOrgFormat  -- default to org
      result = either (T.pack . show) id $ converter content
  TIO.writeFile (distDir </> takeFileName fn) result

main :: IO ()
main = do
  let distDir = "/tmp/blogPosts"
      orgGlob = "./posts/*.org"
      mdGlob  = "./posts/*.md"
  orgFiles <- glob orgGlob
  mdFiles  <- glob mdGlob
  mapM_ (processFile distDir) (orgFiles ++ mdFiles)

--------------------------------------------------------------------------------
