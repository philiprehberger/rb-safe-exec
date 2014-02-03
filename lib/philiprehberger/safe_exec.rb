# frozen_string_literal: true

require_relative 'safe_exec/version'
require_relative 'safe_exec/tokenizer'
require_relative 'safe_exec/parser'
require_relative 'safe_exec/evaluator'

module Philiprehberger
  module SafeExec
    class Error < StandardError; end

    # Raised when evaluation exceeds the timeout
    class TimeoutError < Error; end

    DEFAULT_TIMEOUT = 5

    # Evaluate a sandboxed expression with an optional context
    #
    # @param expr [String] the expression to evaluate
    # @param context [Hash] variable bindings
    # @param timeout [Numeric] maximum evaluation time in seconds
    # @return [Object] the evaluation result
    # @raise [Error] on parse or evaluation errors
    # @raise [TimeoutError] if evaluation exceeds the timeout
    def self.evaluate(expr, context = {}, timeout: DEFAULT_TIMEOUT)
      result = nil
      error = nil

      thread = Thread.new do
        tokens = Tokenizer.tokenize(expr)
        ast = Parser.new(tokens).parse
        result = Evaluator.new(context).evaluate(ast)
      rescue Error => e
        error = e
      end

      unless thread.join(timeout)
        thread.kill
        raise TimeoutError, "expression evaluation timed out after #{timeout} seconds"
      end

      raise error if error

      result
    end
  end
end
