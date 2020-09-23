{-# LANGUAGE OverloadedStrings #-}
import  Hakyll
import  MyBlog
import  Text.Pandoc.Definition (Div, nullAttr, Plain, Str, Link)
import qualified Data.Text as T

sourcesDir = "https://github.com/Cj-bc/blog/blob/source/images"

convertSrcPath :: Item String -> Compiler (Item String)
convertSrcPath item = withUrls $ \x -> if isSourceUrl x then mkAbsolute x else x

mkAbsolute x = sourcesDir <> drop 4 x <> "?raw=true"

insertRepositoryInfo :: Item Pandoc -> Compiler (Item Pandoc)
insertRepositoryInfo = withItemBody . walk $ (:) noteBlock
    where
        linkForPost :: a -> Text -- WIP, currently it points to top page of blog, but I want it to point to specific post
        linkForPost = const "https://cj-bc.github.com/blog"
        _title      = "WIP -- 仮タイトル" -- WIP
        noteBlock   = Div nullAttr [Plain [Str ":::message"
                                          ,Str "このポストは"
                                          , Link nullAttr [Str "ブログ"], (linkForPost, _title)]
                                          ,Str "からの転載です。"
                                          ,Str ":::"
                                   ]

-- | Convert 'Pandoc' data into Markdown formatted 'String'
--
-- I borrowed some codes from 'Hakyll.Web.Pandoc.writePandocWith'
writePandocAsMarkdown :: Item Pandoc -> Compiler (Item String)
writePandocAsMarkdown item = case runPure $ writeMarkdown (def {writeExtensions = pandocMarkdownCfg}) pandoc of
                                Left err -> error $ "writePandocAsMarkdown: " ++ show err
                                Right item' -> Item itemi $ T.unpack item'
                    where
                      itemi  = itemIdentifier item
                      pandoc = itemBody item



main :: IO ()
main = hakyll $ do
    match "posts/*" $ do
        route $ idRoute
        compile $ convertSrcPath
            >>= readPandocWith pandocMarkdownCfg
            >>= insertRepositoryInfo
            >>= writePandocAsMarkdown
