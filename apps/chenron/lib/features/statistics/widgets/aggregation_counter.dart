/// Seam exposing how many times a chart has recomputed its aggregation.
///
/// Chart States implement this so tests can assert the aggregation runs
/// once per distinct input list (memoization) rather than on every
/// repaint, without reaching into the private State types via `dynamic`.
/// Production code only ever implements it — the counter is read in tests.
abstract interface class AggregationCounter {
  int get aggregationCount;
}
