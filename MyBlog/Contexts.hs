{-# LANGUAGE OverloadedStrings #-}
module MyBlog.Contexts where
import              Hakyll
import qualified    Data.Attoparsec.Text as P
import qualified Data.Text as T
import              Shelly


dateFormat :: T.Text
dateFormat = "%B %e, %Y"

postCtx :: Tags -> Context String
postCtx tags =
    dateField "date" (T.unpack dateFormat)
    <> tagsField "tags" tags
    <> updateDataField
    <> teaserField "teaser" "raw content"
    <> thumbnailField
    <> defaultContext

updateDataField :: Context String
updateDataField = field "updated" $ \item -> do
                      fp <- T.pack <$> getResourceFilePath
                      date  <- unsafeCompiler $ shelly $ run "git" ["log", "--date=format:" `T.append` dateFormat, "--", fp]
                                                         -|- run "grep" ["^Date:"]
                                                         -|- run "head" ["-n1"]
                      return . maybe ("failed to fetch") id . P.maybeResult $ P.parse parseDate date

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


feedCtx = dateField "date" (T.unpack dateFormat)
          <> bodyField "description"
          <> defaultContext
