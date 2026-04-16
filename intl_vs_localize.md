# JavaScript Intl vs Localize: Functional Comparison

This document compares the functional coverage of the [JavaScript Intl API](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl) and the [Localize](https://hexdocs.pm/localize) Elixir library. Both are built on the Unicode CLDR data set, but they expose different subsets of that data and offer different capabilities.

## Summary

JavaScript Intl provides a focused set of formatting and comparison APIs for use in browsers and server-side JS. Localize provides a broader set of internationalization functions including everything Intl offers plus message formatting, unit conversion, number parsing, rule-based number formatting, territory and currency metadata, calendar locale data, Gettext integration, and more.

## Feature-by-Feature Comparison

### Number Formatting

| Capability | JS Intl | Localize |
|---|---|---|
| Decimal formatting | `Intl.NumberFormat` | `Localize.Number.to_string/2` |
| Currency formatting | `Intl.NumberFormat` (style: "currency") | `Localize.Number.to_string/2` (format: :currency) |
| Percent formatting | `Intl.NumberFormat` (style: "percent") | `Localize.Number.to_string/2` (format: :percent) |
| Unit formatting | `Intl.NumberFormat` (style: "unit") | `Localize.Unit.to_string/2` |
| Scientific notation | `Intl.NumberFormat` (notation: "scientific") | `Localize.Number.to_string/2` (format: :scientific) |
| Compact notation ("1.2K") | `Intl.NumberFormat` (notation: "compact") | `Localize.Number.to_string/2` (format: :decimal_short / :decimal_long) |
| Format to parts | `formatToParts()` | Not available |
| Range formatting | `formatRange()` | `Localize.Number.to_range_string/3` |
| Number parsing | Not available | `Localize.Number.Parser.parse/2` |
| Number scanning in text | Not available | `Localize.Number.Parser.scan/2` |
| Approximate/at-least/at-most | Not available | `to_approximately_string/2`, `to_at_least_string/2`, `to_at_most_string/2` |
| Ratio/fraction formatting | Not available | `Localize.Number.to_ratio_string/2` |
| Rule-based formatting (spellout, Roman numerals) | Not available | `Localize.Number.Rbnf.to_string/3` |
| Number system transliteration | Not available | `Localize.Number.Transliterate` |
| Currency symbol resolution from text | Not available | `Localize.Number.Parser.resolve_currency/2` |

### Date and Time Formatting

| Capability | JS Intl | Localize |
|---|---|---|
| Date formatting | `Intl.DateTimeFormat` | `Localize.Date.to_string/2` |
| Time formatting | `Intl.DateTimeFormat` | `Localize.Time.to_string/2` |
| DateTime formatting | `Intl.DateTimeFormat` | `Localize.DateTime.to_string/2` |
| Format to parts | `formatToParts()` | Not available |
| Date/time range formatting | `formatRange()` | `Localize.Interval.to_string/3` |
| Partial date formatting (year+month only, etc.) | Not directly | `Localize.Date.to_string/2` with partial maps |
| Custom CLDR skeletons | Via component options | Direct skeleton atoms or strings |
| Relative time ("3 days ago") | `Intl.RelativeTimeFormat` | `Localize.DateTime.Relative.to_string/2` |
| Calendar metadata (month names, day names, eras) | Not available | `Localize.Calendar.months/2`, `days/2`, `eras/2`, `quarters/2`, `day_periods/2` |
| First day of week / weekend days per territory | Not available | `Localize.Calendar.first_day_for_territory/1`, `weekend/1` |
| Calendar display names | `Intl.DisplayNames` (type: "calendar") | `Localize.Calendar.display_name/3` |
| Date-time field display names | `Intl.DisplayNames` (type: "dateTimeField") | `Localize.Calendar.display_name/3` |
| strftime-compatible options | Not available | `Localize.Calendar.strftime_options!/1` |
| Multiple calendar systems | Via `calendar` option | 17+ calendar types (Gregorian, Buddhist, Chinese, Hebrew, Islamic, Japanese, Persian, etc.) |

### Duration Formatting

| Capability | JS Intl | Localize |
|---|---|---|
| Duration formatting (unit names) | `Intl.DurationFormat` | `Localize.Duration.to_string/2` |
| Duration formatting (numeric, "37:48:12") | Not available | `Localize.Duration.to_time_string/2` |
| Duration calculation between dates | Not available | `Localize.Duration.new/2` |
| Duration from seconds | Not available | `Localize.Duration.new_from_seconds/1` |
| Format to parts | `formatToParts()` | Not available |

### List Formatting

| Capability | JS Intl | Localize |
|---|---|---|
| Conjunction lists ("a, b, and c") | `Intl.ListFormat` (type: "conjunction") | `Localize.List.to_string/2` (format: :standard) |
| Disjunction lists ("a, b, or c") | `Intl.ListFormat` (type: "disjunction") | `Localize.List.to_string/2` (format: :or) |
| Unit lists ("a, b, c") | `Intl.ListFormat` (type: "unit") | `Localize.List.to_string/2` (format: :unit) |
| Format to parts | `formatToParts()` | Not available |
| Intersperse (for safe HTML) | Not available | `Localize.List.intersperse/2` |

### Display Names

| Capability | JS Intl | Localize |
|---|---|---|
| Region/territory names | `Intl.DisplayNames` (type: "region") | `Localize.Territory.display_name/2` |
| Language names | `Intl.DisplayNames` (type: "language") | `Localize.Language.display_name/2` |
| Currency names | `Intl.DisplayNames` (type: "currency") | `Localize.Currency.display_name/2` |
| Script names | `Intl.DisplayNames` (type: "script") | `Localize.Script.display_name/2` |
| Calendar type names | `Intl.DisplayNames` (type: "calendar") | `Localize.Calendar.display_name(:calendar, ...)` |
| Date-time field names | `Intl.DisplayNames` (type: "dateTimeField") | `Localize.Calendar.display_name(:date_time_field, ...)` |
| Locale display names ("English (United States)") | Not available | `Localize.Locale.LocaleDisplay.display_name/2` |
| Subdivision names | Not available | `Localize.Territory.subdivision_name/2` |
| Territory translation (name in one locale to another) | Not available | `Localize.Territory.translate_territory/3` |
| Reverse lookup (name to territory code) | Not available | `Localize.Territory.to_territory_code/2` |

### Plural Rules

| Capability | JS Intl | Localize |
|---|---|---|
| Cardinal plural category | `Intl.PluralRules` (type: "cardinal") | `Localize.Number.PluralRule.plural_type/2` (type: :cardinal) |
| Ordinal plural category | `Intl.PluralRules` (type: "ordinal") | `Localize.Number.PluralRule.plural_type/2` (type: :ordinal) |
| Range plural category | `selectRange()` | Not available |

### Collation (String Comparison and Sorting)

| Capability | JS Intl | Localize |
|---|---|---|
| Locale-aware string comparison | `Intl.Collator.compare()` | `Localize.Collation.compare/3` |
| Locale-aware sorting | Via `Array.sort()` with Collator | `Localize.Collation.sort/2` |
| Sort key generation | Not available | `Localize.Collation.sort_key/2` |
| Sensitivity / strength levels | `sensitivity` option | `strength` option |
| Numeric collation | `numeric` option | `numeric` option |
| Case-first ordering | `caseFirst` option | `case_first` option |

### Text Segmentation

| Capability | JS Intl | Localize |
|---|---|---|
| Grapheme cluster segmentation | `Intl.Segmenter` (granularity: "grapheme") | Not in Localize (Elixir built-in: `String.graphemes/1`) |
| Word segmentation | `Intl.Segmenter` (granularity: "word") | Not in Localize (available via `unicode_string` library) |
| Sentence segmentation | `Intl.Segmenter` (granularity: "sentence") | Not in Localize (available via `unicode_string` library) |
| Segment metadata (isWordLike) | Yes | Not available |
| Line break segmentation | Not available | Not in Localize (available via `unicode_string` library) |

### Message Formatting

| Capability | JS Intl | Localize |
|---|---|---|
| ICU MessageFormat 2 | Not available | `Localize.Message.format/3` |
| Message canonicalization | Not available | `Localize.Message.canonical_message/2` |
| Message similarity (Jaro distance) | Not available | `Localize.Message.jaro_distance/3` |
| Gettext integration | Not available | `Localize.Gettext.Interpolation` |

### Units of Measurement

| Capability | JS Intl | Localize |
|---|---|---|
| Unit formatting | `Intl.NumberFormat` (style: "unit") | `Localize.Unit.to_string/2` |
| Unit creation and validation | Not available | `Localize.Unit.new/3` |
| Unit conversion | Not available | `Localize.Unit.convert/2` |
| Measurement system conversion | Not available | `Localize.Unit.convert_measurement_system/2` |
| Unit arithmetic | Not available | `Localize.Unit.Math` (add, subtract, multiply, divide, compare) |
| Territory-based unit preferences | Not available | `Localize.Unit.Preference` |
| Usage-based formatting ("person-height", "road") | Not available | `Localize.Unit.to_string/2` with `:usage` option |
| Unit category discovery | Not available | `Localize.Unit.known_units_by_category/0` |
| Measurement system per territory | Not available | `Localize.Unit.measurement_system_for_territory/1` |

### Currency Data

| Capability | JS Intl | Localize |
|---|---|---|
| Currency formatting | `Intl.NumberFormat` (style: "currency") | `Localize.Number.to_string/2` (format: :currency) |
| Currency display name | `Intl.DisplayNames` (type: "currency") | `Localize.Currency.display_name/2` |
| Currency validation | Not available | `Localize.Currency.known_currency_code?/1` |
| Custom currency creation | Not available | `Localize.Currency.new/2` |
| Currencies for a locale | Not available | `Localize.Currency.currencies_for_locale/1` |
| Currency code from territory | Not available | `Localize.Territory.to_currency_code/1` |

### Territory Data

| Capability | JS Intl | Localize |
|---|---|---|
| Territory display name | `Intl.DisplayNames` (type: "region") | `Localize.Territory.display_name/2` |
| Territory hierarchy (parent/children/contains?) | Not available | `Localize.Territory.parent/1`, `children/1`, `contains?/2` |
| Territory info (GDP, population, etc.) | Not available | `Localize.Territory.info/1` |
| Unicode flag emoji | Not available | `Localize.Territory.unicode_flag/1` |
| Country codes list | Not available | `Localize.Territory.country_codes/0` |

### Locale Management

| Capability | JS Intl | Localize |
|---|---|---|
| Canonical locale names | `Intl.getCanonicalLocales()` | `Localize.LanguageTag.canonicalize/1` |
| Supported values discovery | `Intl.supportedValuesOf()` | Various `known_*` functions |
| BCP 47 language tag parsing | `Intl.Locale` constructor | `Localize.LanguageTag.parse/1` |
| Process-level locale | Not applicable (browser locale) | `Localize.get_locale/0`, `put_locale/1`, `with_locale/2` |
| Locale matching / distance | Not available | `Localize.Locale.DistanceTrie` |
| Locale display name ("English (United States)") | Not available | `Localize.Locale.LocaleDisplay.display_name/2` |
| Likely subtags | Not available | Supported via CLDR data |

### Text Utilities

| Capability | JS Intl | Localize |
|---|---|---|
| Locale-aware quotation marks | Not available | `Localize.quote/2` |
| Locale-aware ellipsis | Not available | `Localize.ellipsis/2` |

## Capabilities Unique to JS Intl

* **`formatToParts()`** — All JS Intl formatters can return structured arrays of `{type, value}` objects representing the individual parts of a formatted string. This is useful for custom rendering (for example, styling the currency symbol differently from the number). Localize does not expose format parts.

* **`Intl.Segmenter` segment metadata** — The JS segmenter returns `isWordLike` for each word segment, distinguishing content words from punctuation and whitespace. The `unicode_string` library (used by `Intl.Segmenter` in this project) does not provide this metadata.

* **`Intl.PluralRules.selectRange()`** — Determines the plural category for a range of numbers (for example, "1–3 items"). Localize does not provide range plural selection.

## Capabilities Unique to Localize

* **ICU MessageFormat 2** — `Localize.Message.format/3` parses and evaluates MessageFormat 2 strings with variable placeholders, plural rules, select expressions, and custom formatting functions. JS has no built-in message formatting (developers typically use external libraries like `intl-messageformat`).

* **Rule-based number formatting (RBNF)** — `Localize.Number.Rbnf.to_string/3` formats numbers as spellout text ("one hundred twenty-three"), ordinal text ("twenty-third"), Roman numerals ("CXXIII"), and other algorithmic number systems per locale.

* **Number parsing** — `Localize.Number.Parser.parse/2` parses locale-formatted number strings back into numbers, handling locale-specific decimal separators and grouping characters. JS Intl has no parsing counterpart.

* **Unit conversion and arithmetic** — `Localize.Unit.convert/2` converts between compatible units (kilometers to miles, Celsius to Fahrenheit). `Localize.Unit.Math` provides add, subtract, multiply, divide, and compare operations on unit values. JS Intl can format units but cannot convert between them.

* **Territory hierarchy and metadata** — `Localize.Territory` provides parent/child relationships between territories (for example, "US" is contained in "Northern America" which is contained in "Americas"), territory info (population, GDP, languages), and Unicode flag emoji.

* **Calendar locale data** — `Localize.Calendar` exposes month names, day names, era names, quarter names, and day period names in all styles (wide, abbreviated, narrow) for all supported calendars and locales. It also provides first-day-of-week and weekend configuration per territory.

* **Duration calculation** — `Localize.Duration.new/2` computes the calendar duration between two dates or times. JS `Intl.DurationFormat` can only format a duration object that you provide — it cannot calculate one.

* **Locale display names** — `Localize.Locale.LocaleDisplay.display_name/2` produces human-readable locale descriptions like "English (United States)" or "français (France)". JS Intl has no equivalent.

* **Subdivision names** — `Localize.Territory.subdivision_name/2` provides localized names for country subdivisions (states, provinces, regions). JS Intl does not support subdivisions.

* **Custom currencies** — `Localize.Currency.new/2` allows defining private-use currency codes for applications that need currencies not in ISO 4217.

* **Gettext integration** — `Localize.Gettext.Interpolation` provides a Gettext interpolation backend that uses CLDR formatting for interpolated values.

* **Text utilities** — `Localize.quote/2` wraps text in locale-appropriate quotation marks (for example, « » for French, „ " for German). `Localize.ellipsis/2` adds locale-appropriate ellipsis characters.

* **List intersperse** — `Localize.List.intersperse/2` returns a list with separator strings inserted between elements (rather than a concatenated string), which is useful for building safe HTML output where elements may contain markup.
