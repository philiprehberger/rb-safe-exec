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
        expect { described_class.evaluate('10 / 0') }.to raise_error(Philiprehberger::SafeExec::Error, /division by zero/)
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
    end

    context 'with timeout' do
      it 'accepts a custom timeout' do
        expect(described_class.evaluate('1 + 1', {}, timeout: 1)).to eq(2)
      end
    end
  end
end
