# Slippage Decomposition

## Specification
An order's execution slippage is defined as:

$$
slippage_{bps} = sideSign \times \frac{MarketAvgPrice-OrderAvgPrice}{MarketAvgPrice} \times 10000
$$

where

$$
sideSign = 
\begin{cases} 1, & \text{for buy order}, \\
              -1, & \text{otherwise}
\end{cases}
$$

Let's split the whole order duration into $N$ equal time periods and introduce the following notations:

- $P_{m,i}$: the market average price in period $i$
- $V_{m,i}$: the market volume traded in period $i$
- $P_{o,i}$: the order average execution price in period $i$
- $V_{o,i}$: the order quantity executed in period $i$

With above notation, we have

$$
MarketAvgPrice = \frac{\sum_{i=1}^{N} P_{m,i} \cdot V_{m,i}}{\sum_{i=1}^{N} V_{m,i}} = \sum_{i=1}^{N} P_{m,i} \cdot \frac{V_{m,i}}{\sum_{i=1}^{N} V_{m,i}} = \sum_{i=1}^{N} P_{m,i} \cdot \rho_{m,i}
$$

where $\rho_{m,i} = \frac{V_{m,i}}{\sum_{i=1}^{N} V_{m,i}}$, *i.e.* the proportion of market volume traded in period $i$. By the same token, we have

$$
OrderAvgPrice = \frac{\sum_{i=1}^{N} P_{o,i} \cdot V_{o,i}}{\sum_{i=1}^{N} V_{o,i}} = \sum_{i=1}^{N} P_{o,i} \cdot \frac{V_{o,i}}{\sum_{i=1}^{N} V_{o,i}} = \sum_{i=1}^{N} P_{o,i} \cdot \rho_{o,i}
$$

where $\rho_{o,i} = \frac{V_{o,i}}{\sum_{i=1}^{N} V_{o,i}}$, *i.e.* the proportion of order quantity traded in period $i$.

Let's introduce one more notation for the predicted volume profile $\hat{\rho}_{o,i}$. So we can rewrite the numerator of the slippage definition as:

$$
\sum_{i=1}^{N} P_{m,i} \cdot \rho_{m,i} - \sum_{i=1}^{N} P_{o,i} \cdot \rho_{o,i} = \sum_{i=1}^{N} (P_{m,i} - P_{o,i}) \cdot \rho_{m,i} + \sum_{i=1}^{N} P_{o,i} \cdot (\rho_{m,i} - \hat{\rho}_{o,i}) + \sum_{i=1}^{N} P_{o,i} \cdot (\hat{\rho}_{o,i} - \rho_{o,i})
$$

In this way, the performance slippage is decomposed into three components:

- $\sum_{i=1}^{N} (P_{m,i} - P_{o,i}) \cdot \rho_{m,i}$ is the price component, which indicates how much an order's execution price deviates from market price, *i.e.* how much spread is captured by the order.
- $\sum_{i=1}^{N} P_{o,i} \cdot (\rho_{m,i} - \hat{\rho}_{o,i})$ is the tolerance component, which indicates the cost paid due to how closely the order follows the target volume profile.
- $\sum_{i=1}^{N} P_{o,i} \cdot (\hat{\rho}_{o,i} - \rho_{o,i})$ is the profile component, which indicates the slippage due to difference between the estimated volume profile and realized volume profile from the market.

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