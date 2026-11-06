# serve-cost

Serving-cost arithmetic in integer microdollars. Convert flat AI
serving quotes to exact totals and compare invoices that are quoted
in different units.

## Why

An invoice that quotes $6.00 per GPU-hour and one that quotes $3.00
per million tokens are not directly comparable, and eyeballing the
conversion is where serving budgets leak. The audit approach used on
[PastAGI](https://www.pastagi.com) treats serving math as something
you show before the demo; this library does the conversion in integer
microdollars so the comparison stays exact.

## Example

```
GPU-hour quote : $6.00/hr -> 6000000 microdollars
per-Mtok quote : $3.00/Mtok @ 2000 tok/s -> 21600000 microdollars
gap            : $15.60 per serving hour
boundary crossed: false
```

Same serving hour: 7.2 million tokens at $3/Mtok is $21.60, the
GPU-hour lane is $6.00, and the $15.60 gap only becomes visible once
the unit conversion is done exactly.

## Usage

```d
import servingcost;

auto perMtok = ConversionParams(3.00, 2000.0, 1_000_000, 3600);
auto audit = perUnitCost(perMtok);
assert(audit.microdollars == 21_600_000);
```

## License

MIT
