# Kdb Notes

## Operator (|)
The (|) operator can be used to reverse the ordering of the list. In such a case, a single argument is provided:

```q
q) (|) 0 1 2 3 4 5 6 7 8 9
9 8 7 6 5 4 3 2 1 0
```

The operator works on any type; in particular, it can be used to reverse the letters in a word:

```q
q) (|) "hello"
"olleh"
```

## where
More generally, [where][where] applied to a vector of integers (or a dictionary with integer values) can be defined as a function returning the number of occurrences of those integers according to the integer values:

```q
q) where `a`b`c`d!til 4
`b`c`c`d`d`d
```

## enumeration
- [Enum Basics](https://code.kx.com/q/basics/enumerations/)
- [Enum Extend](https://code.kx.com/q/ref/enum-extend/)
- [Enum Resolve](https://code.kx.com/q/ref/enumeration/)
- [Enum in *Q for Mortals*](https://code.kx.com/q4m3/7_Transforming_Data/#75-enumerations)

## peach


[where]: https://code.kx.com/q/ref/where/
