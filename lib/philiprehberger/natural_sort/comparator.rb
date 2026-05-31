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
    # @param ignore_case [Boolean] when true, downcases sort keys before comparison
    # @return [Array<String, nil>] a new sorted array
    def self.sort(array, case_sensitive: false, reverse: false, ignore_case: false)
      effective_case_sensitive = ignore_case ? false : case_sensitive
      result = array.sort { |a, b| compare(a, b, case_sensitive: effective_case_sensitive) }
      reverse ? result.reverse : result
    end

    # Sorts an array of strings in place using natural ordering.
    #
    # Mirrors Ruby's `Array#sort!` for callers who want to mutate the
    # receiver rather than copy. Returns the same array.
    #
    # @param array [Array<String, nil>] the array to sort in place
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @param reverse [Boolean] when true, reverses the natural order
    # @return [Array<String, nil>] the same array, now sorted in place
    def self.sort!(array, case_sensitive: false, reverse: false)
      array.sort! { |a, b| compare(a, b, case_sensitive: case_sensitive) }
      array.reverse! if reverse
      array
    end

    # Sorts an array by the natural order of values returned by the block.
    #
    # @param array [Array] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @param reverse [Boolean] when true, reverses the natural order
    # @param ignore_case [Boolean] when true, downcases sort keys before comparison
    # @yield [element] block that returns the string to compare
    # @return [Array] a new sorted array
    def self.sort_by(array, case_sensitive: false, reverse: false, ignore_case: false, &block)
      effective_case_sensitive = ignore_case ? false : case_sensitive
      result = array.sort { |a, b| compare(block.call(a), block.call(b), case_sensitive: effective_case_sensitive) }
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

    # Returns a two-element array `[min, max]` of the naturally-smallest and
    # naturally-largest elements in a single Enumerable pass. Mirrors Ruby's
    # `Enumerable#minmax`. Returns `[nil, nil]` for empty arrays.
    #
    # @param array [Array<String, nil>] the array to search
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Array<(String, String)>, Array<(nil, nil)>] [min, max] pair
    def self.minmax(array, case_sensitive: false)
      return [nil, nil] if array.empty?

      array.minmax { |a, b| compare(a, b, case_sensitive: case_sensitive) }
    end

    # Returns the n naturally-smallest elements of an array.
    #
    # With the default +n: 1+, returns the single smallest element (or +nil+ for
    # an empty array). With +n > 1+, returns an Array of up to +n+ elements in
    # natural sort order (small-to-large). When +n+ exceeds the array size, the
    # entire sorted array is returned.
    #
    # @param array [Array<String, nil>] the array to search
    # @param n [Integer] number of elements to return (must be a non-negative Integer)
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [String, Array<String, nil>, nil] a single element when +n == 1+,
    #   otherwise an Array of up to +n+ elements
    # @raise [ArgumentError] when +n+ is not a non-negative Integer
    def self.first(array, n: 1, case_sensitive: false)
      raise ArgumentError, 'n must be a non-negative Integer' unless n.is_a?(Integer) && n >= 0

      sorted = sort(array, case_sensitive: case_sensitive)
      return sorted.first if n == 1

      sorted.first(n)
    end

    # Returns the n naturally-largest elements of an array.
    #
    # With the default +n: 1+, returns the single largest element (or +nil+ for
    # an empty array). With +n > 1+, returns an Array of up to +n+ elements in
    # reverse natural sort order (large-to-small). When +n+ exceeds the array
    # size, the entire reverse-sorted array is returned.
    #
    # @param array [Array<String, nil>] the array to search
    # @param n [Integer] number of elements to return (must be a non-negative Integer)
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [String, Array<String, nil>, nil] a single element when +n == 1+,
    #   otherwise an Array of up to +n+ elements
    # @raise [ArgumentError] when +n+ is not a non-negative Integer
    def self.last(array, n: 1, case_sensitive: false)
      raise ArgumentError, 'n must be a non-negative Integer' unless n.is_a?(Integer) && n >= 0

      sorted = sort(array, case_sensitive: case_sensitive)
      return sorted.last if n == 1

      sorted.last(n).reverse
    end

    # Returns a sort key array usable with Ruby's built-in sort_by, min_by, max_by, etc.
    #
    # The key is an array of [type_flag, value] pairs where type_flag ensures
    # correct ordering between numeric and string chunks (numbers sort before strings).
    #
    # @param str [String, nil] the string to generate a key for
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Array] a comparable sort key
    def self.natural_key(str, case_sensitive: false)
      return [[-1, '']] if str.nil?

      tokens = tokenize(str.to_s, case_sensitive: case_sensitive)
      tokens.map do |chunk|
        chunk.is_a?(Integer) ? [0, chunk] : [1, chunk]
      end
    end

    # Stable sort by block result, preserving original order for equal elements.
    #
    # @param array [Array] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @yield [element] block that returns the string to compare
    # @return [Array] a new sorted array with stable ordering
    def self.sort_by_stable(array, case_sensitive: false, &block)
      array.each_with_index
           .sort_by do |element, index|
        key_str = block.call(element)
        [natural_key(key_str, case_sensitive: case_sensitive), index]
      end
           .map(&:first)
    end

    # Spaceship-style comparator returning -1, 0, or 1.
    #
    # Suitable for use with Array#sort:
    #   array.sort { |a, b| NaturalSort.collate(a, b) }
    #
    # @param a [String, nil] first string
    # @param b [String, nil] second string
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Integer] -1, 0, or 1
    def self.collate(a, b, case_sensitive: false)
      compare(a, b, case_sensitive: case_sensitive)
    end

    # Returns true if value falls within the natural sort range [min, max] inclusive.
    #
    # @param value [String] the value to check
    # @param min [String] the lower bound (inclusive)
    # @param max [String] the upper bound (inclusive)
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Boolean] true if value is between min and max in natural sort order
    def self.between?(value, min, max, case_sensitive: false)
      compare(min, value, case_sensitive: case_sensitive) <= 0 &&
        compare(value, max, case_sensitive: case_sensitive) <= 0
    end

    # Splits each string at the first digit boundary, groups by the non-numeric prefix.
    # Each group's values are naturally sorted.
    #
    # @param array [Array<String>] the array to group
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Hash<String, Array<String>>] prefix => naturally sorted values
    def self.group_by_prefix(array, case_sensitive: false)
      groups = {}

      array.each do |str|
        s = str.to_s
        match = s.match(/\A([^\d]*)/)
        prefix = match ? match[1] : ''

        groups[prefix] ||= []
        groups[prefix] << str
      end

      groups.each_value do |values|
        values.replace(sort(values, case_sensitive: case_sensitive))
      end

      groups
    end

    # Returns an array of original indices representing the natural-sort permutation.
    #
    # @param array [Array<String, nil>] the array to sort
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @param reverse [Boolean] when true, reverses the natural order
    # @return [Array<Integer>] indices into the original array in natural sort order
    def self.sort_index(array, case_sensitive: false, reverse: false)
      return [] if array.empty?

      result = array.each_with_index
                    .sort { |(a, _), (b, _)| compare(a, b, case_sensitive: case_sensitive) }
                    .map(&:last)
      reverse ? result.reverse : result
    end

    # Deduplicates an array preserving first-occurrence order, treating elements as
    # equal when natural comparison returns 0.
    #
    # @param array [Array<String, nil>] the array to deduplicate
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @return [Array<String, nil>] a new array with duplicates removed
    def self.uniq(array, case_sensitive: false)
      result = []
      array.each do |element|
        next if result.any? { |kept| compare(kept, element, case_sensitive: case_sensitive).zero? }

        result << element
      end
      result
    end

    # Natural sort for separator-delimited paths.
    #
    # Splits each path on +separator+, naturally sorts the resulting segment arrays
    # lexicographically, then returns the original path strings in sorted order.
    # Trailing separators are preserved in the output; the split segments (with an
    # empty trailing element) are used for comparison.
    #
    # @param paths [Array<String>] paths to sort
    # @param separator [String] the path separator (default '/')
    # @param case_sensitive [Boolean] whether text comparison is case-sensitive
    # @param reverse [Boolean] when true, reverses the final output order
    # @return [Array<String>] a new array of paths in natural-sort order
    def self.sort_paths(paths, separator: '/', case_sensitive: false, reverse: false)
      decorated = paths.map do |path|
        segments = path.to_s.split(separator, -1)
        key = segments.map { |seg| natural_key(seg, case_sensitive: case_sensitive) }
        [key, path]
      end

      sorted = decorated.sort_by(&:first).map(&:last)
      reverse ? sorted.reverse : sorted
    end

    # Returns the position +target+ would occupy in natural sort order
    # within +array+, treating equality under natural comparison. Returns
    # +nil+ when no element compares equal to +target+. Equivalent to a
    # natural-sort variant of +Array#index+ that respects natural
    # comparison semantics (e.g. +'a1'+ and +'a01'+ are equal).
    #
    # When multiple elements compare equal, the smallest index of an
    # equal element is returned.
    #
    # @example
    #   Philiprehberger::NaturalSort.index(['file10', 'file2', 'file1'], 'file2')
    #   # => 1
    #
    # @param array [Array<String, nil>] the array to search
    # @param target [String, nil] the value to locate
    # @param case_sensitive [Boolean] whether comparison is case-sensitive
    # @return [Integer, nil] the first index whose value naturally equals +target+, or nil
    def self.index(array, target, case_sensitive: false)
      array.each_with_index do |element, idx|
        return idx if compare(element, target, case_sensitive: case_sensitive).zero?
      end
      nil
    end

    # Binary-search variant of {index} that assumes +sorted_array+ is
    # already in natural sort order. Returns the index of an element that
    # compares equal to +target+, or +nil+ when no such element exists.
    # O(log n) lookup.
    #
    # Behaviour is undefined when +sorted_array+ is not actually sorted.
    #
    # @example
    #   sorted = Philiprehberger::NaturalSort.sort(['file10', 'file2', 'file1'])
    #   Philiprehberger::NaturalSort.position(sorted, 'file2')
    #   # => 1
    #
    # @param sorted_array [Array<String, nil>] an array already in natural sort order
    # @param target [String, nil] the value to locate
    # @param case_sensitive [Boolean] whether comparison is case-sensitive
    # @return [Integer, nil] index of an element that naturally equals +target+, or nil
    def self.position(sorted_array, target, case_sensitive: false)
      lo = 0
      hi = sorted_array.length - 1
      while lo <= hi
        mid = (lo + hi) / 2
        cmp = compare(sorted_array[mid], target, case_sensitive: case_sensitive)
        return mid if cmp.zero?

        if cmp.negative?
          lo = mid + 1
        else
          hi = mid - 1
        end
      end
      nil
    end

    # Refinement that adds sort_naturally_by to Array.
    #
    # Usage:
    #   using Philiprehberger::NaturalSort::ArrayRefinement
    #   array.sort_naturally_by { |item| item.name }
    module ArrayRefinement
      refine Array do
        # Sorts the array by the natural order of values returned by the block.
        #
        # @param case_sensitive [Boolean] whether text comparison is case-sensitive
        # @param reverse [Boolean] when true, reverses the natural order
        # @yield [element] block that returns the string to compare
        # @return [Array] a new sorted array
        def sort_naturally_by(case_sensitive: false, reverse: false, &block)
          Philiprehberger::NaturalSort.sort_by(self, case_sensitive: case_sensitive, reverse: reverse, &block)
        end
      end
    end
  end
end
