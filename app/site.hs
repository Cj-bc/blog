--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList)
import           Data.Default (def)
import qualified Data.Text as T

import qualified MyBlog.MetaData as MD
--------------------------------------------------------------------------------


pandocMarkdownCfg :: ReaderOptions
pandocMarkdownCfg = def { readerExtensions = extensionsFromList [Ext_emoji, Ext_task_lists
                                                                , Ext_backtick_code_blocks, Ext_fenced_code_attributes
                                                                , Ext_header_attributes
                                                                , Ext_raw_html
                                                                ]
                        }
main :: IO ()

--------------------------------------------------------------------------------
