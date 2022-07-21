{-# LANGUAGE OverloadedStrings #-}
{- |
    Module      : MyBlog.Pandoc
    Copyright   : Copyright (c) 2021 Cj-bc a.k.a Cj.bc_sd
    LICENSE     :

This module provides some functions related to Pandoc
-}
module MyBlog.Pandoc where

import Data.Maybe (listToMaybe)
import Text.Pandoc.Walk
import Text.Pandoc.Definition
import Text.Pandoc.Shared
import qualified Data.Text as T

addClass :: [T.Text] -> Attr -> Attr
addClass txt (ident, classes, kv) = (ident, classes ++ txt, kv)


-- | Combines transformations I do against posts
myPandocTransform :: Pandoc -> Pandoc
myPandocTransform = walk codeBlockFormat
                  . walk blockQuoteFormat
                  . walk (walk imageFormat :: Block -> Block)
                  . walk addAnchorToHeader
                  . walk (walk orgLinkFormat :: Block -> Block)
                  . walk tableFormat
                  . headerShift (-1)


-- | Defines code block format

-- TODO: detect correct filetype for label
--  I want to show filetype on the top-right side by using "attached label".
--  Current implementation simply show 'class_'es of 'CodeBlock', but it could contain not
--  only filetype but also other stuff. So I want to detect filetype from them and use only it.
codeBlockFormat :: Block -> Block
codeBlockFormat (CodeBlock (ident, classes, kv) t) = Div ("", ["ui", "segment"], mempty)
                                                                [Div ("", ["ui", "top", "right", "attached", "label"], mempty) [Plain [Str filetype]]
                                                                , CodeBlock (ident, classes ++ ["SourceCode"], kv) t
                                                                ]
        where
            filetype = maybe "" id (listToMaybe  classes)
codeBlockFormat other = other

tableFormat :: Block -> Block
tableFormat (Table attr c csp th tbs tf) = Table (addClass ["ui", "celled", "table"] attr) c csp th tbs tf
tableFormat other = other

imageFormat :: Inline -> Inline
imageFormat (Image attr inlines target) = Image (addClass ["ui", "rounded", "image"] attr) inlines target
imageFormat other = other

blockQuoteFormat :: Block -> Block
blockQuoteFormat (BlockQuote cs) = Div (mempty, ["ui", "piled", "segment"], [("style", "z-index: 0")]) [BlockQuote cs]
blockQuoteFormat other = other

addAnchorToHeader :: Block -> Block
addAnchorToHeader (Header lvl (id_, classes, kv) inlines) = Header lvl (id_', classes, kv) inlines
        where
            id_' = if T.null id_ then anchored
                                 else id_
            anchored = mconcat $ map stringify inlines
addAnchorToHeader other = other

-- | Convert Org mode custom external links into proper 'Inline'
-- As Custom links are 
orgLinkFormat :: Inline -> Inline
orgLinkFormat l@(Link attr alt (lt, desc))
  | "twitter:" `T.isPrefixOf` lt = Link attr alt ("https://twitter.com/" <> T.drop (T.length "twitter:") lt, desc)
  | "github:" `T.isPrefixOf` lt  = Link attr alt ("https://github.com/"  <> T.drop (T.length "github:")  lt, desc)
  | otherwise                    = l
orgLinkFormat i = i
