# philiprehberger-safe_exec

[![Tests](https://github.com/philiprehberger/rb-safe-exec/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-safe-exec/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-safe_exec.svg)](https://rubygems.org/gems/philiprehberger-safe_exec)
[![License](https://img.shields.io/github/license/philiprehberger/rb-safe-exec)](LICENSE)

Sandboxed expression evaluator with whitelisted operations

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-safe_exec"
```

Or install directly:

```bash
gem install philiprehberger-safe_exec
```

## Usage

```ruby
require "philiprehberger/safe_exec"

Philiprehberger::SafeExec.evaluate('2 + 3 * 4')           # => 14
Philiprehberger::SafeExec.evaluate('(2 + 3) * 4')         # => 20
Philiprehberger::SafeExec.evaluate('price * 1.08', { price: 100 })  # => 108.0
```

### Arithmetic

```ruby
Philiprehberger::SafeExec.evaluate('10 + 5')   # => 15
Philiprehberger::SafeExec.evaluate('10 - 5')   # => 5
Philiprehberger::SafeExec.evaluate('10 * 5')   # => 50
Philiprehberger::SafeExec.evaluate('10 / 3')   # => 3 (integer division)
Philiprehberger::SafeExec.evaluate('10.0 / 3') # => 3.333...
```

### Comparisons and Booleans

```ruby
Philiprehberger::SafeExec.evaluate('5 > 3')              # => true
Philiprehberger::SafeExec.evaluate('5 == 5')              # => true
Philiprehberger::SafeExec.evaluate('true && false')       # => false
Philiprehberger::SafeExec.evaluate('!false || true')      # => true
Philiprehberger::SafeExec.evaluate('age >= 18 && age < 65', { age: 25 })  # => true
```

### String Operations

```ruby
Philiprehberger::SafeExec.evaluate("'hello' + ' ' + 'world'")  # => "hello world"
Philiprehberger::SafeExec.evaluate("name == 'Alice'", { name: 'Alice' })  # => true
```

### Hash and Array Access

```ruby
context = { items: [10, 20, 30], user: { 'name' => 'Alice', 'role' => 'admin' } }

Philiprehberger::SafeExec.evaluate('items[0]', context)        # => 10
Philiprehberger::SafeExec.evaluate("user['name']", context)    # => "Alice"
Philiprehberger::SafeExec.evaluate('user.role', context)       # => "admin"
```

### Timeout

```ruby
Philiprehberger::SafeExec.evaluate('1 + 1', {}, timeout: 2)
# Raises Philiprehberger::SafeExec::TimeoutError if evaluation exceeds 2 seconds
```

## API

| Method | Description |
|--------|-------------|
| `SafeExec.evaluate(expr, context, timeout:)` | Evaluate an expression with context variables and optional timeout |

### Supported Operations

| Category | Operations |
|----------|-----------|
| Arithmetic | `+`, `-`, `*`, `/` |
| Comparison | `==`, `!=`, `>`, `<`, `>=`, `<=` |
| Boolean | `&&`, `\|\|`, `!` |
| String | concatenation via `+`, comparison |
| Access | `array[index]`, `hash['key']`, `hash.key` |
| Literals | integers, floats, strings, booleans, nil |
| Grouping | parentheses `()` |

## Development

```bash
bundle install
bundle exec rspec      # Run tests
bundle exec rubocop    # Check code style
```

## License

MIT
