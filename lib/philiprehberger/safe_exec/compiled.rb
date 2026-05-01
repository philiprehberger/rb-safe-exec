# frozen_string_literal: true

module Philiprehberger
  module SafeExec
    # A pre-parsed expression that can be evaluated repeatedly against
    # different contexts without re-tokenizing or re-parsing.
    #
    # Returned by {Philiprehberger::SafeExec.compile}. Use this when the
    # same expression is evaluated against many contexts (e.g., rules
    # engines, calculation pipelines).
    class Compiled
      # @return [String] the original expression source
      attr_reader :source

      # @param source [String] the expression source
      # @raise [Error] if the source fails to tokenize or parse
      def initialize(source)
        @source = source
        @ast = Parser.new(Tokenizer.tokenize(source)).parse
      end

      # Evaluate against a context with optional timeout.
      #
      # @param context [Hash] variable bindings
      # @param timeout [Numeric] maximum evaluation time in seconds
      # @return [Object] the evaluation result
      # @raise [Error] on evaluation errors
      # @raise [TimeoutError] if evaluation exceeds the timeout
      def evaluate(context = {}, timeout: DEFAULT_TIMEOUT)
        result = nil
        error = nil

        thread = Thread.new do
          result = Evaluator.new(context).evaluate(@ast)
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
end
