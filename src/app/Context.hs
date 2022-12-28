{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TypeOperators       #-}

module Context where

import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.HashMap.Strict  as HM
import           Data.List            (intercalate, isInfixOf, isPrefixOf)
import           Data.Monoid
import qualified Data.Text            as T
import           Hakyll
import           Hakyll.Core.Metadata
import           Prelude              hiding (div, span)

--------------------------------------------------------------------------------

tagsCtx :: Context a
tagsCtx =
  field "tags" $ \item -> do
    let identifier = itemIdentifier item

    metadata   <- getMetadata identifier  -- $ itemIdentifier item

    let tags = case HM.lookup "tags" metadata of
                 Nothing    -> ""
                 Just value ->   -- this is not actual value, case it again
                   case value of
                     String x -> T.unpack x
                     _        -> ""

    return tags

articleContextWithTags :: Tags -> Context String
articleContextWithTags tags =
  tagsField "tags" tags
    <> articleCtx

articleUrl :: Item a -> Compiler String
articleUrl item =
  fmap (maybe "" toUrl) . getRoute . setVersion Nothing $ itemIdentifier item

articleUrlCtx :: Context a
articleUrlCtx =
  field "articleUrl" articleUrl

articleCtx :: Context String
articleCtx =
  mconcat
    [  tagsCtx
    ,  articleUrlCtx
    ,  defaultContext
    ]

defaultCtx :: Context String
defaultCtx =
  mconcat
    [ articleUrlCtx
    , defaultContext
    ]
