{-# language MultiParamTypeClasses #-}

module Satchmo.Polynomial.Numeric where

import qualified Satchmo.Boolean as B
import Satchmo.Code
import Satchmo.Numeric

import Control.Monad ( forM )

data Poly a = Poly [a]

instance Decode a b => Decode ( Poly a ) ( Poly b ) where
    decode ( Poly xs ) = do
        ys <- forM xs decode
        return $ Poly ys

instance ( Create a, Constant a, Numeric a )
         => Numeric ( Poly a ) where
    equal ( Poly xs ) ( Poly ys ) = do
        z <- create 0
        bs <- forM ( fullZip xs ys ) $ \ xy -> case xy of
            ( Just x, Just y ) -> equal x y
            ( Just x, Nothing ) -> equal x z
            ( Nothing, Just y ) -> equal z y
        B.and bs
    greater_equal  ( Poly xs ) ( Poly ys ) = do
        z <- create 0
        bs <- forM ( fullZip xs ys ) $ \ xy -> case xy of
            ( Just x, Just y ) -> greater_equal x y
            ( Just x, Nothing ) -> greater_equal x z
            ( Nothing, Just y ) -> greater_equal z y
        B.and bs
    plus  ( Poly xs ) ( Poly ys ) = do
        bs <- forM ( fullZip xs ys ) $ \ xy -> case xy of
            ( Just x, Just y ) -> plus x y
            ( Just x, Nothing ) -> return x
            ( Nothing, Just y ) -> return y
        return $ Poly bs
    minus ( Poly xs ) ( Poly ys ) = do
        z <- create 0
        bs <- forM ( fullZip xs ys ) $ \ xy -> case xy of
            ( Just x, Just y ) -> minus x y
            ( Just x, Nothing ) -> return x
            ( Nothing, Just y ) -> minus z y
        return $ Poly bs
    times ( Poly xs ) ( Poly ys ) = case xs of
        [] -> return $ Poly []
        x : xs -> do
            xys <- forM ys $ times x
            z <- constant 0
            Poly rest <- times (Poly xs) (Poly ys)
            plus ( Poly xys ) ( Poly $ z : rest )

fullZip :: [a] -> [b] -> [ (Maybe a, Maybe b) ]    
fullZip [] [] = []
fullZip [] (y:ys) = (Nothing, Just y) : fullZip [] ys
fullZip (x:xs) [] = (Just x, Nothing) : fullZip xs []
fullZip (x:xs) (y:ys) = (Just x, Just y) : fullZip xs ys


