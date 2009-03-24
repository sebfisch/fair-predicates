-- |
-- Module      : Data.Answer
-- Copyright   : Sebastian Fischer
-- License     : PublicDomain
-- 
-- Maintainer  : Sebastian Fischer (sebf@informatik.uni-kiel.de)
-- Stability   : experimental
-- Portability : portable
-- 
-- This Haskell library provides an implementation of Boolean
-- predicates with an interleaved evaluation of arguments.
-- 
module Data.Answer ( 

  Answer, fromAnswer, true, false, neg, (/\), (\/)

 ) where

infixr 3 /\
infixr 2 \/

-- | @Answer@s are like @Bool@s but can be evaluated incrementally.
-- 
data Answer = Yes | No | Undecided Answer

-- | Evaluates an answer.
-- 
fromAnswer :: Answer -> Bool
fromAnswer Yes           = True
fromAnswer No            = False
fromAnswer (Undecided a) = fromAnswer a

-- | The positive answer.
-- 
true :: Answer
true = Yes

-- | The negative answer.
-- 
false :: Answer
false = No

-- | Negates an answer.
-- 
neg :: Answer -> Answer
neg a = Undecided (negative a)

negative :: Answer -> Answer
negative Yes           = No
negative No            = Yes
negative (Undecided a) = neg a

-- | Conjunction of answers.
-- 
(/\) :: Answer -> Answer -> Answer
a /\ b = Undecided (conjunction a b)

conjunction :: Answer -> Answer -> Answer
conjunction Yes           a             = a
conjunction No            _             = No
conjunction a             Yes           = a
conjunction _             No            = No
conjunction (Undecided a) (Undecided b) = a /\ b

-- | Disjunction of answers.
-- 
(\/) :: Answer -> Answer -> Answer
a \/ b = Undecided (disjunction a b)

disjunction :: Answer -> Answer -> Answer
disjunction Yes           _             = Yes
disjunction No            a             = a
disjunction _             Yes           = Yes
disjunction a             No            = a
disjunction (Undecided a) (Undecided b) = a \/ b

