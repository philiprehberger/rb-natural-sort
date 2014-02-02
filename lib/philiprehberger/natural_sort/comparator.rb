# frozen_string_literal: true

module Philiprehberger
  module NaturalSort
    # Splits a string into chunks of text and numbers for natural comparison.
    #
    # @param str [String] the string to tokenize
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Array<String, Integer>] alternating text and numeric chunks
    def self.tokenize(str, case_sensitive: false)
      normalized = case_sensitive ? str : str.downcase
      normalized.scan(/\d+|[^\d]+/).map do |chunk|
        chunk.match?(/\A\d+\z/) ? chunk.to_i : chunk
      end
    end

    # Compares two strings using natural sort order.
    #
    # @param a [String, nil] first string
    # @param b [String, nil] second string
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Integer] -1, 0, or 1
    def self.compare(a, b, case_sensitive: false)
      return 0 if a.nil? && b.nil?
      return -1 if a.nil?
      return 1 if b.nil?

      a_str = a.to_s
      b_str = b.to_s

      tokens_a = tokenize(a_str, case_sensitive: case_sensitive)
      tokens_b = tokenize(b_str, case_sensitive: case_sensitive)

      max_len = [tokens_a.length, tokens_b.length].max

      max_len.times do |i|
        chunk_a = tokens_a[i]
        chunk_b = tokens_b[i]

        # Shorter token list comes first
        return -1 if chunk_a.nil?
        return 1 if chunk_b.nil?

        # Both numeric
        if chunk_a.is_a?(Integer) && chunk_b.is_a?(Integer)
          cmp = chunk_a <=> chunk_b
          return cmp unless cmp.zero?

          next
        end

        # Both strings
        if chunk_a.is_a?(String) && chunk_b.is_a?(String)
          cmp = chunk_a <=> chunk_b
          return cmp unless cmp.zero?

          next
        end

        # Mixed: numbers sort before strings
        return chunk_a.is_a?(Integer) ? -1 : 1
      end

      0
    end

    # Returns a Proc suitable for use with Array#sort.
    #
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Proc] a comparison proc returning -1, 0, or 1
    def self.comparator(case_sensitive: false)
      ->(a, b) { compare(a, b, case_sensitive: case_sensitive) }
    end

    # Sorts an array of strings in natural order.
    #
    # @param array [Array<String, nil>] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Array<String, nil>] a new sorted array
    def self.sort(array, case_sensitive: false)
      array.sort { |a, b| compare(a, b, case_sensitive: case_sensitive) }
    end

    # Sorts an array by the natural order of values returned by the block.
    #
    # @param array [Array] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @yield [element] block that returns the string to compare
    # @return [Array] a new sorted array
    def self.sort_by(array, case_sensitive: false, &block)
      array.sort { |a, b| compare(block.call(a), block.call(b), case_sensitive: case_sensitive) }
    end
  end
end
