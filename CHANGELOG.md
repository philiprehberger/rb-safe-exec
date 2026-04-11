# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-04-10

### Added
- Exponentiation operator: `**` (right-associative, higher precedence than `*`/`/`)
- Math functions: `sqrt(n)`, `ceil(n)`, `floor(n)`, `pow(base, exp)`
- String functions: `upcase(str)`, `downcase(str)`, `trim(str)`

### Changed
- Consolidate `BUILTIN_FUNCTIONS` into a single module-level constant

## [0.2.0] - 2026-04-03

### Added
- Ternary operator: `condition ? value_if_true : value_if_false`
- Modulo operator: `%`
- Built-in functions: `min(a, b)`, `max(a, b)`, `abs(n)`, `length(str_or_arr)`, `round(n, precision)`

## [0.1.7] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.6] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.5] - 2026-03-26

### Fixed
- Add Sponsor badge to README
- Fix license section link format

## [0.1.4] - 2026-03-24

### Changed
- Expand test coverage to 50+ examples covering edge cases and error paths

## [0.1.3] - 2026-03-24

### Changed
- Expand README API table to document all public methods

## [0.1.2] - 2026-03-24

### Fixed
- Remove inline comments from Development section to match template

## [0.1.1] - 2026-03-22

### Changed
- Version bump for republishing

## [0.1.0] - 2026-03-22

### Added
- Initial release
- Arithmetic operations: addition, subtraction, multiplication, division
- Comparison operators: ==, !=, >, <, >=, <=
- Boolean operators: &&, ||, !
- String concatenation via + operator
- Hash and array access via bracket notation and dot notation
- Context variable bindings
- Timeout support for runaway expressions
- Custom tokenizer and recursive descent parser (no eval, send, or method_missing)
