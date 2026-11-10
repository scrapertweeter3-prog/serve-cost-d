# serve-cost

Library docs for serve-cost, a D package that puts flat AI serving quotes
into one exact unit: integer microdollars. An invoice priced per GPU-hour
and an invoice priced per million tokens never compare directly, and the
eyeball conversion is where serving budgets leak. The audit approach behind
the [PastAGI serving-cost writeups](https://www.pastagi.com) treats the
unit conversion as something you show before the demo; this library does
it in integers so the comparison survives an invoice review.

## One quote, two units

`ConversionParams` carries a quote the way an invoice states it: the rate
for one invoice block, the units delivered per serving second, the block
size, and the serving window. A $3.00/Mtok quote at 2,000 tokens/second
over a one-hour window is `ConversionParams(3.00, 2000.0, 1_000_000, 3600)`.
`perUnitCost` folds that into:

```
per-Mtok quote : $3.00/Mtok @ 2000 tok/s -> 21600000 microdollars
```

$21.60 for the serving hour. The GPU-hour lane on the same window,
`ConversionParams(6.00, 1.0 / 3600.0, 1, 3600)`, lands at exactly
6000000 microdollars. The two totals are in the same unit now, and the
$15.60 gap between them is the number an invoice review actually needs.

## What the integers buy

`CostAudit.microdollars` is the exact total; `dollars` is the display
value rounded from it. The audit records the units the invoice quoted
(`fromUnit`) and the per-second basis it produced (`toUnit`), so a
reviewer can trace any total back to its quote. When a quote cannot land
on whole microdollars, the residue is flagged through `crossedBoundary`
instead of vanishing into rounding: the total says it is approximate
rather than silently absorbing the fraction.

## Where the break-even sits

The per-second arithmetic makes cross-quote comparisons mechanical. At
2,000 tokens/second the $3/Mtok quote prices a serving second at 6,000
microdollars; the $6.00 GPU-hour quote prices the same second at about
1,667. The two lanes meet where the token rate works out to roughly 556
tokens/second, so a workload sustaining above that rate pays more under
the per-token quote, and one below it pays more under the flat hourly
rate. That threshold is unit arithmetic, not a benchmark, and it moves
with the quote, which is the point of doing the conversion exactly.

## Reproduce the numbers

```
ldc2 demo/main.d source/servingcost.d -of=demo_bin && ./demo_bin
```

prints the invoice line, both totals, the gap, and the boundary flag.
Every figure on this page comes from that run against the library source
as committed. `dub build` compiles the library clean.

## Where the audit angle lives

The longer invoice-side serving writeups sit on
[PastAGI](https://www.pastagi.com).
