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
| `SafeExec.evaluate(expr, context = {}, timeout: 5)` | Evaluate a sandboxed expression string with optional context variables and timeout (seconds) |
| `SafeExec::Error` | Base error class for parse and evaluation failures |
| `SafeExec::TimeoutError` | Raised when evaluation exceeds the timeout |
| `SafeExec::DEFAULT_TIMEOUT` | Default timeout in seconds (`5`) |
| `SafeExec::VERSION` | Gem version string |
| `Tokenizer.tokenize(input)` | Tokenize an expression string into an array of `Token` structs |
| `Tokenizer::Token` | Struct with `type` (Symbol) and `value` (String) fields |
| `Tokenizer::TOKEN_PATTERNS` | Ordered array of `[type, regex]` pairs used by the tokenizer |
| `Parser.new(tokens)` | Create a parser from an array of `Token` structs |
| `Parser#parse` | Parse the token stream into an AST hash |
| `Evaluator.new(context = {})` | Create an evaluator with a context hash (keys are normalized to strings) |
| `Evaluator#evaluate(node)` | Evaluate an AST node and return the result |

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
bundle exec rspec
bundle exec rubocop
```

## License

MIT
