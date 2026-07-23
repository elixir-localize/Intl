# Intl API Compatibility

This document tracks the compatibility between this Elixir `Intl` library and the [JavaScript Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl).

## General Differences

The JS Intl API is object-oriented: you create a formatter instance with `new Intl.NumberFormat(locale, options)` and then call methods on it. This library is functional: options are passed directly to each function call as a keyword list.

All JS camelCase parameter names are converted to snake_case in this library. For example, `minimumFractionDigits` becomes `minimum_fraction_digits`.

Return values use Elixir's `{:ok, result}` / `{:error, reason}` convention. Bang variants (for example, `format!/2`) are provided for convenience.

## Static Methods

| JS Intl Method | Elixir Function | Status |
|---|---|---|
| `Intl.getCanonicalLocales()` | `Intl.get_canonical_locales/1` | Compatible |
| `supportedLocalesOf()` (per constructor) | `Intl.supported_locales_of/1` | One top-level function — all modules share the same CLDR locale data |
| `Intl.supportedValuesOf()` | `Intl.supported_values_of/1` | Compatible — supports `:calendar`, `:collation`, `:currency`, `:numbering_system`, `:time_zone`, and `:unit`. |

## Intl.NumberFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.NumberFormat.format/2` | Compatible |
| `formatRange()` | `Intl.NumberFormat.format_range/3` | Compatible — supports all styles. Unit ranges apply the unit pattern once ("2–5 kilometers") with the TR35 plural-range category. |
| `formatToParts()` | `Intl.NumberFormat.format_to_parts/2` | Compatible for all styles. Part types are snake_case atoms (`:minus_sign` rather than `"minusSign"`); unit text is a `:unit` part and the `currency_display: :name` currency name is a `:currency` part. |
| `formatRangeToParts()` | `Intl.NumberFormat.format_range_to_parts/3` | Compatible for `:decimal`, `:currency`, and `:percent` styles; parts carry a `:source` key (`:start_range`, `:end_range`, `:shared`). `:unit` range parts are not supported. |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### NumberFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `style` | `:style` | `:decimal`, `:currency`, `:percent`, `:unit` |
| `currency` | `:currency` | Pass-through |
| `unit` | `:unit` | Unit identifier string |
| `unitDisplay` | `:unit_display` | `:long`, `:short`, `:narrow` |
| `notation` | `:notation` | `:standard`, `:scientific`, `:engineering`, or `:compact` |
| `compactDisplay` | `:compact_display` | `:short` or `:long`. Compact currency always uses the short form (CLDR defines no long compact currency format). |
| `minimumFractionDigits` | `:minimum_fraction_digits` | Mapped to `:min_fractional_digits` in Localize |
| `maximumFractionDigits` | `:maximum_fraction_digits` | Mapped to `:max_fractional_digits` in Localize |
| `minimumIntegerDigits` | `:minimum_integer_digits` | Pass-through; integer in `1..21` |
| `minimumSignificantDigits` | `:minimum_significant_digits` | Pass-through; integer in `1..21` |
| `maximumSignificantDigits` | `:maximum_significant_digits` | Pass-through; integer in `1..21` |
| `useGrouping` | `:use_grouping` | `:always`, `:auto`, `:min2`, `true`, `false`. Mapped to Localize `:minimum_grouping_digits`. |
| `signDisplay` | `:sign_display` | `:auto`, `:always`, `:except_zero`, `:negative`, `:never`. Pass-through to Localize. |
| `currencyDisplay` | `:currency_display` | `:symbol`, `:narrow_symbol`, `:code`, `:name`. `:name` renders via the Localize `:currency_long` format with the currency's fraction digits applied ("1,234.50 US dollars"), matching JS. |
| `currencySign` | `:currency_sign` | `:standard` or `:accounting`. `:accounting` maps to the Localize `:accounting` format. |
| `numberingSystem` | `:numbering_system` | Mapped to Localize `:number_system`. Any valid CLDR numbering system may be used with any locale, including algorithmic systems. A `-u-nu-` locale extension is also honoured. |
| `roundingIncrement` | `:rounding_increment` | Mapped to Localize `:round_nearest`. Any positive integer is accepted (JS restricts the value set). |
| `roundingMode` | `:rounding_mode` | Pass-through to Localize |
| `roundingPriority` | `:rounding_priority` | `:auto`, `:more_precision`, `:less_precision`, per ECMA-402 |
| `trailingZeroDisplay` | `:trailing_zero_display` | `:auto` or `:strip_if_integer` |

With the default `rounding_priority: :auto`, a significant-digit bound causes the fraction-digit bounds to be ignored entirely, per ECMA-402.

Compact notation applies the ECMA-402 default precision of at most two significant digits on the mantissa, matching JS (`1234` formats as "1.2K").

## Intl.DateTimeFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.DateTimeFormat.format/2` | Compatible |
| `formatRange()` | `Intl.DateTimeFormat.format_range/3` | Compatible |
| `formatToParts()` | `Intl.DateTimeFormat.format_to_parts/2` | Compatible — decomposes styles, component skeletons, and combined date+time wrappers into typed field parts. |
| `formatRangeToParts()` | — | Not supported (Localize interval formatting does not yet expose parts) |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### DateTimeFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `dateStyle` | `:date_style` | `:full`, `:long`, `:medium`, `:short` |
| `timeStyle` | `:time_style` | `:full`, `:long`, `:medium`, `:short` |
| `weekday` | `:weekday` | Component options build a CLDR skeleton |
| `year` | `:year` | Component option |
| `month` | `:month` | Component option |
| `day` | `:day` | Component option |
| `hour` | `:hour` | Component option |
| `minute` | `:minute` | Component option |
| `second` | `:second` | Component option |
| `timeZone` | `:time_zone` | Pass-through |
| `calendar` | `:calendar` | Pass-through |
| `hour12` | `:hour12` | Boolean; selects the 12- or 24-hour symbol for the `:hour` component |
| `hourCycle` | `:hour_cycle` | `:h11`, `:h12`, `:h23`, `:h24`. Takes precedence over `:hour12`. |
| `timeZoneName` | `:time_zone_name` | `:short`, `:long`, `:short_offset`, `:long_offset`, `:short_generic`, `:long_generic` |
| `numberingSystem` | — | Use a `-u-nu-` locale extension (for example, `locale: "en-u-nu-thai"`) |
| `era` | `:era` | `:long`, `:short`, `:narrow` |
| `fractionalSecondDigits` | `:fractional_second_digits` | `1`, `2`, or `3` fractional-second digits, separated by the locale decimal separator |
| `dayPeriod` | `:day_period` | `:long`, `:short`, `:narrow` — flexible day periods ("in the morning") |

### DateTimeFormat Input Types

The JS API accepts `Date` objects. This library accepts Elixir `Date`, `Time`, `DateTime`, and `NaiveDateTime` structs. The appropriate Localize formatter is dispatched automatically based on the input type.

## Intl.ListFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.ListFormat.format/2` | Compatible |
| `formatToParts()` | `Intl.ListFormat.format_to_parts/2` | Compatible — `:element` and `:literal` parts |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### ListFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `type` | `:type` | `:conjunction`, `:disjunction`, `:unit` |
| `style` | `:style` | `:long`, `:short`, `:narrow` |

The combination of `type` and `style` is mapped to a Localize list format atom (for example, `:standard`, `:or_short`, `:unit_narrow`).

## Intl.DisplayNames

| JS Method | Elixir Function | Status |
|---|---|---|
| `of()` | `Intl.DisplayNames.of/2` | Partial |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### DisplayNames Type Support

| JS Type | Elixir `:type` | Status |
|---|---|---|
| `"region"` | `:region` | Compatible — delegates to `Localize.Territory.display_name/2` |
| `"language"` | `:language` | Compatible — delegates to `Localize.Language.display_name/2` |
| `"currency"` | `:currency` | Compatible — delegates to `Localize.Currency.display_name/2` |
| `"script"` | `:script` | Compatible — delegates to `Localize.Script.display_name/2` |
| `"calendar"` | `:calendar` | Compatible — delegates to `Localize.Calendar.display_name/3` |
| `"dateTimeField"` | `:date_time_field` | Compatible — delegates to `Localize.Calendar.display_name/3` |

## Intl.RelativeTimeFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.RelativeTimeFormat.format/3` | Compatible |
| `formatToParts()` | `Intl.RelativeTimeFormat.format_to_parts/3` | Compatible — the `:integer` part carries a `:unit` key |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### RelativeTimeFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `style` | `:style` | `:long`, `:short`, `:narrow`. Mapped to Localize `:format` (`:standard`, `:short`, `:narrow`). |
| `numeric` | `:numeric` | `:always` or `:auto`. `:always` forces numeric output ("1 day ago" instead of "yesterday"). |
| `localeMatcher` | — | Not supported |

### RelativeTimeFormat Differences

The JS API signature is `format(value, unit)` where both are required. The Elixir API is `format(value, unit, options)` with the unit as a separate argument rather than a string parameter.

## Intl.PluralRules

| JS Method | Elixir Function | Status |
|---|---|---|
| `select()` | `Intl.PluralRules.select/2` | Compatible |
| `selectRange()` | `Intl.PluralRules.select_range/3` | Compatible — uses the CLDR plural-ranges data |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### PluralRules Differences

Returns `{:ok, atom}` (for example, `{:ok, :one}`) instead of a string like `"one"`.

## Intl.Collator

| JS Method | Elixir Function | Status |
|---|---|---|
| `compare()` | `Intl.Collator.compare/3` | Compatible (different return type) |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### Collator Differences

The JS `compare()` returns -1, 0, or 1. This library returns `:lt`, `:eq`, or `:gt` following Elixir conventions, making it compatible with `Enum.sort/2`.

An additional `sort/2` convenience function is provided that is not present in the JS API.

### Collator Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `sensitivity` | `:sensitivity` | `:base`, `:accent`, `:case`, `:variant`. Mapped to Localize `:strength` (`:primary`, `:secondary`, `:tertiary`, `:quaternary`). |
| `caseFirst` | `:case_first` | Pass-through to Localize |
| `numeric` | `:numeric` | Pass-through to Localize |
| `ignorePunctuation` | `:ignore_punctuation` | Mapped to Localize `alternate: :shifted` |
| `usage` | `:usage` | `:sort` (default) or `:search`. `:search` selects the locale's search collation tailoring. |
| `collation` | `:collation` | Collation type atom (`:phonebook`, `:pinyin`, `:emoji`, …), mapped to Localize `:type`. Ignored when `:usage` is `:search`. |
| `localeMatcher` | — | Not supported |

## Intl.DurationFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.DurationFormat.format/2` | Compatible |
| `formatToParts()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### DurationFormat Differences

The JS API accepts a plain object with `years`, `months`, `days`, `hours`, `minutes`, `seconds` properties. This library accepts both a `Localize.Duration` struct and a plain map with those keys (plural or singular forms).

### DurationFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `style` | `:style` | `:long`, `:short`, `:narrow` |
| Per-unit styles (`hours`, `minutes`, …) | `:hours`, `:minutes`, … | `:long`, `:short`, or `:narrow` per unit |
| Per-unit display (`hoursDisplay`, etc.) | `:hours_display`, … | `:auto` or `:always` per unit |

## Intl.Segmenter

| JS Method | Elixir Function | Status |
|---|---|---|
| `segment()` | `Intl.Segmenter.segment/2` | Partial |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Intl.supported_locales_of/1` |

### Segmenter Granularity Support

| JS Granularity | Elixir `:granularity` | Status |
|---|---|---|
| `"grapheme"` | `:grapheme` | Compatible — uses `String.graphemes/1` (always available) |
| `"word"` | `:word` | Compatible — requires optional `unicode_string` dependency |
| `"sentence"` | `:sentence` | Compatible — requires optional `unicode_string` dependency |

### Segmenter Differences

* The JS API returns an iterable of `{segment, index, input, isWordLike}` objects. This library returns `{:ok, [String.t()]}` — a flat list of segment strings.

* The `isWordLike` property from JS word segmentation is not replicated.

* The `:word` and `:sentence` granularity require the optional `unicode_string` (~> 1.8) dependency. If not installed, these return `{:error, reason}`.

## Features Not Supported Across All Modules

* **`formatToParts`** — Available for `Intl.NumberFormat`, `Intl.DateTimeFormat`, `Intl.ListFormat`, and `Intl.RelativeTimeFormat`. `Intl.DurationFormat` and `Intl.Segmenter` have no parts API (the JS `Segmenter` has none either).

* **`resolvedOptions`** — Not implemented. In the JS API this returns the effective options after locale negotiation and default resolution. Could be added in a future version.

* **`localeMatcher`** — The JS `localeMatcher` option (`"best fit"` / `"lookup"`) is not supported. Localize uses its own locale resolution strategy.
