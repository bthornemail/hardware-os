{-# LANGUAGE DeriveAnyClass #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}

-- | Desktop.CanvasEDSL
-- JSON Canvas Spec 1.0 (https://jsoncanvas.org/spec/1.0/)
-- Covariant axis  : Top/Bottom  (FIFO)
-- Contravariant   : Left/Right  (PORT)
--
-- Nodes can represent messages/packets; edges represent flow with arrow semantics.
module Desktop.CanvasEDSL
  ( -- * Canvas
    Canvas(..)
  , Node(..)
  , Edge(..)
  , NodeType(..)
  , Side(..)
  , EndShape(..)

    -- * IDs
  , NodeId(..)
  , EdgeId(..)

    -- * EDSL builders
  , canvas
  , textNode
  , fileNode
  , linkNode
  , groupNode
  , packetNode

    -- * Covariant/Contravariant link combinators
  , fifoTop
  , fifoBottom
  , portLeft
  , portRight
  , flow

    -- * Streaming (NDJSON)
  , CanvasEvent(..)
  , encodeNDJSON
  ) where

import GHC.Generics (Generic)
import Data.Aeson (ToJSON(..), FromJSON(..), (.=), object)
import qualified Data.Aeson as A
import qualified Data.ByteString.Lazy.Char8 as BL
import Data.Text (Text)

-- ----------------------------
-- IDs
-- ----------------------------

newtype NodeId = NodeId { unNodeId :: Text }
  deriving (Eq, Ord, Show, Generic, ToJSON, FromJSON)

newtype EdgeId = EdgeId { unEdgeId :: Text }
  deriving (Eq, Ord, Show, Generic, ToJSON, FromJSON)

-- ----------------------------
-- JSON Canvas: Canvas
-- ----------------------------

data Canvas = Canvas
  { nodes :: [Node]
  , edges :: [Edge]
  } deriving (Eq, Show, Generic)

instance ToJSON Canvas where
  toJSON Canvas{..} = object
    [ "nodes" .= nodes
    , "edges" .= edges
    ]

-- ----------------------------
-- JSON Canvas: Nodes
-- ----------------------------

data NodeType = NText | NFile | NLink | NGroup
  deriving (Eq, Show, Generic)

instance ToJSON NodeType where
  toJSON = \case
    NText  -> A.String "text"
    NFile  -> A.String "file"
    NLink  -> A.String "link"
    NGroup -> A.String "group"

data Node = Node
  { nodeId   :: NodeId
  , nodeType :: NodeType
  , x        :: Int
  , y        :: Int
  , width    :: Int
  , height   :: Int
  , color    :: Maybe Text       -- canvasColor per spec (hex or preset "1".."6")
  -- type-specific payload (only one should be set for correctness)
  , text     :: Maybe Text
  , file     :: Maybe Text
  , subpath  :: Maybe Text
  , url      :: Maybe Text
  , label    :: Maybe Text
  , background :: Maybe Text
  , backgroundStyle :: Maybe Text -- cover|ratio|repeat
  } deriving (Eq, Show, Generic)

instance ToJSON Node where
  toJSON Node{..} =
    object $
      [ "id"     .= nodeId
      , "type"   .= nodeType
      , "x"      .= x
      , "y"      .= y
      , "width"  .= width
      , "height" .= height
      ]
      ++ opt "color" color
      ++ opt "text" text
      ++ opt "file" file
      ++ opt "subpath" subpath
      ++ opt "url" url
      ++ opt "label" label
      ++ opt "background" background
      ++ opt "backgroundStyle" backgroundStyle
    where
      opt k = maybe [] (\v -> [k .= v])

-- ----------------------------
-- JSON Canvas: Edges
-- ----------------------------

data Side = Top | Right | Bottom | Left
  deriving (Eq, Show, Generic)

instance ToJSON Side where
  toJSON = \case
    Top    -> A.String "top"
    Right  -> A.String "right"
    Bottom -> A.String "bottom"
    Left   -> A.String "left"

data EndShape = EndNone | EndArrow
  deriving (Eq, Show, Generic)

instance ToJSON EndShape where
  toJSON = \case
    EndNone  -> A.String "none"
    EndArrow -> A.String "arrow"

data Edge = Edge
  { edgeId    :: EdgeId
  , fromNode  :: NodeId
  , fromSide  :: Maybe Side
  , fromEnd   :: Maybe EndShape
  , toNode    :: NodeId
  , toSide    :: Maybe Side
  , toEnd     :: Maybe EndShape
  , edgeColor :: Maybe Text       -- canvasColor per spec
  , edgeLabel :: Maybe Text
  } deriving (Eq, Show, Generic)

instance ToJSON Edge where
  toJSON Edge{..} =
    object $
      [ "id"       .= edgeId
      , "fromNode" .= fromNode
      , "toNode"   .= toNode
      ]
      ++ opt "fromSide" fromSide
      ++ opt "fromEnd" fromEnd
      ++ opt "toSide" toSide
      ++ opt "toEnd" toEnd
      ++ opt "color" edgeColor
      ++ opt "label" edgeLabel
    where
      opt k = maybe [] (\v -> [k .= v])

-- ----------------------------
-- EDSL: canvas + nodes
-- ----------------------------

canvas :: [Node] -> [Edge] -> Canvas
canvas ns es = Canvas { nodes = ns, edges = es }

textNode :: NodeId -> (Int,Int) -> (Int,Int) -> Text -> Node
textNode nid (px,py) (w,h) t = Node
  { nodeId = nid, nodeType = NText
  , x = px, y = py, width = w, height = h
  , color = Nothing
  , text = Just t
  , file = Nothing
  , subpath = Nothing
  , url = Nothing
  , label = Nothing
  , background = Nothing
  , backgroundStyle = Nothing
  }

fileNode :: NodeId -> (Int,Int) -> (Int,Int) -> Text -> Node
fileNode nid (px,py) (w,h) f = Node
  { nodeId = nid, nodeType = NFile
  , x = px, y = py, width = w, height = h
  , color = Nothing
  , text = Nothing
  , file = Just f
  , subpath = Nothing
  , url = Nothing
  , label = Nothing
  , background = Nothing
  , backgroundStyle = Nothing
  }

linkNode :: NodeId -> (Int,Int) -> (Int,Int) -> Text -> Text -> Node
linkNode nid (px,py) (w,h) u lab = Node
  { nodeId = nid, nodeType = NLink
  , x = px, y = py, width = w, height = h
  , color = Nothing
  , text = Nothing
  , file = Nothing
  , subpath = Nothing
  , url = Just u
  , label = Just lab
  , background = Nothing
  , backgroundStyle = Nothing
  }

groupNode :: NodeId -> (Int,Int) -> (Int,Int) -> Text -> Node
groupNode nid (px,py) (w,h) lab = Node
  { nodeId = nid, nodeType = NGroup
  , x = px, y = py, width = w, height = h
  , color = Nothing
  , text = Nothing
  , file = Nothing
  , subpath = Nothing
  , url = Nothing
  , label = Just lab
  , background = Nothing
  , backgroundStyle = Nothing
  }

-- | Packet node for messages.
packetNode :: NodeId -> (Int,Int) -> (Int,Int) -> Text -> Text -> Node
packetNode nid (px,py) (w,h) pktType payload =
  textNode nid (px,py) (w,h) (pktType <> "\n\n" <> payload)

-- ----------------------------
-- EDSL: edges
-- ----------------------------

flow :: EdgeId -> NodeId -> Side -> NodeId -> Side -> Maybe Text -> Edge
flow eid a aSide b bSide mLab = Edge
  { edgeId = eid
  , fromNode = a
  , fromSide = Just aSide
  , fromEnd  = Just EndNone
  , toNode   = b
  , toSide   = Just bSide
  , toEnd    = Just EndArrow
  , edgeColor = Nothing
  , edgeLabel = mLab
  }

-- | Covariant FIFO axis: Top/Bottom.
-- Use these when the edge represents FIFO flow / stream continuity.
fifoTop :: EdgeId -> NodeId -> NodeId -> Maybe Text -> Edge
fifoTop eid from to mLab = flow eid from Top to Bottom mLab

fifoBottom :: EdgeId -> NodeId -> NodeId -> Maybe Text -> Edge
fifoBottom eid from to mLab = flow eid from Bottom to Top mLab

-- | Contravariant PORT axis: Left/Right.
-- Use these when the edge represents "port wiring" / selection / addressing.
portLeft :: EdgeId -> NodeId -> NodeId -> Maybe Text -> Edge
portLeft eid from to mLab = flow eid from Left to Right mLab

portRight :: EdgeId -> NodeId -> NodeId -> Maybe Text -> Edge
portRight eid from to mLab = flow eid from Right to Left mLab

-- ----------------------------
-- NDJSON streaming (events)
-- ----------------------------

-- | NDJSON event stream for incremental updates / packets.
-- Each line is one JSON object (NDJSON).
data CanvasEvent
  = EvAddNode Node
  | EvAddEdge Edge
  | EvSnapshot Canvas
  deriving (Eq, Show, Generic)

instance ToJSON CanvasEvent where
  toJSON = \case
    EvAddNode n -> object
      [ "schema" .= ("ulp.canvas.event.v0.1" :: Text)
      , "op"     .= ("addNode" :: Text)
      , "node"   .= n
      ]
    EvAddEdge e -> object
      [ "schema" .= ("ulp.canvas.event.v0.1" :: Text)
      , "op"     .= ("addEdge" :: Text)
      , "edge"   .= e
      ]
    EvSnapshot c -> object
      [ "schema" .= ("ulp.canvas.event.v0.1" :: Text)
      , "op"     .= ("snapshot" :: Text)
      , "canvas" .= c
      ]

-- | Encode events as NDJSON (one JSON object per line).
encodeNDJSON :: [CanvasEvent] -> BL.ByteString
encodeNDJSON evs =
  BL.unlines (map A.encode evs)
