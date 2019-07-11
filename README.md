# Cron for Swift

[![TravisCI](http://img.shields.io/travis/Ponyboy47/Cron-Swift.svg?style=flat)](https://travis-ci.org/Ponyboy47/Cron-Swift)

## Installation

### Swift Package Manager

Add the following line to your `Package.swift` file
```swift
.package(url: "https://github.com/Ponyboy47/Cron-Swift.git", from: "2.3.0")
```

## Usage

```swift
import Cron

let job = try? CronJob(pattern: "*/10 * * * * *") { () -> Void in
    print("job executes every 10 seconds")
}
```

## Cron Pattern Syntax

5 - 7 fields separated by TAB or whitespace:


| Field name | Range         | Special Characters         | Remarks       |
|------------|---------------|----------------------------|---------------|
|second      |0-59           | `*` `/` `,` `-` `H`        |               |
|minute      |0-59           | `*` `/` `,` `-` `H`        |               |
|hour        |0-23           | `*` `/` `,` `-` `H` `L` `W`|               |
|day of month|1-31           | `*` `/` `,` `-` `H`        |               |
|month       |1-12 or JAN-DEC| `*` `/` `,` `-`            |               |
|day of week |0-7 or SUN-SAT | `*` `/` `,` `-` `L` `#`    | 0 or 7 is SUN |
|year        | -             | `*` `/` `,` `-`            |               |

The reference documentation for this implementation is found at [Wikipedia](https://en.wikipedia.org/wiki/Cron#CRON_expression).

## Special Characters

### Asterisk (`*`)

Asterisk means the full range in the field. For example, `*` for an `hour` entry implies `0-23`.

### Slash (`/`)

Slashes can be combined with ranges to specify step values.

### Comma (`,`)

Commas are used to separate items of a list.

### Hyphen (`-`)

Hyphens are used for ranges.

Ranges are two numbers separated with a hyphen. For example, `8-11` for an `hours` entry specifies execution at hours 8, 9, 10 and 11.

### Number sign (`#`)

'#' is allowed for the day-of-week field, and must be followed by a number between one and five. It allows you to specify constructs such as "the second Friday" of a given month.

### Hash (`H`)

The `H` symbol can be used like a range. For example, `H H(0-7) * * *` means some time between 0:00 AM (midnight) to 7:59 AM.

The `H` symbol can be thought of as a random value over a range, but it actually is a hash of the given value, not a random function, so that the value remains stable for it.

### Last (`L`)

When used in the day-of-week field, it allows you to specify constructs such as "the last Friday" ("5L") of a given month. In the day-of-month field, it specifies the last day of the month.

### Weekday (`W`)

This character is used to specify the weekday (Monday to Friday) nearest the given day.
