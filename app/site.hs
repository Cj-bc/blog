--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import qualified Data.Map as M
import           Data.Maybe (fromMaybe)
import           Data.Monoid (mappend)
import           Hakyll
import           Text.Pandoc.Options (ReaderOptions(..), Extension(..), extensionsFromList)
import           Text.Pandoc.Shared (stringify, splitTextBy)
import           Text.Pandoc.Definition (docTitle, Pandoc(Pandoc))
import           Data.Default (def)
import qualified Data.Text as T
import           Control.Monad (forM_)
import           Lens.Micro.Platform ((^.), view)
import           Hakyll.Web.Html (withUrls)
import           Hakyll.Core.Compiler (getResourceFilePath)
import qualified Shelly as Shelly
import           System.FilePath.Posix (takeBaseName)
import           Data.List (isPrefixOf)

import           MyBlog.Contexts
import           MyBlog.Pandoc
import qualified MyBlog.MetaData as MD
--------------------------------------------------------------------------------

blogName :: String
blogName = "CLI! CLI! CLI!"

highlightjsTheme = "night-owl"

feedUrlBase     = "/feeds"
atomFeedUrlBase = feedUrlBase <> "/atom"
rssFeedUrlBase  = feedUrlBase <> "/rss"
tagFeedUrlBase  = "/tag"
tagAtomFeedUrl tag = atomFeedUrlBase <> tagFeedUrlBase <> "/" <> tag <> ".xml"
tagRssFeedUrl  tag = rssFeedUrlBase  <> tagFeedUrlBase <> "/" <> tag <> ".xml"


postsPattern = "posts/*.org"

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
        prefix      = "/images"
        isSourceUrl = isPrefixOf prefix
        fixSourceDist fn = withUrls $ \x -> if isSourceUrl x then fixSourceDist' fn x else x
        fixSourceDist' fn x = "/images/" ++ fn ++ (drop (length prefix) x)


type Renderer = FeedConfiguration -> Context String -> [Item String] -> Compiler (Item String)

-- | create the same object for several feeds
--
-- Currently, this will generate RSS and Atom feeds.
createFeeds :: String -> (Renderer -> Rules ()) -> Rules ()
createFeeds fileName rules = do
    -- Drop 1 here to drop '/' letter in the UrlBase.
    -- Starting with '/' is required to use 'relativizeUrls', but for 'create'
    -- it should not be used.
    create [fromFilePath . drop 1 $ atomFeedUrlBase <> fileName] $ rules renderAtom
    create [fromFilePath . drop 1 $ rssFeedUrlBase  <> fileName] $ rules renderRss

main :: IO ()
main = hakyll $ do
    match "images/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/dist/semantic.min.css" $ do
        route $ constRoute "css/semantic.min.css"
        compile copyFileCompiler

    match "css/dist/semantic.min.js" $ do
        route $ constRoute "js/semantic.min.js"
        compile copyFileCompiler

    match "css/dist/themes/**" $ do
        route $ gsubRoute "dist/" (const "")
        compile copyFileCompiler

    match "css/myCustom.css" $ do
        route $ constRoute "css/myCustom.css"
        compile copyFileCompiler

    -- Tag pages that the name is in this list will be generated 
    tagNameList <- fmap T.unpack . splitTextBy (== '\n') <$> preprocess (Shelly.shelly $ Shelly.bash "./scripts/gen-tagslist.sh" [])

    -- Create tag pages
    sequence . flip fmap tagNameList $ \tagString ->
      create [fromCapture "tags/*.html" tagString] $ do
        route idRoute
        compile $ do
          -- Get list of tags for each post
          tagsList <- loadAllSnapshots "posts/*.org" "tags" :: Compiler [Item [String]]
          -- 'tagsMap' below is almost same as Hakyll.Web.Tags.tagsMap,
          -- But I don't convert it into List.
          let tagsMap = foldl (M.unionWith (++)) mempty (f <$> tagsList) :: M.Map String [Identifier]
              f (Item ident tagStrings) = M.fromList $ zip tagStrings $ repeat [ident]
              taggedPostIds = fromMaybe [] $ M.lookup tagString tagsMap

          posts <- recentFirst =<< (sequence $ load <$> taggedPostIds) 

          let ctx = constField "title" "tag page"
                    <> constField "atomFeedUrl" (tagAtomFeedUrl tagString)
                    <> constField "rssFeedUrl" (tagRssFeedUrl tagString)
                    <> postListCtx posts
                    <> defaultContext'
          makeItem ""
            >>= loadAndApplyTemplate "templates/tag.html" ctx
            >>= loadAndApplyTemplate "templates/default.html" ctx
            >>= relativizeUrls

    sequence . flip fmap tagNameList $ \tagName ->
      createFeeds (mconcat [tagFeedUrlBase, "/", tagName, ".xml"]) $ \renderer -> do
        route idRoute
        compile $ do
          posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots postsPattern "content"
          renderer feedConfiguration feedCtx posts

    match postsPattern $ do
        route $ setExtension "html"
        compile $ do
            originalPostData <- getResourceBody >>= readPandocWith pandocMarkdownCfg
            pandocData@(Item ident (Pandoc pandocMeta _)) <- traverse (return . myPandocTransform) originalPostData
            let titleMetadata = T.unpack . foldl (\p n -> p <> stringify n) "" . docTitle $ pandocMeta
                metadataSet = fmap MD.collectMetaData originalPostData
            currentIdentifier <- getUnderlying 
            saveSnapshot "title" (Item currentIdentifier titleMetadata)

            -- Store tags of this Post in snapshot
            saveSnapshot "tags" (fmap T.unpack . view MD.tags <$> metadataSet)
            tags <- buildTagsWith (flip loadSnapshotBody "tags") postsPattern (fromCapture "tags/*.html")

            let ctx  = constField "title" titleMetadata <> postCtx
            -- pandocCompilerWithTransform  def myPandocTransform
            return (writePandocWith def pandocData)
              >>= saveSnapshot "raw content"
              >>= loadAndApplyTemplate "templates/post.html" ctx
              >>= saveSnapshot "content"
              >>= loadAndApplyTemplate "templates/default.html" ctx
              >>= modifySourceUrl
              >>= relativizeUrls

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll postsPattern
            tags <- buildTagsWith (flip loadSnapshotBody "tags") postsPattern (fromCapture "tags/*.html")

            -- TODO: listFieldを元にして, 各postにContextも独自に適用できるフィールドを生成する
            -- id:6da7268f-a417-436f-ab64-8aaef1373dbe
            let archiveCtx =
                    postListCtx posts `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext'

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    createFeeds "/general.xml" $ \renderer -> do
        route idRoute
        compile $ do
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots postsPattern "content"
            renderer feedConfiguration feedCtx posts

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll postsPattern
            tags <- buildTagsWith (flip loadSnapshotBody "tags") postsPattern (fromCapture "tags/*.html")
            let indexCtx =
                    postListCtx posts `mappend`
                    constField "title" ""                    `mappend`
                    defaultContext'

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler


--------------------------------------------------------------------------------
