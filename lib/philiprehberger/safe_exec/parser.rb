# frozen_string_literal: true

module Philiprehberger
  module SafeExec
    # Recursive descent parser that builds an AST from tokens
    class Parser
      def initialize(tokens)
        @tokens = tokens
        @pos = 0
      end

      # Parse the token stream into an AST node
      #
      # @return [Hash] the AST node
      # @raise [Philiprehberger::SafeExec::Error] on parse errors
      def parse
        node = parse_or
        raise Error, "unexpected token: #{current&.value}" if current

        node
      end

      private

      def current
        @tokens[@pos]
      end

      def advance
        token = @tokens[@pos]
        @pos += 1
        token
      end

      def expect(type)
        token = advance
        raise Error, "expected #{type}, got #{token&.type || 'end of input'}" unless token&.type == type

        token
      end

      def parse_or
        left = parse_and
        while current&.type == :operator && current.value == '||'
          advance
          right = parse_and
          left = { type: :or, left: left, right: right }
        end
        left
      end

      def parse_and
        left = parse_equality
        while current&.type == :operator && current.value == '&&'
          advance
          right = parse_equality
          left = { type: :and, left: left, right: right }
        end
        left
      end

      def parse_equality
        left = parse_comparison
        while current&.type == :operator && %w[== !=].include?(current.value)
          op = advance.value
          right = parse_comparison
          left = { type: :comparison, op: op, left: left, right: right }
        end
        left
      end

      def parse_comparison
        left = parse_addition
        while current&.type == :operator && %w[> < >= <=].include?(current.value)
          op = advance.value
          right = parse_addition
          left = { type: :comparison, op: op, left: left, right: right }
        end
        left
      end

      def parse_addition
        left = parse_multiplication
        while current&.type == :operator && %w[+ -].include?(current.value)
          op = advance.value
          right = parse_multiplication
          left = { type: :binary, op: op, left: left, right: right }
        end
        left
      end

      def parse_multiplication
        left = parse_unary
        while current&.type == :operator && %w[* /].include?(current.value)
          op = advance.value
          right = parse_unary
          left = { type: :binary, op: op, left: left, right: right }
        end
        left
      end

      def parse_unary
        if current&.type == :operator && current.value == '!'
          advance
          operand = parse_unary
          return { type: :not, operand: operand }
        end

        if current&.type == :operator && current.value == '-'
          advance
          operand = parse_unary
          return { type: :negate, operand: operand }
        end

        parse_access
      end

      def parse_access
        node = parse_primary

        while current
          if current.type == :lbracket
            advance
            index = parse_or
            expect(:rbracket)
            node = { type: :index, object: node, key: index }
          elsif current.type == :dot
            advance
            property = expect(:identifier)
            node = { type: :property, object: node, name: property.value }
          else
            break
          end
        end

        node
      end

      def parse_primary
        token = current
        raise Error, 'unexpected end of expression' unless token

        case token.type
        when :number
          advance
          value = token.value.include?('.') ? token.value.to_f : token.value.to_i
          { type: :literal, value: value }
        when :string
          advance
          { type: :literal, value: token.value[1..-2] }
        when :boolean
          advance
          { type: :literal, value: token.value == 'true' }
        when :null
          advance
          { type: :literal, value: nil }
        when :identifier
          advance
          { type: :identifier, name: token.value }
        when :lparen
          advance
          node = parse_or
          expect(:rparen)
          node
        else
          raise Error, "unexpected token: #{token.value}"
        end
      end
    end
  end
end
