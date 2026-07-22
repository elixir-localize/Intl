# TODO

Remaining conformance gaps against the JS Intl API, tracked in the [compatibility guide](https://hexdocs.pm/intl/compatibility.html). Split by whether the work is blocked on Localize.

## Blocked on Localize

These are logged in the Localize repository's TODO.md as feature requests:

* `minimumIntegerDigits` — needs a Localize `:minimum_integer_digits` (zero-padding) option.

* `trailingZeroDisplay` — needs a Localize `:trailing_zero_display` option (`:auto` | `:strip_if_integer`).

* `roundingPriority` — needs Localize `:rounding_priority` semantics when both fraction-digit and significant-digit bounds are given. Current behavior (significant digits win) matches the JS `"auto"` default.

* `formatToParts` / `formatRangeToParts` (all modules) — needs Localize to expose structured format parts.

* `Intl.RelativeTimeFormat` `numeric: :always` — needs Localize to support forcing numeric output instead of named forms ("yesterday").

* `Intl.supported_values_of/1` for `:collation` and `:time_zone` — needs Localize inventory functions.

## Intl-side (no upstream work required)

* `resolvedOptions` — could be built on `Localize.Number.Format.Options.validate_options/2` (public API since Localize 0.50) for NumberFormat; other modules need equivalent resolution.

* `supportedLocalesOf` — wrap `Localize.available_locale_id?/1` per module.

* `Intl.DateTimeFormat` component options now supportable by Localize: `dayPeriod` (flexible day periods since Localize 0.44), `timeZoneName` (metazone data since 0.45), `numberingSystem` (default-system handling since 0.47), `fractionalSecondDigits`, `era`, and `hour12`/`hourCycle`.

## Completed

### Script Display Names

Resolved: `Localize.Script.display_name/2` is now available and `Intl.DisplayNames` supports `type: :script`.
