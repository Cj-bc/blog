{-# LANGUAGE OverloadedStrings, TemplateHaskell #-}
module MyBlog.MetaData where
import Lens.Micro.Platform (makeLenses, set, (.~), (&))
import Data.Foldable (fold)
import Data.Default (Default(..))
import Text.Pandoc.Shared (safeRead, splitTextBy)
import Text.Pandoc.Definition
import Data.Text (Text)

data PostKind = Memo | Diary | Knowledge | Advertisment | Translation | HowTo
              deriving (Read, Show, Eq)

instance Semigroup PostKind where
  _ <> p' = p'

instance Monoid PostKind where
  mempty = Memo

data PostStatus = Normal | Accuracy | Outdated | Archive
                deriving (Read, Show, Eq, Ord)

instance Semigroup PostStatus where
  p <> p' = max p p'
  
instance Monoid PostStatus where
  mempty = Normal

data PostProgress = Empty | WIP | Published
                  deriving (Read, Show, Eq, Ord)

instance Semigroup PostProgress where
  p <> p' = max p p'
  
instance Monoid PostProgress where
  mempty = Empty

data BlogMetaData = BlogMetaData { _tags :: [Text]
                                 , _author :: Text
                                 , _kind :: PostKind
                                 , _status :: PostStatus
                                 , _progress :: PostProgress
                                 }
                  deriving (Read, Show, Eq)
makeLenses ''BlogMetaData
  
instance Default BlogMetaData where
  def = BlogMetaData [] "" Memo Normal Empty

instance Semigroup BlogMetaData where
  (BlogMetaData ts a k s p) <> (BlogMetaData ts' a' k' s' p')
    = (BlogMetaData (ts<>ts') (a<>a') (k<>k') (s<>s') (p<>p'))

instance Monoid BlogMetaData where
  mempty = def

collectMetaData :: Pandoc -> BlogMetaData
collectMetaData (Pandoc _ (titleBlock:_)) = maybe def id . fold . fmap readOneMetaData $ getMeta titleBlock
  where
    getMeta :: Block -> [(Text, Text)]
    getMeta (Header 1 (_, _, kv) _) = kv
    getMeta _ = []
collectMetaData _ = mempty


-- | 一種類のメタデータを読む
readOneMetaData :: (Text, Text) -> Maybe BlogMetaData
readOneMetaData ("blog_post_kind", k)     = safeRead k >>= pure . flip (set kind    ) def
readOneMetaData ("blog_post_status", s)   = safeRead s >>= pure . flip (set status  ) def
readOneMetaData ("blog_post_progress", p) = safeRead p >>= pure . flip (set progress) def
readOneMetaData ("tags", t)               = Just $ def&tags.~(filter (/= "") $ splitTextBy (== ':') t)
readOneMetaData _                         = Nothing
