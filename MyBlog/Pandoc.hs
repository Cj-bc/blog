{-# LANGUAGE OverloadedStrings #-}
{- |
    Module      : MyBlog.Pandoc
    Copyright   : Copyright (c) 2021 Cj-bc a.k.a Cj.bc_sd
    LICENSE     :

This module provides some functions related to Pandoc
-}
module MyBlog.Pandoc where

import Text.Pandoc.Walk
import Text.Pandoc.Definition

-- | Combines transformations I do against posts
myPandocTransform :: Pandoc -> Pandoc
myPandocTransform = walk codeBlockFormat

-- | Defines code block format
--
-- TODO: detect correct filetype for label
--  I want to show filetype on the top-right side by using "attached label".
--  Current implementation simply show 'class_'es of 'CodeBlock', but it could contain not
--  only filetype but also other stuff. So I want to detect filetype from them and use only it.
codeBlockFormat :: Block -> Block
codeBlockFormat (CodeBlock attr@(_, (cl:classes), _) t) = Div ("", ["ui", "segment"], mempty)
                                                            [Div ("", ["ui", "top", "right", "attached", "label"], mempty) [Plain [Str cl]]
                                                            , CodeBlock attr t
                                                            ]
--codeBlockFormat (Div (ident, classes@(cl:_), kv) blocks) | "SourceCode" `elem` classes
--        = Div (ident, classes, kv) $
--                [Div ("", ["ui", "top", "right", "attached", "label"], mempty) [Plain [Str cl]]]
--                <> blocks
codeBlockFormat other = other
