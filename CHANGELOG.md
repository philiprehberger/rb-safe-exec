# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
