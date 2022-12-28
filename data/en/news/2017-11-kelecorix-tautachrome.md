---
seria:
title: Embracing new opportunities
date: 2016-01-12
tags: haskell, ghc, aeson, json
author: Sergey Bushnyak
---
`Aeson` is a nice package to work with json, but sometimes it's tedious to write all instances for deriving from/to json with your datatapes. Especially when prototyping quickly.

Fortunately, we can use power of GHC generics and `DeriveAnyClass` language extension, which was introduced in latest release [7.10](https://downloads.haskell.org/~ghc/7.10.1/docs/html/users_guide/release-7-10-1.html), to reduce amount of work. We need to use several extensions [DeriveGeneric]() and [DeriveAnyClass]() which will lead to folowing code:
```haskell
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DeriveAnyClass #-}

module JsonGenerExample where 

import           Data.Aeson
import           GHC.Generics

data User =
  User { login :: String
       , pass  :: String
       } deriving (Generic, FromJSON, ToJSON)
     
data ConnectConfig =
  ConnectConfig
    { host     :: String
    , port     :: Integer
    , db       :: String
    , user     :: User
    , password :: String
    } deriving (Generic, FromJSON, ToJSON)
```
, where at top we connect GHC language extensions, import `Generics` and just add to our datatypes `deriving (Generic, FromJSON, ToJSON)`. That's it, quick and easy.

Earlier you could do almost the same thing just with `DeriveGeneric`, but you still needed to write simple instance.

```haskell
data ConnectConfig =
  ConnectConfig
    { host     :: String
    , port     :: Integer
    , db       :: String
    , user     :: User
    , password :: String
    } deriving (Generic)

instance FromJSON ConnectConfig
instance ToJSON   ConnectConfig
```

and before that, you need to write full `instance`

```haskell
instance ParseJSON ConnectConfig where
  parseJSON = withObject "connectConfig" $ \o ->
    do
      host  <- o .: "host"
      port  <- o .: "port"
      db    <- o .: "db"
      user  <- o .: "user"
      pass  <- o .: "password"
    return (ConnectConfig host port db user pass) 
```

