# Slippage Decomposition

## Specification
An order's execution slippage is defined as:

$$
slippage_{bps} = orderSign \times \frac{Price_{benchmark}-Price_{execution}}{Price_{benchmark}} \times 10000
$$

where
$$orderSign = $$

## Implementation

### API

```q
decomposeSlippage[executions;trades;profile;params]
```
+ ``executions``: a table of order executions with the following columns:

    - ``time``: the time when each execution is transacted
    - ``quantity``: the executed shares of each execution
    - ``price``: the price of each execution
    - ``flag``: a symbol with value `` `open``, `` `continuous`` or `` `close``

+ ``trades``: a table of market trades with the following columns:

    - ``time``: the time when each market print is transacted
    - ``volume``: the executed shares of each market print
    - ``price``: the price of each market print
    - ``flag``: a symbol with value `` `open``, `` `continuous`` or `` `close``

+ ``profile``: a table of minute bar volume profile with the following columns:

    - ``time``: the start time of minute bar
    - ``percent``: the volume percent for a given minute
    - ``flag``: a symbol with value `` `open``, `` `continuous`` or `` `close``

    The volume profile must be a *full-day* volume profile with volume percent for both open and close auction. The ``time`` for open auction is the start time of continuous trading session and the ``time`` for close auction is the end time of continuous trading session.

+ ``params``: a dictionary of parameters with the following keys:

    - ``startTime``: the order start time
    - ``endTime``: the order end time
    - ``includeOpen``: a boolean indicating whether participation in open is enabled
    - ``includeClose``: a boolean indicating whether participation in close is enabled

### Details