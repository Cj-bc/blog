--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList)
import           Data.Default (def)

import           Hakyll.Web.Html (withUrls)
import           Hakyll.Core.Compiler (getResourceFilePath)
import           System.FilePath.Posix (takeBaseName)
import           Data.List (isPrefixOf)

import           MyBlog.Contexts
--------------------------------------------------------------------------------

blogName :: String
blogName = "CLI! CLI! CLI!"

pandocMarkdownCfg :: ReaderOptions
pandocMarkdownCfg = def { readerExtensions = extensionsFromList [Ext_emoji, Ext_task_lists
                                                                , Ext_backtick_code_blocks, Ext_fenced_code_attributes
                                                                , Ext_header_attributes
                                                                , Ext_raw_html
                                                                ]
                        }

feedConfiguration :: FeedConfiguration
feedConfiguration = FeedConfiguration {
                      feedTitle         = "CLI! CLI! CLI!"
                    , feedDescription   = "Cj-bc's personal blog posts."
                    , feedAuthorName    = "Cj-bc a.k.a Cj.BC_SD"
                    , feedAuthorEmail   = "cj.bc-sd@outlook.jp"
                    , feedRoot          = "https://cj-bc.github.io/blog"
                    }

modifySourceUrl :: Item String -> Compiler (Item String)
modifySourceUrl item = do
        fn <- takeBaseName <$> getResourceFilePath
        return $ fmap (fixSourceDist fn) item
    where
        isSourceUrl = isPrefixOf "/src"
        fixSourceDist fn = withUrls $ \x -> if isSourceUrl x then fixSourceDist' fn x else x
        fixSourceDist' fn x = "/src/" ++ fn ++ (drop 4 x)

main :: IO ()
main = hakyll $ do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith pandocMarkdownCfg def
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= modifySourceUrl
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["feeds/atom/general.xml"] $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
            renderAtom feedConfiguration feedCtx posts

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" ""                    `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
