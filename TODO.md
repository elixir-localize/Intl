# TODO

Remaining conformance gaps against the JS Intl API, tracked in the
[compatibility guide](https://hexdocs.pm/intl/compatibility.html). Every
upstream-blocked gap is closed; what remains is Intl-side only.

## Deferred

* [ ] **`resolvedOptions`** — could be built on `Localize.Number.Format.Options.validate_options/2` for NumberFormat; the other modules need equivalent option resolution first. Deferred as an introspection-only API.
* [ ] **`localeMatcher`** — deliberately not supported; Localize's own locale resolution applies.

## Done

* [x] **`dateTimeField` names and flat `supportedValuesOf(:unit)`** — `Intl.DisplayNames.of/2` accepts the JS `:week_of_year` and `:time_zone_name`, which Localize spells `:week` and `:zone`, so all twelve JS field names resolve; `Intl.supported_values_of(:unit)` returns a flat list. 2026-07-28, v1.0.0-rc.1.
* [x] **Segmenter metadata** — `Intl.Segmenter.segment_with_metadata/2` provides the JS segment-object shape with `:word_like?` (`isWordLike`) via `Unicode.String.word_like?/1`. 2026-07-23, with `unicode_string` 2.3.0.
* [x] **Remaining `formatToParts` and `formatRangeToParts` surfaces** — `DateTimeFormat.format_range_to_parts/3`, `NumberFormat.format_range_to_parts/3` for `style: :unit`, `DurationFormat.format_to_parts/2`, and `:numbering_system` for date and time formatting. 2026-07-23, with Localize post-1.0.0-rc.2.
* [x] **Parts APIs and duration options** — `format_to_parts` for DateTimeFormat, ListFormat and RelativeTimeFormat; NumberFormat `format_range_to_parts/3`, unit parts, unit ranges and `currency_display: :name` parts; DateTimeFormat `fractional_second_digits`; DurationFormat per-unit style and display; `PluralRules.select_range/3` delegating to `Localize.Number.PluralRule.Range`. 2026-07-23, with Localize 1.0.0-rc.2.
* [x] **First conformance pass** — `minimum_integer_digits`, `trailing_zero_display`, `rounding_priority`, `format_to_parts/2` for numbers, `RelativeTimeFormat numeric: :always`, `supported_values_of` for `:collation` and `:time_zone`, `supported_locales_of/1`, `PluralRules.select_range/3`, Collator `:usage` and `:collation`, and the DateTimeFormat `:era`, `:day_period`, `:time_zone_name`, `:hour12` and `:hour_cycle` components. 2026-07-23, with Localize 1.0.0-rc.1.
* [x] **Script display names** — `Localize.Script.display_name/2` landed and `Intl.DisplayNames` supports `type: :script`.
