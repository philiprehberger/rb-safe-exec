# frozen_string_literal: true

module Philiprehberger
  module SafeExec
    # Evaluates an AST node tree against a context hash
    class Evaluator
      # @param context [Hash] variable bindings for evaluation
      def initialize(context = {})
        @context = normalize_context(context)
      end

      # Evaluate an AST node
      #
      # @param node [Hash] the AST node
      # @return [Object] the evaluation result
      # @raise [Philiprehberger::SafeExec::Error] on evaluation errors
      def evaluate(node)
        case node[:type]
        when :literal then node[:value]
        when :identifier then resolve_identifier(node[:name])
        when :binary then evaluate_binary(node)
        when :comparison then evaluate_comparison(node)
        when :and then evaluate(node[:left]) && evaluate(node[:right])
        when :or then evaluate(node[:left]) || evaluate(node[:right])
        when :not then !evaluate(node[:operand])
        when :negate then -evaluate(node[:operand])
        when :index then evaluate_index(node)
        when :property then evaluate_property(node)
        when :ternary then evaluate_ternary(node)
        when :function_call then evaluate_function_call(node)
        else raise Error, "unknown node type: #{node[:type]}"
        end
      end

      private

      def normalize_context(context)
        context.transform_keys(&:to_s)
      end

      def resolve_identifier(name)
        raise Error, "undefined variable: #{name}" unless @context.key?(name)

        @context[name]
      end

      def evaluate_binary(node)
        left = evaluate(node[:left])
        right = evaluate(node[:right])

        case node[:op]
        when '+' then evaluate_add(left, right)
        when '-' then left - right
        when '*' then left * right
        when '/' then evaluate_divide(left, right)
        when '%' then evaluate_modulo(left, right)
        when '**' then left**right
        else raise Error, "unknown operator: #{node[:op]}"
        end
      end

      def evaluate_add(left, right)
        if left.is_a?(String) || right.is_a?(String)
          left.to_s + right.to_s
        else
          left + right
        end
      end

      def evaluate_divide(left, right)
        raise Error, 'division by zero' if right.is_a?(Numeric) && right.zero?

        if left.is_a?(Integer) && right.is_a?(Integer)
          left / right
        else
          left.to_f / right
        end
      end

      def evaluate_modulo(left, right)
        raise Error, 'division by zero' if right.is_a?(Numeric) && right.zero?

        left % right
      end

      def evaluate_ternary(node)
        condition = evaluate(node[:condition])
        condition ? evaluate(node[:consequent]) : evaluate(node[:alternate])
      end

      def evaluate_function_call(node)
        name = node[:name]
        args = node[:args].map { |arg| evaluate(arg) }

        raise Error, "unknown function: #{name}" unless SafeExec::BUILTIN_FUNCTIONS.include?(name)

        send(:"builtin_#{name}", args)
      end

      def builtin_min(args)
        raise Error, 'min() requires exactly 2 arguments' unless args.length == 2

        args.min
      end

      def builtin_max(args)
        raise Error, 'max() requires exactly 2 arguments' unless args.length == 2

        args.max
      end

      def builtin_abs(args)
        raise Error, 'abs() requires exactly 1 argument' unless args.length == 1

        args[0].abs
      end

      def builtin_length(args)
        raise Error, 'length() requires exactly 1 argument' unless args.length == 1

        value = args[0]
        raise Error, "length() expects a string or array, got #{value.class}" unless value.is_a?(String) || value.is_a?(Array)

        value.length
      end

      def builtin_round(args)
        raise Error, 'round() requires 1 or 2 arguments' unless [1, 2].include?(args.length)

        precision = args.length == 2 ? args[1] : 0
        args[0].round(precision)
      end

      def builtin_sqrt(args)
        raise Error, 'sqrt() requires exactly 1 argument' unless args.length == 1

        Math.sqrt(args[0])
      end

      def builtin_ceil(args)
        raise Error, 'ceil() requires exactly 1 argument' unless args.length == 1

        args[0].ceil
      end

      def builtin_floor(args)
        raise Error, 'floor() requires exactly 1 argument' unless args.length == 1

        args[0].floor
      end

      def builtin_pow(args)
        raise Error, 'pow() requires exactly 2 arguments' unless args.length == 2

        args[0]**args[1]
      end

      def builtin_upcase(args)
        raise Error, 'upcase() requires exactly 1 argument' unless args.length == 1
        raise Error, "upcase() expects a string, got #{args[0].class}" unless args[0].is_a?(String)

        args[0].upcase
      end

      def builtin_downcase(args)
        raise Error, 'downcase() requires exactly 1 argument' unless args.length == 1
        raise Error, "downcase() expects a string, got #{args[0].class}" unless args[0].is_a?(String)

        args[0].downcase
      end

      def builtin_trim(args)
        raise Error, 'trim() requires exactly 1 argument' unless args.length == 1
        raise Error, "trim() expects a string, got #{args[0].class}" unless args[0].is_a?(String)

        args[0].strip
      end

      def evaluate_comparison(node)
        left = evaluate(node[:left])
        right = evaluate(node[:right])

        case node[:op]
        when '==' then left == right
        when '!=' then left != right
        when '>' then left > right
        when '<' then left < right
        when '>=' then left >= right
        when '<=' then left <= right
        else raise Error, "unknown comparison: #{node[:op]}"
        end
      end

      def evaluate_index(node)
        object = evaluate(node[:object])
        key = evaluate(node[:key])

        case object
        when Array
          raise Error, "array index must be an integer, got #{key.class}" unless key.is_a?(Integer)

          object[key]
        when Hash
          object[key] || object[key.to_s] || object[key.to_sym]
        else
          raise Error, "cannot index into #{object.class}"
        end
      end

      def evaluate_property(node)
        object = evaluate(node[:object])
        name = node[:name]

        case object
        when Hash
          object[name] || object[name.to_s] || object[name.to_sym]
        else
          raise Error, "cannot access property '#{name}' on #{object.class}"
        end
      end
    end
  end
end
