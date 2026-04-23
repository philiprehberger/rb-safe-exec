# frozen_string_literal: true

module Philiprehberger
  module SafeExec
    # Tokenizes expression strings into an array of typed tokens
    module Tokenizer
      TOKEN_PATTERNS = [
        [:number, /\A-?\d+(?:\.\d+)?/],
        [:string, /\A'[^']*'/],
        [:string, /\A"[^"]*"/],
        [:boolean, /\A(?:true|false)\b/],
        [:null, /\Anil\b/],
        [:operator, %r{\A(?:&&|\|\||\*\*|[!=]=|>=|<=|[+\-*/%><!])}],
        [:question, /\A\?/],
        [:colon, /\A:/],
        [:lparen, /\A\(/],
        [:rparen, /\A\)/],
        [:lbracket, /\A\[/],
        [:rbracket, /\A\]/],
        [:dot, /\A\./],
        [:comma, /\A,/],
        [:identifier, /\A[a-zA-Z_][a-zA-Z0-9_]*/],
        [:whitespace, /\A\s+/]
      ].freeze

      Token = Struct.new(:type, :value, keyword_init: true)

      # Tokenize an expression string
      #
      # @param input [String] the expression to tokenize
      # @return [Array<Token>] the token list
      # @raise [Philiprehberger::SafeExec::Error] on unexpected characters
      def self.tokenize(input)
        tokens = []
        pos = 0

        while pos < input.length
          matched = false

          TOKEN_PATTERNS.each do |type, pattern|
            match = input[pos..].match(pattern)
            next unless match

            tokens << Token.new(type: type, value: match[0]) unless type == :whitespace
            pos += match[0].length
            matched = true
            break
          end

          raise Error, "unexpected character at position #{pos}: '#{input[pos]}'" unless matched
        end

        tokens
      end
    end
  end
end
