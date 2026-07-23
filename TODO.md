# TODO

Remaining conformance gaps against the JS Intl API, tracked in the [compatibility guide](https://hexdocs.pm/intl/compatibility.html). Split by whether the work is blocked on Localize.

## Blocked on Localize

* `Intl.DateTimeFormat.formatRangeToParts` — needs parts support in `Localize.Interval` formatting.

* `Intl.NumberFormat.format_range_to_parts/3` with `style: :unit` — needs `Localize.Unit.to_range_parts/3`.

* `Intl.DurationFormat` `formatToParts` — needs a parts variant of `Localize.Duration.to_string/2` (unit parts joined with list parts already exist upstream, so this is composition work).

* `Intl.Segmenter` `isWordLike` — needs word-classification metadata from the segmentation engine (the `unicode_string` package, not Localize).

## Intl-side (no upstream work required)

* `resolvedOptions` — could be built on `Localize.Number.Format.Options.validate_options/2` for NumberFormat; other modules need equivalent resolution. Deferred as introspection-only API.

* `localeMatcher` — deliberately not supported; Localize's own locale resolution applies.

## Completed

### 1.0.0-rc.0 second pass (July 23, 2026)

Closed with Localize 1.0.0-rc.2: `format_to_parts` for DateTimeFormat, ListFormat, and RelativeTimeFormat; NumberFormat `format_range_to_parts/3`, unit parts, unit ranges, and `currency_display: :name` parts; DateTimeFormat `fractional_second_digits`; DurationFormat per-unit style and display options; `PluralRules.select_range/3` now delegates to `Localize.Number.PluralRule.Range`.

### 1.0.0-rc.0 first pass (July 23, 2026)

Closed with Localize 1.0.0-rc.1: `minimum_integer_digits`, `trailing_zero_display`, `rounding_priority`, `format_to_parts/2` for numbers, `RelativeTimeFormat numeric: :always`, `supported_values_of` `:collation`/`:time_zone`, `supported_locales_of/1`, `PluralRules.select_range/3`, `Collator :usage`/`:collation`, and the DateTimeFormat `:era`/`:day_period`/`:time_zone_name`/`:hour12`/`:hour_cycle` components (plus the component-skeleton bug fix).

### Script Display Names

Resolved: `Localize.Script.display_name/2` is now available and `Intl.DisplayNames` supports `type: :script`.
