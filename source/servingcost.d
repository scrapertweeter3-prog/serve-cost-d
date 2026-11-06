/++ Serving-cost math for flat-rate AI serving: integer-microdollar
 + arithmetic with automatic unit conversion and error capture.
 +
 + Built for audit work: an invoice that quotes $6/hour is measured in
 + different units than one that quotes $3/Mtok. This module keeps
 + everything in integer microdollars so billing comparisons stay exact
 + and auditable, then converts between usage units automatically.
 +/
module servingcost;

/// Results of one conversion audit.
struct CostAudit {
    ulong microdollars;   /// exact integer microdollar cost
    double dollars;       /// convenience readout (rounded display value)
    string fromUnit;      /// unit the invoice quoted
    string toUnit;        /// unit the audit reports
    bool crossedBoundary; /// conversion crossed an invoice-unit boundary
}

/// Parameters for one conversion.
struct ConversionParams {
    double ratePerUnit;    /// quoted rate, in dollars per invoice block
    double unitsPerSecond; /// quoted units delivered per serving second (e.g. tokens)
    ulong  divisor;        /// quoted units per invoice block (e.g. 1_000_000 for Mtok)
    ulong  seconds;        /// serving seconds to audit
}

/**
 * Convert a $/unit quote into an exact integer microdollar total.
 *
 * ratePerUnit prices ONE invoice block (divisor units). A $3/Mtok quote
 * is ratePerUnit=3.00 with divisor=1_000_000. The capture is exact:
 * any residue that integer math cannot express is reported through
 * crossedBoundary instead of vanishing.
 */
CostAudit perUnitCost(ConversionParams p) @safe pure {
    import std.math.rounding : round;
    double perSecond = (p.ratePerUnit / p.divisor) * p.unitsPerSecond;
    double total = perSecond * p.seconds;
    ulong micro = cast(ulong) round(total * 1_000_000.0);
    double recomposed = cast(double) micro / 1_000_000.0;
    bool residue = (total - recomposed) != 0.0;
    return CostAudit(micro, cast(double) micro / 1e6,
                     "$/block", "per-second", residue);
}
