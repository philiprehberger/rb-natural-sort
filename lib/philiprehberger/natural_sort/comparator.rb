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
    # @param reverse [Boolean] when true, reverses the natural order
    # @return [Array<String, nil>] a new sorted array
    def self.sort(array, case_sensitive: false, reverse: false)
      result = array.sort { |a, b| compare(a, b, case_sensitive: case_sensitive) }
      reverse ? result.reverse : result
    end

    # Sorts an array by the natural order of values returned by the block.
    #
    # @param array [Array] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @param reverse [Boolean] when true, reverses the natural order
    # @yield [element] block that returns the string to compare
    # @return [Array] a new sorted array
    def self.sort_by(array, case_sensitive: false, reverse: false, &block)
      result = array.sort { |a, b| compare(block.call(a), block.call(b), case_sensitive: case_sensitive) }
      reverse ? result.reverse : result
    end

    # Stable sort that preserves original order for equal elements.
    #
    # @param array [Array<String, nil>] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Array<String, nil>] a new sorted array with stable ordering
    def self.sort_stable(array, case_sensitive: false)
      array.each_with_index
           .sort_by do |element, index|
        [tokenize(element.nil? ? '' : element.to_s, case_sensitive: case_sensitive), element.nil? ? 0 : 1,
         index]
      end
           .map(&:first)
    end

    # Finds the naturally smallest element without full sort.
    #
    # @param array [Array<String, nil>] the array to search
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [String, nil] the naturally smallest element, or nil for empty arrays
    def self.min(array, case_sensitive: false)
      return nil if array.empty?

      array.min { |a, b| compare(a, b, case_sensitive: case_sensitive) }
    end

    # Finds the naturally largest element without full sort.
    #
    # @param array [Array<String, nil>] the array to search
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [String, nil] the naturally largest element, or nil for empty arrays
    def self.max(array, case_sensitive: false)
      return nil if array.empty?

      array.max { |a, b| compare(a, b, case_sensitive: case_sensitive) }
    end
  end
end
