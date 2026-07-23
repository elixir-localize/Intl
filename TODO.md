# TODO

Remaining conformance gaps against the JS Intl API, tracked in the [compatibility guide](https://hexdocs.pm/intl/compatibility.html). Split by whether the work is blocked on Localize.

## Blocked on Localize

* `formatToParts` beyond NumberFormat — needs Localize parts support for dates/times, lists, and units (`Localize.Number.to_parts/2` landed in 1.0.0-rc.1; siblings pending).

* `formatRangeToParts` — needs `Localize.Number.to_range_parts/3` (listed as a post-1.0 candidate in Localize's TODO).

* `format_to_parts/2` with `currency_display: :name` — needs parts support for the Localize `:currency_long` composed formats.

* `Intl.DateTimeFormat` `fractionalSecondDigits` — needs fractional-second (`S`) support in Localize skeleton matching; the Intl skeleton builder is ready.

* `Intl.DurationFormat` per-unit style options (`hoursDisplay`, …) — needs per-unit control in `Localize.Duration.to_string/2`.

* `Intl.Segmenter` `isWordLike` — needs word-classification metadata from the segmentation engine.

## Intl-side (no upstream work required)

* `resolvedOptions` — could be built on `Localize.Number.Format.Options.validate_options/2` for NumberFormat; other modules need equivalent resolution. Deferred as introspection-only API.

* `localeMatcher` — deliberately not supported; Localize's own locale resolution applies.

## Completed

### 1.0.0-rc.0 (July 23, 2026)

Closed with Localize 1.0.0-rc.1: `minimum_integer_digits`, `trailing_zero_display`, `rounding_priority`, `format_to_parts/2` for numbers, `RelativeTimeFormat numeric: :always`, `supported_values_of` `:collation`/`:time_zone`, `supported_locales_of/1`, `PluralRules.select_range/3`, `Collator :usage`/`:collation`, and the DateTimeFormat `:era`/`:day_period`/`:time_zone_name`/`:hour12`/`:hour_cycle` components (plus the component-skeleton bug fix).

### Script Display Names

Resolved: `Localize.Script.display_name/2` is now available and `Intl.DisplayNames` supports `type: :script`.
