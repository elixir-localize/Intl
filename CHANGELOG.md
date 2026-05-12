# Changelog

All notable changes to this project will be documented in this file.

This project follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
