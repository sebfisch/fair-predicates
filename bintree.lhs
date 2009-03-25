% Fair Predicates

This Haskell library provides an implementation of Boolean predicates
with interleaved evaluation. Conjunction and disjunction are not
biased to one of their arguments but evaluate both step-wise
interleaved.

Installation
============

Use [cabal-install] to download and install this library as follows:

~~~
    $ cabal update
    $ cabal install fair-predicates
~~~

Usage
=====

To use this library, import it:

> import Data.Answer

It provides primitive answers `true` and `false` as well as
combinators `neg` for negation, `/\` for conjunction, and `\/` for
disjunction. The binary combinators are fair in the sense that they
perform evaluation steps of other answer combinators interleaved. No
real parallelism is implemented and there is still a slight bias
towards the left argument: `false /\ undefined` is `false` but
`undefined /\ false` is `undefined`.

Sorted binary trees
-------------------

We can use interleaved conjunction to detect that binary trees are not
sorted even if they are infinite (independent of which parts of the
tree are infinite). Here is a type for binary trees containing
numbers.

> data Tree = Tip | Fork Tree Int Tree

An interleaving predicate that checks whether a tree is sorted can be
defined almost as if its result would be a `Bool`.

> isSorted :: Tree -> Answer
> isSorted Tip          = true
> isSorted (Fork l n r) = allEntries (<n) l
>                      /\ allEntries (>n) r
>                      /\ isSorted l
>                      /\ isSorted r

The auxiliary function `allEntries` checks a (boolean) predicate `p`
for all entries of a tree.

> allEntries :: (Int -> Bool) -> Tree -> Answer
> allEntries _ Tip          = true
> allEntries p (Fork l n r) = answer (p n) /\ allEntries p l /\ allEntries p r

It uses the combinator `answer` to convert a boolean into an answer.

We can define simple infinite sorted trees by generating increasing
right or decreasing left branches.

> increasing :: Int -> Tree
> increasing n = Fork Tip n (increasing (n+1))
>
> decreasing :: Int -> Tree
> decreasing n = Fork (decreasing (n-1)) n Tip

The following tests both answer `false`:

> testInfiniteLeft :: Answer
> testInfiniteLeft = isSorted (Fork (decreasing (-1)) 0 (Fork Tip (-1) Tip))
>
> testInfiniteRight :: Answer
> testInfiniteRight = isSorted (Fork (Fork Tip 1 Tip) 0 (increasing 1))

An implementation using plain `Bool`s would be either right- or
left-biased and, thus, diverge on at least one of these examples. With
`Data.Answer` both tests yield `false`.

> main = do putStrLn "The following tests should answer 'false':"
>           putStrLn $ "infinite left subtree: " ++ show testInfiniteLeft
>           putStrLn $ "infinite right subtree: " ++ show testInfiniteRight

Having doubts? Pass [bintree.lhs] to `runhaskell`!

Complete API documentation is available from [Hackage].

Implementation
==============

Implementing fair predicates is simple. Define an `Answer` type with
an additional constructor for undecided answers,

~~~ { .Haskell }
data Answer = Yes | No | Undecided Answer
~~~

yield an undecided result from every combinator that constructs
answers,

~~~ { .Haskell }
a /\ b = Undecided (conjunction a b)
~~~

and match both arguments in binary combinators.

~~~ { .Haskell }
conjunction Yes           a             = a
conjunction No            _             = No
conjunction a             Yes           = a
conjunction _             No            = No
conjunction (Undecided a) (Undecided b) = a /\ b
~~~

The complete implementation is available on [Github].

The implementation idea can be generalized to search for solutions of
an arbitrary type. Oleg Kiselyov has implemented a [non-determinism
monad][stream-monad] with a similar interleaving for the `mplus`
operation.

Contact
=======

For feedback or bug reports contact [Sebastian
Fischer](sebf@informatik.uni-kiel.de).


[cabal-install]: http://hackage.haskell.org/trac/hackage/wiki/CabalInstall
[Hackage]: http://hackage.haskell.org/cgi-bin/hackage-scripts/package/fair-predicates
[bintree.lhs]: bintree.lhs
[Github]: http://github.com/sebfisch/fair-predicates
[stream-monad]: http://hackage.haskell.org/cgi-bin/hackage-scripts/package/stream-monad

