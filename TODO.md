# TODO

Remaining conformance gaps against the JS Intl API, tracked in the [compatibility guide](https://hexdocs.pm/intl/compatibility.html). Split by whether the work is blocked on Localize.

## Blocked upstream

Nothing — every upstream-blocked conformance gap is closed.

## Intl-side (no upstream work required)

* `resolvedOptions` — could be built on `Localize.Number.Format.Options.validate_options/2` for NumberFormat; other modules need equivalent resolution. Deferred as introspection-only API.

* `localeMatcher` — deliberately not supported; Localize's own locale resolution applies.

## Completed

### 1.0.0-rc.0 fourth pass (July 23, 2026)

Closed with `unicode_string` 2.3.0: `Intl.Segmenter.segment_with_metadata/2` provides the JS segment-object shape with `:word_like?` (`isWordLike`) via the new `Unicode.String.word_like?/1`.

### 1.0.0-rc.0 third pass (July 23, 2026)

Closed with post-rc.2 Localize work: `DateTimeFormat.format_range_to_parts/3` (interval parts), `NumberFormat.format_range_to_parts/3` for `style: :unit`, `DurationFormat.format_to_parts/2`, and the `:numbering_system` option for date/time formatting. Every JS `formatToParts`/`formatRangeToParts` surface is now implemented.

### 1.0.0-rc.0 second pass (July 23, 2026)

Closed with Localize 1.0.0-rc.2: `format_to_parts` for DateTimeFormat, ListFormat, and RelativeTimeFormat; NumberFormat `format_range_to_parts/3`, unit parts, unit ranges, and `currency_display: :name` parts; DateTimeFormat `fractional_second_digits`; DurationFormat per-unit style and display options; `PluralRules.select_range/3` now delegates to `Localize.Number.PluralRule.Range`.

### 1.0.0-rc.0 first pass (July 23, 2026)

Closed with Localize 1.0.0-rc.1: `minimum_integer_digits`, `trailing_zero_display`, `rounding_priority`, `format_to_parts/2` for numbers, `RelativeTimeFormat numeric: :always`, `supported_values_of` `:collation`/`:time_zone`, `supported_locales_of/1`, `PluralRules.select_range/3`, `Collator :usage`/`:collation`, and the DateTimeFormat `:era`/`:day_period`/`:time_zone_name`/`:hour12`/`:hour_cycle` components (plus the component-skeleton bug fix).

### Script Display Names

Resolved: `Localize.Script.display_name/2` is now available and `Intl.DisplayNames` supports `type: :script`.
