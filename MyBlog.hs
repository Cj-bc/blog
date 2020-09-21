{-|
Module      : MyBlog
Description : Common codes for every executables
Copyright   : (c) Cj.bc_sd a.k.a Cj-bc, 2020
Maintainer  : cj.bc-sd@outlook.jp
Stability   : experimental


-}
module MyBlog where

import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList)
import           Data.Default (def)

pandocMarkdownCfg :: ReaderOptions
pandocMarkdownCfg = def { readerExtensions = extensionsFromList [Ext_emoji, Ext_task_lists
                                                                , Ext_backtick_code_blocks, Ext_fenced_code_attributes
                                                                , Ext_header_attributes
                                                                , Ext_raw_html
                                                                ]
                        }

postRoute :: Routes
postRoute = setExtension "html"

isSourceUrl = isPrefixOf "/images"
