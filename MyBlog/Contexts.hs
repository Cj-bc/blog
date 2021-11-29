{-# LANGUAGE OverloadedStrings #-}
module MyBlog.Contexts where
import              Hakyll
import              Hakyll.Web.Tags (Tags)
import qualified    Data.Attoparsec.Text as P
import qualified Data.Text as T
import Text.Blaze.Html (toHtml, toValue, (!))
import qualified Text.Blaze.Html5.Attributes as A
import qualified Text.Blaze.Html5 as H
import              Shelly

defaultContext' :: Context String
defaultContext' = constField "highlightjsTheme" "night-owl"
                <> defaultContext

dateFormat :: T.Text
dateFormat = "%B %e, %Y"

postCtx :: Tags -> Context String
postCtx tags =
    dateField "date" (T.unpack dateFormat)
    <> tagsFieldWithFomanticClassName "tags" tags
    <> updateDataField
    <> teaserField "teaser" "raw content"
    <> thumbnailField
    <> defaultContext'

updateDataField :: Context String
updateDataField = field "updated" $ \item -> do
                      fp <- T.pack <$> getResourceFilePath
                      date  <- unsafeCompiler . shelly $ do
                            lsFilesResult <- run "git" ["ls-files", "--", fp]
                            if (T.null lsFilesResult)
                            then return Nothing
                            else P.maybeResult <$> P.parse parseDate <$> run "git" ["log", "--date=format:" `T.append` dateFormat, "--", fp]
                                                                     -|- run "grep" ["^Date:"]
                                                                     -|- run "head" ["-n1"]
                      return $ maybe "- No update yet -" id date -- TODO: use 'created time'

parseDate :: P.Parser String
parseDate = do
    P.string "Date:"
    P.many' " "
    P.manyTill P.anyChar P.endOfLine

-- | Get thumbnail image from meta
--
-- TODO: retrieve thumbnail from post itself(using 'functionField')
thumbnailField :: Context String
thumbnailField = constField "thumbnail" "hard hat"

-- | Almost same as 'tagsField', but this will give each tags class name for Fomantic-UI
--
-- TODO: support some Fomantic UI's variations?
--       I want to make this not only for Fomantic but also for other customizations
tagsFieldWithFomanticClassName = tagsFieldWith getTags simpleRenderLink' mconcat -- I don't know what is good function that alter mconcat.
    where
        -- | This function is copied and have some modification:
        --   source: https://hackage.haskell.org/package/hakyll-4.13.4.1/docs/src/Hakyll.Web.Tags.html
        simpleRenderLink' :: String -> (Maybe FilePath) -> Maybe H.Html
        simpleRenderLink' _   Nothing         = Nothing
        simpleRenderLink' tag (Just filePath) = Just $
            H.a ! A.title (H.stringValue ("All pages tagged '"++tag++"'."))
                ! A.href (toValue $ toUrl filePath)
                ! A.class_ "ui tag label"
                $ toHtml tag

feedCtx = dateField "date" (T.unpack dateFormat)
          <> bodyField "description"
          <> defaultContext'

-- | Common Contexts for pages that holds post list
postListCtx :: Tags -> [Item String] -> Context b
postListCtx tags posts = listField "posts" (titleSnapshotField "title" <> postCtx tags) (return posts)

-- | スナップショットに仕舞ってあるタイトルを取り出して使う
titleSnapshotField :: String -> Context String
titleSnapshotField fName = field fName $ \item -> loadSnapshotBody (itemIdentifier item) "title"
