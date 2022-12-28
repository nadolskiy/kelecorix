{-# LANGUAGE AllowAmbiguousTypes #-}
{-# LANGUAGE FlexibleContexts    #-}
{-# LANGUAGE FlexibleInstances   #-}
{-# LANGUAGE OverloadedStrings   #-}
{-# LANGUAGE TypeOperators       #-}

{-# OPTIONS_GHC -fno-warn-unused-do-bind #-}

--
-- License     : Copyright
-- Maintainer  : Sergey Bushnyak, sergey.bushnyak@sigrlami.eu
-- Stability   : experimental
-- Portability : GHC
--
-- Entry point for site publishing

import           Control.Applicative
import           Control.Error                   hiding (left)
import           Control.Monad
import           Control.Monad.Trans
import           Data.Aeson
import           Data.Aeson.Types
import qualified Data.HashMap.Strict             as HM
import           Data.List                       (intercalate, isInfixOf,
                                                  isPrefixOf)
import           Data.List
import qualified Data.Map                        as Map
import           Data.Maybe
import           Data.Monoid
import           Data.Ord
import           Data.String.Utils               (replace)
import qualified Data.Text                       as T
import           Data.Time
import qualified Data.Time.Format                as DF
import           Hakyll
import           Hakyll.Core.Metadata
import           Prelude                         hiding (div, span)
import           System.Directory
import           System.FilePath                 (normalise, takeBaseName,
                                                  takeFileName)
import           System.Locale
import           Text.Blaze.Html                 (toHtml, toValue, (!))
import           Text.Blaze.Html.Renderer.String (renderHtml)
import qualified Text.Blaze.Html5                as H
import qualified Text.Blaze.Html5.Attributes     as A
import           Text.Highlighting.Kate.Styles
import           Text.JSON
import qualified Text.Pandoc.Highlighting        as PH
import           Text.Pandoc.Options
import           Text.Pandoc.Options
import           Text.Printf
import qualified Text.Read                       as T


import           Context

--------------------------------------------------------------------------------

langs =
  [ ("English" , "en")
  -- , ("Русский" , "ru")
  -- , ("Dutch", "ne")
  ]

-- List language locales
langLoc = fmap snd langs

config :: Configuration
config =
  defaultConfiguration
    { destinationDirectory = "../out/"
    --, providerDirectory    = "../data/"
    , inMemoryCache        = True
    }

main :: IO ()
main =
  do
    cdir <- getCurrentDirectory
    hakyllWith config $ do

        -- handle css files
        match "css/*" $ compile getResourceBody
        create ["kelecorix.css"] $ do
          route idRoute
          compile $ do
            items  <- loadAll "css/*"
            itemsWithName <-
             forM (items :: [Item String]) $
               \item -> do
                 ident <- return $ itemIdentifier item
                 let number = fromMaybe 0 $ T.readMaybe (takeWhile (/='-') $ drop 12 $ show ident) :: Int
                 return (number, item)

            makeItem $ concatMap itemBody $ (map snd (sortBy (comparing fst) (itemsWithName::[(Int, Item String)])))

        -- handle templates
        match "tpl/**" $ compile templateCompiler

        -- handle static files
        sequence_ $ fmap matchStatic
          [ "img/**"
          , "js/*"
          , "css/plugins/**"
          , "fonts/**"
          , "style/*.woff"
          , "style/*.png"
          , "favicon.png"
          , ".htaccess"
          ]

        forM_ langLoc $ \dir -> do

            let path = "data/" ++ dir
                ptrn = fromGlob $ path ++ "/**"

            tags <- buildTags ptrn (fromCapture "tags/*.html")

--------------------------------------------------------------------------------
-- Create technology page

            create [fromFilePath (path ++ "/technology.html")] $ do
              route idRouteCustom
              compile $ do
                let tplA = fromFilePath ("tpl/"++ dir ++ "/technology.tpl")
                    tplD = fromFilePath ("tpl/"++ dir ++ "/default.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplA defaultContext
                  >>= loadAndApplyTemplate tplD defaultContext
                  >>= relativizeUrls

--------------------------------------------------------------------------------
-- Create solutions page

            create [fromFilePath (path ++ "/solutions.html")] $ do
              route idRouteCustom
              compile $ do
                let tplA = fromFilePath ("tpl/"++ dir ++ "/solutions.tpl")
                    tplD = fromFilePath ("tpl/"++ dir ++ "/default.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplA defaultContext
                  >>= loadAndApplyTemplate tplD defaultContext
                  >>= relativizeUrls

--------------------------------------------------------------------------------
-- Create services page

            create [fromFilePath (path ++ "/services.html")] $ do
              route idRouteCustom
              compile $ do
                let tplA = fromFilePath ("tpl/"++ dir ++ "/services.tpl")
                    tplD = fromFilePath ("tpl/"++ dir ++ "/default.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplA defaultContext
                  >>= loadAndApplyTemplate tplD defaultContext
                  >>= relativizeUrls

--------------------------------------------------------------------------------
-- News

            -- Apply Pandoc compiler to news
            match (fromGlob (path ++ "/news/*.md")) $
                version "newsPage" $
                compile $ do
                  debugCompiler $ "????"
                  myPandocCompiler >>= saveSnapshot "contentN"

            -- Apply templates to converted news
            match (fromGlob (path ++ "/news/*.md")) $ do
              route   $ composeRoutes idRouteCustom (setExtension "html")
              --route   $ setExtension "html"
              compile $ do
                item <- getUnderlying
                html <- load $ setVersion (Just "newsPage") item
                let tplN = fromFilePath ("tpl/" ++ dir ++ "/news-post.tpl")
                    tplD = fromFilePath ("tpl/" ++ dir ++ "/default-news-post.tpl")
                return html { itemIdentifier = item}
                  >>= saveSnapshot "contentN"
                  >>= loadAndApplyTemplate tplN (articleContextWithTags tags)
                  >>= loadAndApplyTemplate tplD defaultCtx
                  >>= relativizeUrls

            -- Create news list
            create [fromFilePath (path ++ "/news.html")] $ do
              route idRouteCustom
              compile $ do
                notes' <- news dir
                let tplN  = fromFilePath ("tpl/" ++ dir ++ "/news.tpl")
                    tplD  = fromFilePath ("tpl/" ++ dir ++ "/default-news.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplN (constField "news" notes' <> defaultCtx)
                  >>= loadAndApplyTemplate tplD defaultCtx
                  >>= relativizeUrls

--------------------------------------------------------------------------------
-- Engineering Blog

            -- Apply Pandoc compiler to blog
            match (fromGlob (path ++ "/blog/*.md")) $
                version "postPage" $
                compile $ do
                  myPandocCompiler >>= saveSnapshot "contentN"

            -- Apply templates to converted blog
            match (fromGlob (path ++ "/blog/*.md")) $ do
              route   $ composeRoutes  idRouteCustom (setExtension "html")
              --route   $ setExtension "html"
              compile $ do
                item <- getUnderlying
                html <- load $ setVersion (Just "postPage") item
                let tplN = fromFilePath ("tpl/" ++ dir ++ "/post.tpl")
                    tplD = fromFilePath ("tpl/" ++ dir ++ "/default-news-post.tpl")
                return html { itemIdentifier = item}
                  >>= saveSnapshot "contentN"
                  >>= loadAndApplyTemplate tplN (articleContextWithTags tags)
                  >>= loadAndApplyTemplate tplD defaultCtx
                  >>= relativizeUrls

            -- Create posts list for blog
            create [fromFilePath (path ++ "/blog.html")] $ do
              route idRouteCustom
              compile $ do
                notes' <- blog dir
                let tplN  = fromFilePath ("tpl/" ++ dir ++ "/blog.tpl")
                    tplD  = fromFilePath ("tpl/" ++ dir ++ "/default-blog.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplN (constField "blog" notes' <> defaultCtx)
                  >>= loadAndApplyTemplate tplD defaultCtx
                  >>= relativizeUrls

--------------------------------------------------------------------------
--  Area
            -- Apply Pandoc compiler to blog
            match (fromGlob (path ++ "/area/*.md")) $
                version "areasPage" $
                compile $ do
                  myPandocCompiler >>= saveSnapshot "contentN"

            match (fromGlob (path ++ "/area/*.md")) $ do
              route   $ composeRoutes  idRouteCustom (setExtension "html")
              compile $ do
                item <- getUnderlying
                html <- load $ setVersion (Just "areasPage") item
                let tplN = fromFilePath ("tpl/" ++ dir ++ "/area/telecom.tpl")
                    tplD = fromFilePath ("tpl/" ++ dir ++ "/default-area.tpl")
                return html { itemIdentifier = item}
                  >>= saveSnapshot "areasPage"
                  >>= loadAndApplyTemplate tplN defaultCtx
                  >>= loadAndApplyTemplate tplD defaultCtx
                  >>= relativizeUrls


--------------------------------------------------------------------------
-- About us

            create [fromFilePath (path ++ "/about.html")] $ do
              route idRouteCustom
              compile $ do
                let tplA = fromFilePath ("tpl/" ++ dir ++ "/about.tpl")
                    tplD = fromFilePath ("tpl/" ++ dir ++ "/default-about.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplA defaultContext
                  >>= loadAndApplyTemplate tplD defaultContext
                  >>= relativizeUrls

--------------------------------------------------------------------------
-- Create index

            create [fromFilePath (path ++ "/index.html")] $ do
              route idRouteCustom
              compile $ do
                let tplM = fromFilePath ("tpl/" ++ dir ++"/index.tpl")
                    tplD = fromFilePath ("tpl/" ++ dir ++"/default-index.tpl")
                makeItem ""
                  >>= loadAndApplyTemplate tplM defaultContext
                  >>= loadAndApplyTemplate tplD defaultContext
                  >>= relativizeUrls

idRouteCustom :: Routes
idRouteCustom =
  customRoute $ \ident ->
    do
      let fs = toFilePath ident
      case length fs > 0 of
        False -> error $ "Invalid filepath: " ++ fs
        True  -> drop 5 fs -- drop 8 fs -- 7 is length of ../data/

matchStatic :: Pattern -> Rules ()
matchStatic pattern = do
  match pattern $ do
    route idRoute
    compile copyFileCompiler

--------------------------------------------------------------------------------

-- | Generate notes list to use in blog page
blog :: String -> Compiler String
blog dir = do
  posts <- loadAll (fromGlob ("data/" ++ dir ++ "/blog/*.md") .&&. hasVersion "postPage")
  tpl   <- loadBody (fromFilePath ("tpl/" ++ dir ++ "/post-item.tpl"))
  applyTemplateList tpl (articleUrlCtx <> defaultCtx) =<< recentFirst posts

-- | Generate notes list to use in blog page
news :: String -> Compiler String
news dir = do
  news' <- loadAll (fromGlob ("data/" ++ dir ++ "/news/*.md") .&&. hasVersion "newsPage")
  tpl   <- loadBody (fromFilePath ("tpl/" ++ dir ++ "/news-item.tpl"))
  debugCompiler $ "----" ++ (show news')
  applyTemplateList tpl (articleUrlCtx <> defaultCtx) =<< recentFirst news'

myPandocCompiler =
  pandocCompilerWith
    defaultHakyllReaderOptions
    defaultHakyllWriterOptions
      {
      -- writerHtml5            = True
      -- , writerHighlight        = True
      writerHighlightStyle   = Just PH.pygments
      -- , writerHTMLMathMethod   = MathML Nothing
      , writerEmailObfuscation = NoObfuscation
      }
