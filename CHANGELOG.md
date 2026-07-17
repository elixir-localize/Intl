# Changelog

All notable changes to this project will be documented in this file.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.3.0] - 2026-07-18

### Added

* `Intl.NumberFormat.format/2` supports `notation: :scientific` and `notation: :engineering`.

* `Intl.NumberFormat.format/2` supports `:currency_display` (`:symbol`, `:narrow_symbol`, `:code`, `:name`) and `:currency_sign` (`:standard`, `:accounting`).

* `Intl.NumberFormat.format/2` supports `:use_grouping` (`:always`, `:auto`, `:min2`, `true`, `false`), mapped to Localize `:minimum_grouping_digits`.

* `Intl.NumberFormat.format/2` supports `:minimum_significant_digits`, `:maximum_significant_digits`, `:numbering_system`, and `:rounding_increment`.

* `Intl.NumberFormat.format_range/3` supports the `:currency` and `:percent` styles in addition to `:decimal`.

### Changed

* Localize 0.50 or later is required. Compact notation now applies the ECMA-402 default precision of at most two significant digits ("1.2K" for 1234), matching JS.

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
