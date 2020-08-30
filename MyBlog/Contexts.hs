{-# LANGUAGE OverloadedStrings #-}
module MyBlog.Contexts where
import              Hakyll
import qualified    Data.Attoparsec.Text as P
import qualified Data.Text as T
import              Shelly


dateFormat = "%B %e, %Y"

postCtx :: Context String
postCtx =
    dateField "date" dateFormat
    <> updateDataField
    <> defaultContext

updateDataField :: Context String
updateDataField = field "updated" $ \item -> do
                      fp <- T.pack <$> getResourceFilePath
                      date  <- unsafeCompiler $ shelly $ run "git" ["log", "--date=format:" ++ dateFormat, "--", fp]
                                                         -|- run "grep" ["^Date:"]
                                                         -|- run "head" ["-n1"]
                      return . maybe ("failed to fetch") id . P.maybeResult $ P.parse parseDate date

parseDate :: P.Parser String
parseDate = do
    P.string "Date:"
    P.many' " "
    T.unpack <$> P.take 10
