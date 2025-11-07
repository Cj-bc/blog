{-# LANGUAGE OverloadedStrings #-}
module MyBlog.ZennExport where

import qualified Data.Text as T
import qualified Data.Text.IO as TIO
import Data.Text (Text)
import Data.Maybe (fromMaybe, listToMaybe)
import Data.Default (def)
import Data.Time.Format (formatTime, defaultTimeLocale)
import Data.Time.LocalTime (LocalTime)
import Text.Pandoc.Definition
import Text.Pandoc.Readers (readOrg)
import Text.Pandoc.Writers (writeMarkdown)
import Text.Pandoc.Options (ReaderOptions(..), WriterOptions(..), Extension(..), extensionsFromList)
import Text.Pandoc.Class (runPure)
import Text.Pandoc.Error (PandocError)
import System.FilePath (takeFileName, dropExtension, (</>))
import qualified Data.Yaml as Y

-- | Zenn metadata structure
data ZennMeta = ZennMeta
  { zennTitle :: Text
  , zennEmoji :: Text
  , zennType :: Text
  , zennTopics :: [Text]
  , zennPublished :: Bool
  , zennPublishedAt :: Maybe Text
  } deriving (Show)

-- | Extract org-mode metadata from Pandoc Meta
extractOrgMeta :: Meta -> ZennMeta
extractOrgMeta meta =
  let title = extractMetaString "title" meta
      tags = extractTags meta
      date = extractDate meta
      emoji = fromMaybe "📝" (extractMetaString "emoji" meta)
      postType = fromMaybe "tech" (extractMetaString "type" meta)
  in ZennMeta
      { zennTitle = fromMaybe "Untitled" title
      , zennEmoji = emoji
      , zennType = postType
      , zennTopics = tags
      , zennPublished = True
      , zennPublishedAt = date
      }

-- | Extract a string metadata field
extractMetaString :: Text -> Meta -> Maybe Text
extractMetaString key (Meta m) =
  case lookup key m of
    Just (MetaString s) -> Just s
    Just (MetaInlines inlines) -> Just $ T.unwords (map extractInlineText inlines)
    _ -> Nothing

-- | Extract text from Inline
extractInlineText :: Inline -> Text
extractInlineText (Str s) = s
extractInlineText Space = " "
extractInlineText (Code _ s) = s
extractInlineText (Emph inlines) = T.concat (map extractInlineText inlines)
extractInlineText (Strong inlines) = T.concat (map extractInlineText inlines)
extractInlineText _ = ""

-- | Extract tags from metadata, removing colons
extractTags :: Meta -> [Text]
extractTags (Meta m) =
  case lookup "tags" m of
    Just (MetaString s) -> filter (not . T.null) $ map (T.strip . T.filter (/= ':')) $ T.splitOn ":" s
    Just (MetaInlines inlines) ->
      let tagsText = T.concat (map extractInlineText inlines)
      in filter (not . T.null) $ map (T.strip . T.filter (/= ':')) $ T.splitOn ":" tagsText
    Just (MetaList vals) -> concatMap extractListText vals
    _ -> []
  where
    extractListText (MetaString s) = [s]
    extractListText (MetaInlines inlines) = [T.concat (map extractInlineText inlines)]
    extractListText _ = []

-- | Extract date from metadata and format for Zenn
extractDate :: Meta -> Maybe Text
extractDate (Meta m) =
  case lookup "date" m of
    Just (MetaString s) -> Just $ formatDateForZenn s
    Just (MetaInlines inlines) ->
      let dateText = T.concat (map extractInlineText inlines)
      in Just $ formatDateForZenn dateText
    _ -> Nothing

-- | Format date string for Zenn (YYYY-MM-DD hh:mm)
-- Handles org-mode date format: [2020-08-02 Sun] or [2020-08-02 Sun 14:30]
formatDateForZenn :: Text -> Text
formatDateForZenn dateStr =
  let cleaned = T.strip $ T.filter (\c -> c /= '[' && c /= ']') dateStr
      parts = T.words cleaned
      datePart = if null parts then "" else head parts
      timePart = if length parts >= 3 then parts !! 2 else "00:00"
  in datePart <> " " <> timePart

-- | Generate YAML front matter for Zenn
generateZennFrontMatter :: ZennMeta -> Text
generateZennFrontMatter meta =
  let topics = T.intercalate ", " $ map (\t -> "\"" <> t <> "\"") (zennTopics meta)
      publishedAt = case zennPublishedAt meta of
                      Just d -> "published_at: " <> d <> "\n"
                      Nothing -> ""
  in T.unlines
      [ "---"
      , "title: \"" <> escapeYaml (zennTitle meta) <> "\""
      , "emoji: \"" <> zennEmoji meta <> "\""
      , "type: \"" <> zennType meta <> "\""
      , "topics: [" <> topics <> "]"
      , "published: " <> if zennPublished meta then "true" else "false"
      , publishedAt <> "---"
      , ""
      ]

-- | Escape special characters in YAML strings
escapeYaml :: Text -> Text
escapeYaml = T.replace "\"" "\\\"" . T.replace "\\" "\\\\"

-- | Pandoc reader options for org-mode
orgReaderOptions :: ReaderOptions
orgReaderOptions = def { readerExtensions = extensionsFromList
                          [ Ext_emoji
                          , Ext_tex_math_dollars
                          , Ext_footnotes
                          ]
                       }

-- | Pandoc writer options for Zenn markdown
zennWriterOptions :: WriterOptions
zennWriterOptions = def { writerExtensions = extensionsFromList
                           [ Ext_emoji
                           , Ext_task_lists
                           , Ext_backtick_code_blocks
                           , Ext_fenced_code_attributes
                           , Ext_pipe_tables
                           , Ext_footnotes
                           , Ext_tex_math_dollars
                           ]
                        }

-- | Convert org file to Zenn markdown
convertToZenn :: Text -> Either PandocError Text
convertToZenn orgContent = runPure $ do
  Pandoc meta blocks <- readOrg orgReaderOptions orgContent
  let zennMeta = extractOrgMeta meta
      frontMatter = generateZennFrontMatter zennMeta
      -- Create a new Pandoc document without the metadata (it's in front matter now)
      doc = Pandoc nullMeta blocks
  markdown <- writeMarkdown zennWriterOptions doc
  return $ frontMatter <> markdown

-- | Remove date prefix from filename (YYYY-MM-DD-title.org -> title.md)
removeDataPrefix :: FilePath -> FilePath
removeDataPrefix fileName =
  let base = dropExtension $ takeFileName fileName
      -- Remove date pattern: YYYY-MM-DD-
      withoutDate = case T.splitOn "-" (T.pack base) of
                      (y:m:d:rest) | T.length y == 4 && T.length m == 2 && T.length d == 2
                                   -> T.intercalate "-" rest
                      _ -> T.pack base
  in T.unpack withoutDate <> ".md"
