# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::SafeExec do
  it 'has a version number' do
    expect(Philiprehberger::SafeExec::VERSION).not_to be_nil
  end

  describe '.evaluate' do
    context 'with arithmetic' do
      it 'evaluates addition' do
        expect(described_class.evaluate('2 + 3')).to eq(5)
      end

      it 'evaluates subtraction' do
        expect(described_class.evaluate('10 - 4')).to eq(6)
      end

      it 'evaluates multiplication' do
        expect(described_class.evaluate('3 * 7')).to eq(21)
      end

      it 'evaluates integer division' do
        expect(described_class.evaluate('10 / 3')).to eq(3)
      end

      it 'evaluates float division' do
        expect(described_class.evaluate('10.0 / 3.0')).to be_within(0.01).of(3.33)
      end

      it 'respects operator precedence' do
        expect(described_class.evaluate('2 + 3 * 4')).to eq(14)
      end

      it 'handles parentheses' do
        expect(described_class.evaluate('(2 + 3) * 4')).to eq(20)
      end

      it 'handles negation' do
        expect(described_class.evaluate('-5 + 3')).to eq(-2)
      end

      it 'raises on division by zero' do
        expect do
          described_class.evaluate('10 / 0')
        end.to raise_error(Philiprehberger::SafeExec::Error, /division by zero/)
      end
    end

    context 'with comparisons' do
      it 'evaluates equality' do
        expect(described_class.evaluate('5 == 5')).to be true
        expect(described_class.evaluate('5 == 6')).to be false
      end

      it 'evaluates inequality' do
        expect(described_class.evaluate('5 != 6')).to be true
        expect(described_class.evaluate('5 != 5')).to be false
      end

      it 'evaluates greater than' do
        expect(described_class.evaluate('5 > 3')).to be true
        expect(described_class.evaluate('3 > 5')).to be false
      end

      it 'evaluates less than' do
        expect(described_class.evaluate('3 < 5')).to be true
        expect(described_class.evaluate('5 < 3')).to be false
      end

      it 'evaluates greater than or equal' do
        expect(described_class.evaluate('5 >= 5')).to be true
        expect(described_class.evaluate('4 >= 5')).to be false
      end

      it 'evaluates less than or equal' do
        expect(described_class.evaluate('5 <= 5')).to be true
        expect(described_class.evaluate('6 <= 5')).to be false
      end
    end

    context 'with boolean operators' do
      it 'evaluates logical and' do
        expect(described_class.evaluate('true && true')).to be true
        expect(described_class.evaluate('true && false')).to be false
      end

      it 'evaluates logical or' do
        expect(described_class.evaluate('false || true')).to be true
        expect(described_class.evaluate('false || false')).to be false
      end

      it 'evaluates logical not' do
        expect(described_class.evaluate('!true')).to be false
        expect(described_class.evaluate('!false')).to be true
      end

      it 'handles complex boolean expressions' do
        expect(described_class.evaluate('(5 > 3) && (2 < 4)')).to be true
        expect(described_class.evaluate('(5 > 3) && (2 > 4)')).to be false
      end
    end

    context 'with strings' do
      it 'evaluates string literals with single quotes' do
        expect(described_class.evaluate("'hello'")).to eq('hello')
      end

      it 'evaluates string literals with double quotes' do
        expect(described_class.evaluate('"hello"')).to eq('hello')
      end

      it 'concatenates strings' do
        expect(described_class.evaluate("'hello' + ' ' + 'world'")).to eq('hello world')
      end

      it 'compares strings' do
        expect(described_class.evaluate("'abc' == 'abc'")).to be true
        expect(described_class.evaluate("'abc' != 'def'")).to be true
      end
    end

    context 'with context variables' do
      it 'resolves variables from context' do
        expect(described_class.evaluate('x + y', { x: 10, y: 20 })).to eq(30)
      end

      it 'raises for undefined variables' do
        expect do
          described_class.evaluate('unknown')
        end.to raise_error(Philiprehberger::SafeExec::Error, /undefined variable/)
      end

      it 'handles string keys in context' do
        expect(described_class.evaluate('name', { 'name' => 'Alice' })).to eq('Alice')
      end
    end

    context 'with hash and array access' do
      it 'accesses array elements by index' do
        expect(described_class.evaluate('items[0]', { items: [10, 20, 30] })).to eq(10)
        expect(described_class.evaluate('items[2]', { items: [10, 20, 30] })).to eq(30)
      end

      it 'accesses hash values by string key' do
        expect(described_class.evaluate("user['name']", { user: { 'name' => 'Alice' } })).to eq('Alice')
      end

      it 'accesses hash values via dot notation' do
        expect(described_class.evaluate('user.name', { user: { 'name' => 'Alice' } })).to eq('Alice')
      end

      it 'handles nested access' do
        context = { data: { 'users' => [{ 'name' => 'Alice' }, { 'name' => 'Bob' }] } }
        expect(described_class.evaluate("data['users'][1]['name']", context)).to eq('Bob')
      end
    end

    context 'with nil values' do
      it 'handles nil literals' do
        expect(described_class.evaluate('nil')).to be_nil
      end

      it 'compares with nil' do
        expect(described_class.evaluate('nil == nil')).to be true
        expect(described_class.evaluate('5 == nil')).to be false
      end
    end

    context 'with complex expressions' do
      it 'evaluates multi-part expressions' do
        context = { price: 100, discount: 0.2, tax: 0.08 }
        result = described_class.evaluate('price * (1 - discount) * (1 + tax)', context)
        expect(result).to be_within(0.01).of(86.4)
      end

      it 'evaluates conditional-style expressions' do
        context = { age: 25 }
        expect(described_class.evaluate('age >= 18 && age < 65', context)).to be true
      end
    end

    context 'with parse errors' do
      it 'raises on invalid syntax' do
        expect { described_class.evaluate('2 +') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on unexpected characters' do
        expect { described_class.evaluate('2 @ 3') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on unmatched opening parenthesis' do
        expect { described_class.evaluate('(2 + 3') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on unmatched closing parenthesis' do
        expect { described_class.evaluate('2 + 3)') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on consecutive operators' do
        expect { described_class.evaluate('2 + + 3') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on empty parentheses' do
        expect { described_class.evaluate('()') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on trailing operator' do
        expect { described_class.evaluate('5 *') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on unmatched bracket' do
        expect { described_class.evaluate('items[0', { items: [1] }) }.to raise_error(Philiprehberger::SafeExec::Error)
      end
    end

    context 'with empty and whitespace expressions' do
      it 'raises on empty string' do
        expect { described_class.evaluate('') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on whitespace-only string' do
        expect { described_class.evaluate('   ') }.to raise_error(Philiprehberger::SafeExec::Error)
      end
    end

    context 'with negation edge cases' do
      it 'handles double negation of boolean' do
        expect(described_class.evaluate('!!true')).to be true
      end

      it 'handles negation of numeric value' do
        expect(described_class.evaluate('-(-5)')).to eq(5)
      end

      it 'negates a variable from context' do
        expect(described_class.evaluate('-x', { x: 10 })).to eq(-10)
      end

      it 'handles not on comparison result' do
        expect(described_class.evaluate('!(5 > 3)')).to be false
      end
    end

    context 'with division edge cases' do
      it 'raises on division by zero with float numerator' do
        expect do
          described_class.evaluate('10.0 / 0')
        end.to raise_error(Philiprehberger::SafeExec::Error, /division by zero/)
      end

      it 'raises on division by zero with float zero' do
        expect do
          described_class.evaluate('10 / 0.0')
        end.to raise_error(Philiprehberger::SafeExec::Error, /division by zero/)
      end

      it 'performs integer division truncation' do
        expect(described_class.evaluate('7 / 2')).to eq(3)
      end

      it 'performs float division when one operand is float' do
        expect(described_class.evaluate('7.0 / 2')).to be_within(0.01).of(3.5)
      end
    end

    context 'with string edge cases' do
      it 'handles empty string literal' do
        expect(described_class.evaluate("''")).to eq('')
      end

      it 'concatenates string with number' do
        expect(described_class.evaluate("'count: ' + 5")).to eq('count: 5')
      end

      it 'concatenates number with string' do
        expect(described_class.evaluate("5 + ' items'")).to eq('5 items')
      end

      it 'compares different strings as not equal' do
        expect(described_class.evaluate("'hello' == 'world'")).to be false
      end

      it 'handles string with spaces' do
        expect(described_class.evaluate("'hello world'")).to eq('hello world')
      end
    end

    context 'with nil edge cases' do
      it 'evaluates nil != non-nil as true' do
        expect(described_class.evaluate('nil != 0')).to be true
      end

      it 'evaluates non-nil != nil as true' do
        expect(described_class.evaluate('5 != nil')).to be true
      end

      it 'resolves a context variable set to nil' do
        expect(described_class.evaluate('x == nil', { x: nil })).to be true
      end
    end

    context 'with boolean literal edge cases' do
      it 'evaluates true literal' do
        expect(described_class.evaluate('true')).to be true
      end

      it 'evaluates false literal' do
        expect(described_class.evaluate('false')).to be false
      end

      it 'short-circuits logical or' do
        expect(described_class.evaluate('true || false')).to be true
      end

      it 'short-circuits logical and' do
        expect(described_class.evaluate('false && true')).to be false
      end

      it 'chains multiple or operators' do
        expect(described_class.evaluate('false || false || true')).to be true
      end

      it 'chains multiple and operators' do
        expect(described_class.evaluate('true && true && false')).to be false
      end
    end

    context 'with deeply nested access' do
      it 'accesses deeply nested hash via dot notation' do
        ctx = { a: { 'b' => { 'c' => 42 } } }
        expect(described_class.evaluate('a.b.c', ctx)).to eq(42)
      end

      it 'accesses deeply nested array elements' do
        ctx = { matrix: [[1, 2], [3, 4]] }
        expect(described_class.evaluate('matrix[1][0]', ctx)).to eq(3)
      end

      it 'accesses array element property' do
        ctx = { users: [{ 'name' => 'Alice' }, { 'name' => 'Bob' }] }
        expect(described_class.evaluate('users[0].name', ctx)).to eq('Alice')
      end

      it 'returns nil for missing hash key' do
        ctx = { obj: { 'a' => 1 } }
        expect(described_class.evaluate("obj['missing']", ctx)).to be_nil
      end

      it 'returns nil for out-of-bounds array index' do
        ctx = { items: [10, 20] }
        expect(described_class.evaluate('items[5]', ctx)).to be_nil
      end

      it 'raises when indexing a non-indexable type' do
        expect do
          described_class.evaluate('x[0]', { x: 42 })
        end.to raise_error(Philiprehberger::SafeExec::Error, /cannot index/)
      end

      it 'raises when accessing property on non-hash' do
        expect do
          described_class.evaluate('x.name',
                                   { x: 42 })
        end.to raise_error(Philiprehberger::SafeExec::Error, /cannot access property/)
      end

      it 'raises when array index is not an integer' do
        ctx = { items: [1, 2, 3] }
        expect do
          described_class.evaluate("items['key']",
                                   ctx)
        end.to raise_error(Philiprehberger::SafeExec::Error, /array index must be an integer/)
      end
    end

    context 'with negative array indices' do
      it 'accesses last element with negative index' do
        ctx = { items: [10, 20, 30] }
        expect(described_class.evaluate('items[-1]', ctx)).to eq(30)
      end
    end

    context 'with context variable edge cases' do
      it 'handles symbol and string keys interchangeably' do
        expect(described_class.evaluate('x', { 'x' => 100 })).to eq(100)
        expect(described_class.evaluate('x', { x: 100 })).to eq(100)
      end

      it 'resolves boolean context variables' do
        expect(described_class.evaluate('active', { active: true })).to be true
      end

      it 'resolves array context variable' do
        ctx = { nums: [1, 2, 3] }
        expect(described_class.evaluate('nums[2]', ctx)).to eq(3)
      end
    end

    context 'with complex arithmetic expressions' do
      it 'handles multiple levels of nested parentheses' do
        expect(described_class.evaluate('((2 + 3) * (4 - 1))')).to eq(15)
      end

      it 'handles subtraction with negative result' do
        expect(described_class.evaluate('3 - 10')).to eq(-7)
      end

      it 'handles multiplication by zero' do
        expect(described_class.evaluate('999 * 0')).to eq(0)
      end

      it 'handles chained additions' do
        expect(described_class.evaluate('1 + 2 + 3 + 4 + 5')).to eq(15)
      end

      it 'handles mixed operations with floats and integers' do
        expect(described_class.evaluate('2 * 3.5 + 1')).to be_within(0.01).of(8.0)
      end
    end

    context 'with comparison chaining' do
      it 'evaluates equality between strings from context' do
        ctx = { role: 'admin' }
        expect(described_class.evaluate("role == 'admin'", ctx)).to be true
      end

      it 'evaluates inequality between variables' do
        ctx = { a: 5, b: 10 }
        expect(described_class.evaluate('a != b', ctx)).to be true
      end

      it 'combines comparisons with boolean operators' do
        ctx = { x: 15 }
        expect(described_class.evaluate('x > 10 && x < 20', ctx)).to be true
        expect(described_class.evaluate('x > 10 && x < 12', ctx)).to be false
      end

      it 'combines comparisons with or' do
        ctx = { status: 'active' }
        expect(described_class.evaluate("status == 'active' || status == 'pending'", ctx)).to be true
      end
    end

    context 'with timeout' do
      it 'accepts a custom timeout' do
        expect(described_class.evaluate('1 + 1', {}, timeout: 1)).to eq(2)
      end
    end

    context 'with error class hierarchy' do
      it 'Error is a subclass of StandardError' do
        expect(Philiprehberger::SafeExec::Error.superclass).to eq(StandardError)
      end

      it 'TimeoutError is a subclass of Error' do
        expect(Philiprehberger::SafeExec::TimeoutError.superclass).to eq(Philiprehberger::SafeExec::Error)
      end
    end

    context 'with DEFAULT_TIMEOUT constant' do
      it 'has a default timeout of 5 seconds' do
        expect(Philiprehberger::SafeExec::DEFAULT_TIMEOUT).to eq(5)
      end
    end

    context 'with negative number literals' do
      it 'parses negative integer literal' do
        expect(described_class.evaluate('-42')).to eq(-42)
      end

      it 'parses negative float literal' do
        expect(described_class.evaluate('-3.14')).to be_within(0.001).of(-3.14)
      end
    end

    context 'with hash access via symbol keys in context' do
      it 'accesses hash with symbol keys via bracket string lookup' do
        ctx = { config: { enabled: true } }
        expect(described_class.evaluate("config['enabled']", ctx)).to be true
      end

      it 'accesses hash with symbol keys via dot notation' do
        ctx = { config: { enabled: true } }
        expect(described_class.evaluate('config.enabled', ctx)).to be true
      end

      it 'returns nil for missing key via dot notation' do
        ctx = { config: { 'a' => 1 } }
        expect(described_class.evaluate('config.missing', ctx)).to be_nil
      end
    end

    context 'with truthy and falsy values in boolean operators' do
      it 'treats nil as falsy in logical and' do
        expect(described_class.evaluate('x && true', { x: nil })).to be_nil
      end

      it 'treats nil as falsy in logical or' do
        expect(described_class.evaluate('x || 42', { x: nil })).to eq(42)
      end

      it 'treats zero as truthy in logical and' do
        expect(described_class.evaluate('x && true', { x: 0 })).to be true
      end

      it 'treats empty string as truthy in logical and' do
        expect(described_class.evaluate("x && 'yes'", { x: '' })).to eq('yes')
      end

      it 'returns first truthy value in logical or' do
        expect(described_class.evaluate('x || y', { x: 10, y: 20 })).to eq(10)
      end

      it 'returns last falsy value in chained and with nil' do
        expect(described_class.evaluate('x && y && z', { x: true, y: nil, z: true })).to be_nil
      end
    end

    context 'with deeply nested mixed access patterns' do
      it 'accesses array inside hash inside array via mixed notation' do
        ctx = { data: [{ 'tags' => %w[ruby gem] }] }
        expect(described_class.evaluate("data[0]['tags'][1]", ctx)).to eq('gem')
      end

      it 'accesses three levels of dot notation' do
        ctx = { a: { 'b' => { 'c' => { 'd' => 99 } } } }
        expect(described_class.evaluate('a.b.c.d', ctx)).to eq(99)
      end

      it 'combines dot notation and bracket notation in chain' do
        ctx = { users: { 'list' => [{ 'name' => 'Eve' }] } }
        expect(described_class.evaluate("users.list[0]['name']", ctx)).to eq('Eve')
      end
    end

    context 'with additional arithmetic edge cases' do
      it 'evaluates subtraction of two negative numbers' do
        expect(described_class.evaluate('-3 - -2')).to eq(-1)
      end

      it 'evaluates multiplication of negative numbers' do
        expect(described_class.evaluate('-3 * -4')).to eq(12)
      end

      it 'evaluates division of negative by positive' do
        expect(described_class.evaluate('-10 / 2')).to eq(-5)
      end

      it 'evaluates a long chain of mixed operations' do
        expect(described_class.evaluate('1 + 2 * 3 - 4 / 2')).to eq(5)
      end

      it 'handles float literal without leading digit before dot' do
        expect(described_class.evaluate('0.5 + 0.5')).to be_within(0.001).of(1.0)
      end
    end

    context 'with additional parse error edge cases' do
      it 'raises on expression starting with a binary operator' do
        expect { described_class.evaluate('* 5') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on expression with only an operator' do
        expect { described_class.evaluate('+') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on mismatched bracket types' do
        expect { described_class.evaluate('items[0)', { items: [1] }) }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on expression with dangling dot' do
        expect { described_class.evaluate('x.', { x: { 'a' => 1 } }) }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on two adjacent number literals' do
        expect { described_class.evaluate('5 5') }.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'raises on incomplete boolean expression' do
        expect { described_class.evaluate('true &&') }.to raise_error(Philiprehberger::SafeExec::Error)
      end
    end

    context 'with string and comparison combinations' do
      it 'evaluates double-quoted string equality' do
        expect(described_class.evaluate('"abc" == "abc"')).to be true
      end

      it 'evaluates mixed-quote string equality' do
        expect(described_class.evaluate(%q("hello" == 'hello'))).to be true
      end

      it 'evaluates string inequality' do
        expect(described_class.evaluate("'foo' != 'bar'")).to be true
      end

      it 'concatenates empty string with non-empty' do
        expect(described_class.evaluate("'' + 'hello'")).to eq('hello')
      end

      it 'concatenates string with boolean via context' do
        expect(described_class.evaluate("'active: ' + x", { x: true })).to eq('active: true')
      end
    end

    context 'with parenthesized expressions' do
      it 'evaluates a single parenthesized literal' do
        expect(described_class.evaluate('(42)')).to eq(42)
      end

      it 'evaluates deeply nested parentheses around a literal' do
        expect(described_class.evaluate('(((10)))')).to eq(10)
      end

      it 'evaluates parenthesized boolean expression' do
        expect(described_class.evaluate('(true || false) && (false || true)')).to be true
      end
    end

    context 'with negation and not combined' do
      it 'handles not applied to equality' do
        expect(described_class.evaluate('!(1 == 2)')).to be true
      end

      it 'handles double not' do
        expect(described_class.evaluate('!!false')).to be false
      end

      it 'handles negation of parenthesized arithmetic' do
        expect(described_class.evaluate('-(2 + 3)')).to eq(-5)
      end

      it 'handles not combined with and/or' do
        expect(described_class.evaluate('!false && !false')).to be true
        expect(described_class.evaluate('!true || !true')).to be false
      end
    end

    context 'with context variable used in complex expressions' do
      it 'uses variables in nested arithmetic with comparisons' do
        ctx = { a: 3, b: 4, c: 5 }
        expect(described_class.evaluate('a * a + b * b == c * c', ctx)).to be true
      end

      it 'evaluates ternary-style pattern with boolean operators' do
        ctx = { flag: true, val: 42 }
        expect(described_class.evaluate('flag && val', ctx)).to eq(42)
        expect(described_class.evaluate('!flag && val', ctx)).to be false
      end

      it 'handles context with many variables' do
        ctx = { a: 1, b: 2, c: 3, d: 4, e: 5 }
        expect(described_class.evaluate('a + b + c + d + e', ctx)).to eq(15)
      end
    end

    context 'with negative array indices' do
      it 'accesses second-to-last element' do
        ctx = { items: [10, 20, 30, 40] }
        expect(described_class.evaluate('items[-2]', ctx)).to eq(30)
      end

      it 'accesses first element via negative index equal to length' do
        ctx = { items: [10, 20, 30] }
        expect(described_class.evaluate('items[-3]', ctx)).to eq(10)
      end

      it 'returns nil for negative index beyond array bounds' do
        ctx = { items: [10, 20] }
        expect(described_class.evaluate('items[-5]', ctx)).to be_nil
      end
    end

    context 'with whitespace variations' do
      it 'evaluates expression with extra spaces' do
        expect(described_class.evaluate('  2   +   3  ')).to eq(5)
      end

      it 'evaluates expression with tab characters' do
        expect(described_class.evaluate("2\t+\t3")).to eq(5)
      end

      it 'evaluates expression with no spaces between tokens' do
        expect(described_class.evaluate('2+3')).to eq(5)
      end
    end

    context 'with ternary operator' do
      it 'returns consequent when condition is true' do
        expect(described_class.evaluate('true ? 1 : 2')).to eq(1)
      end

      it 'returns alternate when condition is false' do
        expect(described_class.evaluate('false ? 1 : 2')).to eq(2)
      end

      it 'handles nested ternary expressions' do
        expect(described_class.evaluate('true ? false ? 1 : 2 : 3')).to eq(2)
      end

      it 'works with comparison conditions' do
        expect(described_class.evaluate('5 > 3 ? 10 : 20')).to eq(10)
        expect(described_class.evaluate('5 < 3 ? 10 : 20')).to eq(20)
      end

      it 'works with context variables' do
        ctx = { age: 25 }
        expect(described_class.evaluate("age >= 18 ? 'adult' : 'minor'", ctx)).to eq('adult')
      end
    end

    context 'with modulo operator' do
      it 'evaluates basic modulo' do
        expect(described_class.evaluate('10 % 3')).to eq(1)
      end

      it 'evaluates modulo with negative numbers' do
        expect(described_class.evaluate('-7 % 3')).to eq(2)
      end

      it 'raises on modulo division by zero' do
        expect do
          described_class.evaluate('10 % 0')
        end.to raise_error(Philiprehberger::SafeExec::Error, /division by zero/)
      end

      it 'evaluates modulo with floats' do
        expect(described_class.evaluate('10.5 % 3')).to be_within(0.01).of(1.5)
      end
    end

    context 'with built-in functions' do
      it 'evaluates min()' do
        expect(described_class.evaluate('min(3, 7)')).to eq(3)
        expect(described_class.evaluate('min(10, 2)')).to eq(2)
      end

      it 'evaluates max()' do
        expect(described_class.evaluate('max(3, 7)')).to eq(7)
        expect(described_class.evaluate('max(10, 2)')).to eq(10)
      end

      it 'evaluates abs()' do
        expect(described_class.evaluate('abs(-5)')).to eq(5)
        expect(described_class.evaluate('abs(5)')).to eq(5)
      end

      it 'evaluates length() with a string' do
        expect(described_class.evaluate("length('hello')")).to eq(5)
      end

      it 'evaluates length() with an array' do
        ctx = { items: [1, 2, 3, 4] }
        expect(described_class.evaluate('length(items)', ctx)).to eq(4)
      end

      it 'evaluates round() without precision' do
        expect(described_class.evaluate('round(3.7)')).to eq(4)
      end

      it 'evaluates round() with precision' do
        expect(described_class.evaluate('round(3.14159, 2)')).to be_within(0.001).of(3.14)
      end

      it 'raises for unknown function name' do
        expect do
          described_class.evaluate('unknown(1)')
        end.to raise_error(Philiprehberger::SafeExec::Error)
      end

      it 'uses functions in larger expressions' do
        expect(described_class.evaluate('max(2, 5) + min(1, 3)')).to eq(6)
      end
    end

    context 'with string concatenation' do
      it 'concatenates two string literals' do
        expect(described_class.evaluate("'hello' + ' world'")).to eq('hello world')
      end

      it 'concatenates context variables with strings' do
        ctx = { name: 'Alice' }
        expect(described_class.evaluate("'Hello, ' + name", ctx)).to eq('Hello, Alice')
      end
    end

    context 'with exponentiation operator' do
      it 'evaluates basic exponentiation' do
        expect(described_class.evaluate('2 ** 3')).to eq(8)
      end

      it 'evaluates float exponentiation' do
        expect(described_class.evaluate('4.0 ** 0.5')).to eq(2.0)
      end

      it 'evaluates right-associative exponentiation' do
        expect(described_class.evaluate('2 ** 3 ** 2')).to eq(512)
      end

      it 'gives exponentiation higher precedence than multiplication' do
        expect(described_class.evaluate('2 * 3 ** 2')).to eq(18)
      end

      it 'evaluates exponentiation with parentheses' do
        expect(described_class.evaluate('(2 * 3) ** 2')).to eq(36)
      end

      it 'evaluates negative exponent' do
        expect(described_class.evaluate('2 ** -1')).to eq(0.5)
      end

      it 'evaluates zero exponent' do
        expect(described_class.evaluate('5 ** 0')).to eq(1)
      end

      it 'evaluates exponentiation with context variables' do
        expect(described_class.evaluate('base ** exp', { base: 3, exp: 4 })).to eq(81)
      end
    end

    context 'with math built-in functions' do
      it 'evaluates sqrt()' do
        expect(described_class.evaluate('sqrt(16)')).to eq(4.0)
      end

      it 'evaluates sqrt() with float' do
        expect(described_class.evaluate('sqrt(2.0)')).to be_within(0.0001).of(1.4142)
      end

      it 'evaluates ceil()' do
        expect(described_class.evaluate('ceil(3.2)')).to eq(4)
      end

      it 'evaluates ceil() with negative number' do
        expect(described_class.evaluate('ceil(-3.7)')).to eq(-3)
      end

      it 'evaluates floor()' do
        expect(described_class.evaluate('floor(3.9)')).to eq(3)
      end

      it 'evaluates floor() with negative number' do
        expect(described_class.evaluate('floor(-3.2)')).to eq(-4)
      end

      it 'evaluates pow()' do
        expect(described_class.evaluate('pow(2, 10)')).to eq(1024)
      end

      it 'evaluates pow() with float exponent' do
        expect(described_class.evaluate('pow(9, 0.5)')).to eq(3.0)
      end

      it 'uses math functions in expressions' do
        expect(described_class.evaluate('sqrt(16) + ceil(2.1)')).to eq(7.0)
      end

      it 'raises for sqrt() with wrong arity' do
        expect do
          described_class.evaluate('sqrt(1, 2)')
        end.to raise_error(Philiprehberger::SafeExec::Error, /sqrt\(\) requires exactly 1 argument/)
      end

      it 'raises for pow() with wrong arity' do
        expect do
          described_class.evaluate('pow(2)')
        end.to raise_error(Philiprehberger::SafeExec::Error, /pow\(\) requires exactly 2 arguments/)
      end
    end

    context 'with string built-in functions' do
      it 'evaluates upcase()' do
        expect(described_class.evaluate("upcase('hello')")).to eq('HELLO')
      end

      it 'evaluates downcase()' do
        expect(described_class.evaluate("downcase('HELLO')")).to eq('hello')
      end

      it 'evaluates trim()' do
        expect(described_class.evaluate("trim('  hello  ')")).to eq('hello')
      end

      it 'evaluates trim() with tabs and newlines' do
        ctx = { text: "\t hello \n" }
        expect(described_class.evaluate('trim(text)', ctx)).to eq('hello')
      end

      it 'evaluates upcase() with context variable' do
        expect(described_class.evaluate('upcase(name)', { name: 'alice' })).to eq('ALICE')
      end

      it 'chains string functions with concatenation' do
        expect(described_class.evaluate("upcase('hello') + ' ' + downcase('WORLD')")).to eq('HELLO world')
      end

      it 'raises for upcase() with non-string' do
        expect do
          described_class.evaluate('upcase(42)')
        end.to raise_error(Philiprehberger::SafeExec::Error, /upcase\(\) expects a string/)
      end

      it 'raises for downcase() with non-string' do
        expect do
          described_class.evaluate('downcase(true)')
        end.to raise_error(Philiprehberger::SafeExec::Error, /downcase\(\) expects a string/)
      end

      it 'raises for trim() with non-string' do
        expect do
          described_class.evaluate('trim(123)')
        end.to raise_error(Philiprehberger::SafeExec::Error, /trim\(\) expects a string/)
      end
    end
  end
end
