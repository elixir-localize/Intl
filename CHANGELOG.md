# Changelog

All notable changes to this project will be documented in this file.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

* `Intl.supported_values_of(:collation)` excludes `"standard"` and `"search"` from the returned collation values, per ECMA-402 `supportedValuesOf`.

## [1.0.0-rc.0] - 2026-07-23

### Added

* `Intl.NumberFormat.format_to_parts/2` and `format_to_parts!/2` return typed parts per JS `formatToParts()`, for all styles including `:unit` and `currency_display: :name`.

* `Intl.NumberFormat.format_range_to_parts/3` and `format_range_to_parts!/3` implement JS `formatRangeToParts()` with `:source` tagging (`:start_range`, `:end_range`, `:shared`).

* `Intl.NumberFormat.format_range/3` supports `style: :unit`: the unit pattern is applied once to the range ("2–5 kilometers") with the TR35 plural-range category.

* `Intl.DateTimeFormat.format_to_parts/2` and `format_to_parts!/2` implement JS `formatToParts()` across styles, component skeletons, and combined date+time wrappers.

* `Intl.DateTimeFormat.format_range_to_parts/3` and `format_range_to_parts!/3` implement JS `formatRangeToParts()` with `:source` tagging.

* `Intl.DateTimeFormat.format/2` supports the `:numbering_system` option: any CLDR numbering system renders all numeric fields.

* `Intl.DurationFormat.format_to_parts/2` and `format_to_parts!/2` implement JS `formatToParts()`; numeric parts carry a `:unit` key.

* `Intl.NumberFormat.format_range_to_parts/3` supports `style: :unit`, completing range parts for all styles.

* `Intl.Segmenter.segment_with_metadata/2` and `segment_with_metadata!/2` mirror the JS segment objects: `:segment`, `:index` (byte offset), and `:word_like?` (the JS `isWordLike`, via `Unicode.String.word_like?/1`).

* `Intl.DateTimeFormat.format/2` supports the `:fractional_second_digits` component option (1–3 digits).

* `Intl.ListFormat.format_to_parts/2` and `format_to_parts!/2` implement JS `formatToParts()` with `:element` and `:literal` parts.

* `Intl.RelativeTimeFormat.format_to_parts/3` and `format_to_parts!/3` implement JS `formatToParts()`; the `:integer` part carries a `:unit` key.

* `Intl.DurationFormat.format/2` supports the JS per-unit style options (`:hours`, `:minutes`, …) and per-unit display options (`:hours_display`, …, `:auto` or `:always`).

* `Intl.NumberFormat.format/2` supports `:minimum_integer_digits`, `:trailing_zero_display` (`:strip_if_integer`), and `:rounding_priority` (`:more_precision`, `:less_precision`).

* `Intl.DateTimeFormat.format/2` supports the `:era`, `:day_period`, `:time_zone_name`, `:hour12`, and `:hour_cycle` component options.

* `Intl.PluralRules.select_range/3` and `select_range!/3` implement JS `selectRange()` using the CLDR plural-ranges data.

* `Intl.Collator` supports `:usage` (`:sort`, `:search`) and `:collation` (`:phonebook`, `:pinyin`, `:emoji`, …).

* `Intl.supported_locales_of/1` implements the JS `supportedLocalesOf()` static methods as one top-level function.

* `Intl.supported_values_of/1` supports `:collation` and `:time_zone`, completing the JS `supportedValuesOf()` key set.

* `Intl.RelativeTimeFormat.format/3` honours `numeric: :always`, forcing "1 day ago" instead of "yesterday".

### Changed

* Localize 1.0.0-rc.3 or later is required.

* `currency_display: :name` applies the currency's fraction digits ("1,234.50 US dollars", previously "1,234 US dollars"), matching JS.

* With the default `rounding_priority: :auto`, a significant-digit bound causes fraction-digit bounds to be ignored entirely, per ECMA-402.

* Relative time offsets of zero format with the future pattern ("in 0 days") per ECMA-402.

### Fixed

* `Intl.DateTimeFormat` component options (`:year`, `:month`, `:day`, …) now match a locale format. Previously the generated skeleton was passed as a literal pattern, rendering without locale separators ("2025March15" instead of "March 15, 2025").

## [0.3.0] - 2026-07-22

### Added

* `Intl.NumberFormat.format/2` supports `notation: :scientific` and `notation: :engineering`.

* `Intl.NumberFormat.format/2` supports `:currency_display` (`:symbol`, `:narrow_symbol`, `:code`, `:name`) and `:currency_sign` (`:standard`, `:accounting`).

* `Intl.NumberFormat.format/2` supports `:use_grouping` (`:always`, `:auto`, `:min2`, `true`, `false`), mapped to Localize `:minimum_grouping_digits`.

* `Intl.NumberFormat.format/2` supports `:minimum_significant_digits`, `:maximum_significant_digits`, `:numbering_system`, and `:rounding_increment`.

* `Intl.NumberFormat.format/2` supports `:sign_display` (`:auto`, `:always`, `:except_zero`, `:negative`, `:never`) mirroring the JS `signDisplay` option.

* `:numbering_system` accepts any valid CLDR numbering system for any locale, including algorithmic systems, and `-u-nu-` locale extensions are honoured.

* `Intl.NumberFormat.format_range/3` supports the `:currency` and `:percent` styles in addition to `:decimal`.

### Changed

* Localize 1.0.0-rc.0 or later is required. Compact notation now applies the ECMA-402 default precision of at most two significant digits ("1.2K" for 1234), matching JS.

* Negative currency amounts render the sign before the symbol ("-$1.00", previously "$-1.00"), matching JS `Intl.NumberFormat`.

* `Intl.DurationFormat` translates its `:style` option to the Localize `:format` option, following the Localize 0.43 rename.

### Fixed

* `Intl.NumberFormat.format/2` returns `{:error, %ArgumentError{}}` for invalid `:style`, `:notation`, or `:compact_display` values instead of raising `CaseClauseError`.

## [0.2.0] - 2025-05-12

### Bug Fixes

* Relax the dependency requirement for `localize` to be "~> 0.31 or ~> 1.0".

## [0.1.0] - 2025-04-16

### Highlights

Initial release of `Intl`, an Elixir interface modelled on the JavaScript Intl API.

This library provides a familiar API for developers who know JS Intl, adapted to idiomatic Elixir conventions. It delegates to the `Localize` library for all locale-aware formatting and data access.

Supported modules:

* `Intl.NumberFormat` — locale-aware number, currency, percent, and unit formatting.

* `Intl.DateTimeFormat` — locale-aware date and time formatting with range support.

* `Intl.ListFormat` — list joining with conjunctions, disjunctions, or unit separators.

* `Intl.DisplayNames` — localized names for regions, languages, currencies, scripts, calendars, and date-time fields.

* `Intl.RelativeTimeFormat` — relative time strings ("3 days ago", "in 2 hours").

* `Intl.PluralRules` — CLDR plural category selection (cardinal and ordinal).

* `Intl.Collator` — locale-aware string comparison and sorting via the Unicode Collation Algorithm.

* `Intl.DurationFormat` — locale-aware duration formatting.

* `Intl.Segmenter` — text segmentation into graphemes (built-in), words, and sentences (via optional `unicode_string` dependency).

See the [README](https://github.com/elixir-cldr/intl/blob/v0.1.0/README.md) for usage examples and the [compatibility matrix](https://github.com/elixir-cldr/intl/blob/v0.1.0/compatibility.md) for a detailed comparison with the JS Intl API.
