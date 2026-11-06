import servingcost;
import std.stdio;

void main() {
    // Same serving hour, billed two ways: a $6.00 GPU-hour quote versus
    // a $3.00 per-million-token quote at 2,000 tokens/second.
    auto hourly = ConversionParams(6.00, 1.0 / 3600.0, 1, 3600);
    auto a1 = perUnitCost(hourly);
    writefln("GPU-hour quote : $6.00/hr -> %s microdollars", a1.microdollars);

    auto perMtok = ConversionParams(3.00, 2000.0, 1_000_000, 3600);
    auto a2 = perUnitCost(perMtok);
    writefln("per-Mtok quote : $3.00/Mtok @ 2000 tok/s -> %s microdollars", a2.microdollars);
    writefln("gap            : $%.2f per serving hour", a2.dollars - a1.dollars);
    writefln("boundary crossed: %s", a2.crossedBoundary);
}
