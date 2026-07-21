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
| `Intl.supportedValuesOf()` | `Intl.supported_values_of/1` | Partial — supports `:calendar`, `:currency`, `:numbering_system`, `:unit`. Does not support `"collation"` or `"timeZone"`. |

## Intl.NumberFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.NumberFormat.format/2` | Compatible |
| `formatRange()` | `Intl.NumberFormat.format_range/3` | Compatible — supports `:decimal`, `:currency`, and `:percent` styles. `:unit` ranges are not supported. |
| `formatToParts()` | — | Not supported |
| `formatRangeToParts()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

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
| `minimumIntegerDigits` | — | Not supported (Localize has no zero-padding option) |
| `minimumSignificantDigits` | `:minimum_significant_digits` | Pass-through; integer in `1..21` |
| `maximumSignificantDigits` | `:maximum_significant_digits` | Pass-through; integer in `1..21` |
| `useGrouping` | `:use_grouping` | `:always`, `:auto`, `:min2`, `true`, `false`. Mapped to Localize `:minimum_grouping_digits`. |
| `signDisplay` | `:sign_display` | `:auto`, `:always`, `:except_zero`, `:negative`, `:never`. Pass-through to Localize. |
| `currencyDisplay` | `:currency_display` | `:symbol`, `:narrow_symbol`, `:code`, `:name`. `:name` renders via the Localize `:currency_long` format, which formats the number as a decimal (no forced currency fraction digits). |
| `currencySign` | `:currency_sign` | `:standard` or `:accounting`. `:accounting` maps to the Localize `:accounting` format. |
| `numberingSystem` | `:numbering_system` | Mapped to Localize `:number_system`. Any valid CLDR numbering system may be used with any locale, including algorithmic systems. A `-u-nu-` locale extension is also honoured. |
| `roundingIncrement` | `:rounding_increment` | Mapped to Localize `:round_nearest`. Any positive integer is accepted (JS restricts the value set). |
| `roundingMode` | `:rounding_mode` | Pass-through to Localize |
| `roundingPriority` | — | Not supported |
| `trailingZeroDisplay` | — | Not supported |

When both fraction-digit and significant-digit options are given, significant digits take precedence (equivalent to the JS default `roundingPriority: "auto"`).

Compact notation applies the ECMA-402 default precision of at most two significant digits on the mantissa, matching JS (`1234` formats as "1.2K").

## Intl.DateTimeFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.DateTimeFormat.format/2` | Compatible |
| `formatRange()` | `Intl.DateTimeFormat.format_range/3` | Compatible |
| `formatToParts()` | — | Not supported |
| `formatRangeToParts()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

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
| `hour12` | — | Not directly supported; use locale extensions instead |
| `hourCycle` | — | Not supported |
| `timeZoneName` | — | Not supported |
| `numberingSystem` | — | Not supported |
| `era` | — | Not supported as a standalone component |
| `fractionalSecondDigits` | — | Not supported |
| `dayPeriod` | — | Not supported |

### DateTimeFormat Input Types

The JS API accepts `Date` objects. This library accepts Elixir `Date`, `Time`, `DateTime`, and `NaiveDateTime` structs. The appropriate Localize formatter is dispatched automatically based on the input type.

## Intl.ListFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.ListFormat.format/2` | Compatible |
| `formatToParts()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

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
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

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
| `formatToParts()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

### RelativeTimeFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `style` | `:style` | `:long`, `:short`, `:narrow`. Mapped to Localize `:format` (`:standard`, `:short`, `:narrow`). |
| `numeric` | `:numeric` | `:always` or `:auto`. Currently Localize always uses `:auto` behavior. |
| `localeMatcher` | — | Not supported |

### RelativeTimeFormat Differences

The JS API signature is `format(value, unit)` where both are required. The Elixir API is `format(value, unit, options)` with the unit as a separate argument rather than a string parameter.

The `:numeric` option with value `:always` is accepted but may not force numeric output in all cases, as the underlying Localize library defaults to auto-detection (using "yesterday"/"tomorrow" when the value is -1/+1).

## Intl.PluralRules

| JS Method | Elixir Function | Status |
|---|---|---|
| `select()` | `Intl.PluralRules.select/2` | Compatible |
| `selectRange()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

### PluralRules Differences

Returns `{:ok, atom}` (for example, `{:ok, :one}`) instead of a string like `"one"`.

## Intl.Collator

| JS Method | Elixir Function | Status |
|---|---|---|
| `compare()` | `Intl.Collator.compare/3` | Compatible (different return type) |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

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
| `usage` | — | Not supported (Localize always uses sort semantics) |
| `collation` | — | Not supported |
| `localeMatcher` | — | Not supported |

## Intl.DurationFormat

| JS Method | Elixir Function | Status |
|---|---|---|
| `format()` | `Intl.DurationFormat.format/2` | Compatible |
| `formatToParts()` | — | Not supported |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

### DurationFormat Differences

The JS API accepts a plain object with `years`, `months`, `days`, `hours`, `minutes`, `seconds` properties. This library accepts both a `Localize.Duration` struct and a plain map with those keys (plural or singular forms).

### DurationFormat Option Mapping

| JS Option | Elixir Option | Notes |
|---|---|---|
| `style` | `:style` | `:long`, `:short`, `:narrow` |
| Per-unit style options (`hoursDisplay`, etc.) | — | Not supported |

## Intl.Segmenter

| JS Method | Elixir Function | Status |
|---|---|---|
| `segment()` | `Intl.Segmenter.segment/2` | Partial |
| `resolvedOptions()` | — | Not supported |
| `supportedLocalesOf()` | — | Use `Localize.available_locale_id?/1` directly |

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

* **`formatToParts`** — Not available in any module. The underlying Localize library does not expose structured format parts.

* **`resolvedOptions`** — Not implemented. In the JS API this returns the effective options after locale negotiation and default resolution. Could be added in a future version.

* **`supportedLocalesOf`** — Not wrapped. Use `Localize.available_locale_id?/1` directly to check locale support.

* **`localeMatcher`** — The JS `localeMatcher` option (`"best fit"` / `"lookup"`) is not supported. Localize uses its own locale resolution strategy.
