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

    BUILTIN_FUNCTIONS = %w[min max abs length round sqrt ceil floor pow upcase downcase trim].freeze

    # Evaluate a sandboxed expression with an optional context
    #
    # @param expr [String] the expression to evaluate
    # @param context [Hash] variable bindings
    # @param timeout [Numeric] maximum evaluation time in seconds
    # @return [Object] the evaluation result
    # @raise [Error] on parse or evaluation errors
    # @raise [TimeoutError] if evaluation exceeds the timeout
    def self.evaluate(expr, context = {}, timeout: DEFAULT_TIMEOUT)
      compile(expr).evaluate(context, timeout: timeout)
    end

    # Pre-parse an expression so it can be evaluated repeatedly against
    # different contexts without re-tokenizing or re-parsing.
    #
    # @param expr [String] the expression to compile
    # @return [Compiled] a reusable compiled expression
    # @raise [Error] if the expression fails to tokenize or parse
    def self.compile(expr)
      Compiled.new(expr)
    end
  end
end

require_relative 'safe_exec/compiled'
