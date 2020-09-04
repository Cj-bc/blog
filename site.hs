--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList)
import           Data.Default (def)
import           Control.Monad (forM_)

import           Hakyll.Web.Html (withUrls)
import           Hakyll.Core.Compiler (getResourceFilePath)
import           System.FilePath.Posix (takeBaseName)
import           Data.List (isPrefixOf)

import           MyBlog.Contexts
--------------------------------------------------------------------------------

blogName :: String
blogName = "CLI! CLI! CLI!"

feedUrlBase     = "/feeds"
atomFeedUrlBase = feedUrlBase <> "/atom"
rssFeedUrlBase  = feedUrlBase <> "/rss"
tagFeedUrlBase  = "/tag"
tagAtomFeedUrl tag = atomFeedUrlBase <> tagFeedUrlBase <> "/" <> tag <> ".xml"
tagRssFeedUrl  tag = rssFeedUrlBase  <> tagFeedUrlBase <> "/" <> tag <> ".xml"


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
        isSourceUrl = isPrefixOf "/images"
        fixSourceDist fn = withUrls $ \x -> if isSourceUrl x then fixSourceDist' fn x else x
        fixSourceDist' fn x = "/images/" ++ fn ++ (drop 4 x)

forEachTag :: Tags -> (String -> Pattern -> Rules ()) -> Rules ()
forEachTag tags rules =
    forM_ (tagsMap tags) $ \(tag, identifiers) ->
        rulesExtraDependencies [tagsDependency tags] $
            rules tag $ fromList identifiers

main :: IO ()
main = hakyll $ do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    tags <- buildTags "posts/*" (fromCapture "tags/*.html")

    tagsRules tags $ \tag pattern -> do
        let title = "タグ \"" ++ tag ++ "\" がつけられた投稿"
        route idRoute
        compile $ do
            let ctx = constField "title" title
                      <> constField "atomFeedUrl" (tagAtomFeedUrl tag)
                      <> constField "rssFeedUrl"  (tagRssFeedUrl tag)
                      <> listField "posts" (postCtx tags) (recentFirst =<< loadAll pattern)
                      <> defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/tag.html" ctx
                >>= loadAndApplyTemplate "templates/default.html" ctx
                >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompilerWith pandocMarkdownCfg def
            >>= loadAndApplyTemplate "templates/post.html"    (postCtx tags)
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" (postCtx tags)
            >>= modifySourceUrl
            >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" (postCtx tags) (return posts) `mappend`
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

    create ["feeds/rss/general.xml"] $ do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots "posts/*" "content"
            renderRss feedConfiguration feedCtx posts

    forEachTag tags $ \tag pattern -> do
        create [fromFilePath $ "feeds/atom/tag/" ++ tag ++ ".xml"] $ do
            route idRoute
            compile $ do
                posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots pattern "content"
                renderAtom feedConfiguration feedCtx posts

    forEachTag tags $ \tag pattern -> do
        create [fromFilePath $ "feeds/rss/tag/" ++ tag ++ ".xml"] $ do
            route idRoute
            compile $ do
                posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots pattern "content"
                renderRss feedConfiguration feedCtx posts
    -- }}}


    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let indexCtx =
                    listField "posts" (postCtx tags) (return posts) `mappend`
                    constField "title" ""                    `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
