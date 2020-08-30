{-# LANGUAGE OverloadedStrings #-}

module MyBlog.Contexts where
import              Hakyll
import qualified    Data.Attoparsec.ByteString as P


postCtx :: Context String
postCtx =
    dateField "date" "%B %e, %Y"
    <> defaultContext
