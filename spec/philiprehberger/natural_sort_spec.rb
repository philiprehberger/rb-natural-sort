# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Philiprehberger::NaturalSort do
  it 'has a version number' do
    expect(Philiprehberger::NaturalSort::VERSION).not_to be_nil
  end

  describe '.sort' do
    it 'sorts file names naturally' do
      input = %w[file10 file2 file1]
      expect(described_class.sort(input)).to eq(%w[file1 file2 file10])
    end

    it 'sorts image names with multiple numbers' do
      input = %w[img12 img2 img1 img22]
      expect(described_class.sort(input)).to eq(%w[img1 img2 img12 img22])
    end

    it 'is case insensitive by default' do
      input = %w[Banana apple cherry]
      expect(described_class.sort(input)).to eq(%w[apple Banana cherry])
    end

    it 'supports case sensitive sorting' do
      input = %w[banana Apple cherry]
      result = described_class.sort(input, case_sensitive: true)
      expect(result).to eq(%w[Apple banana cherry])
    end

    it 'handles empty strings' do
      input = ['b', '', 'a']
      expect(described_class.sort(input)).to eq(['', 'a', 'b'])
    end

    it 'handles nil values' do
      input = ['b', nil, 'a']
      expect(described_class.sort(input)).to eq([nil, 'a', 'b'])
    end

    it 'handles all-numeric strings' do
      input = %w[100 20 3]
      expect(described_class.sort(input)).to eq(%w[3 20 100])
    end

    it 'handles strings with leading zeros' do
      input = %w[file009 file10 file01]
      expect(described_class.sort(input)).to eq(%w[file01 file009 file10])
    end

    it 'handles strings with no numbers' do
      input = %w[cherry apple banana]
      expect(described_class.sort(input)).to eq(%w[apple banana cherry])
    end

    it 'handles mixed numeric and text-only strings' do
      input = %w[abc abc1 abc2 abc10]
      expect(described_class.sort(input)).to eq(%w[abc abc1 abc2 abc10])
    end

    it 'returns a new array without modifying the original' do
      input = %w[file10 file2 file1]
      result = described_class.sort(input)
      expect(input).to eq(%w[file10 file2 file1])
      expect(result).to eq(%w[file1 file2 file10])
    end
  end

  describe '.sort_by' do
    it 'sorts by block result in natural order' do
      items = [
        { name: 'item10' },
        { name: 'item2' },
        { name: 'item1' }
      ]
      result = described_class.sort_by(items) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[item1 item2 item10])
    end

    it 'supports case sensitive sorting via block' do
      items = [{ name: 'Item2' }, { name: 'item1' }, { name: 'Item10' }]
      result = described_class.sort_by(items, case_sensitive: true) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[Item2 Item10 item1])
    end
  end

  describe '.sort!' do
    it 'mutates the array in place using natural ordering' do
      input = %w[file10 file2 file1]
      result = described_class.sort!(input)
      expect(input).to eq(%w[file1 file2 file10])
      expect(result).to be(input)
    end

    it 'sorts case-insensitively by default' do
      input = %w[Banana apple Cherry]
      described_class.sort!(input)
      expect(input).to eq(%w[apple Banana Cherry])
    end

    it 'respects case_sensitive: true' do
      input = %w[Banana apple Cherry]
      described_class.sort!(input, case_sensitive: true)
      expect(input).to eq(%w[Banana Cherry apple])
    end

    it 'reverses the order when reverse: true' do
      input = %w[file2 file10 file1]
      described_class.sort!(input, reverse: true)
      expect(input).to eq(%w[file10 file2 file1])
    end

    it 'returns the same array reference' do
      input = %w[c a b]
      expect(described_class.sort!(input)).to be(input)
    end

    it 'handles an empty array' do
      input = []
      described_class.sort!(input)
      expect(input).to eq([])
    end
  end

  describe '.sort with reverse' do
    it 'sorts strings in reverse natural order' do
      input = %w[cherry apple banana]
      expect(described_class.sort(input, reverse: true)).to eq(%w[cherry banana apple])
    end

    it 'sorts numbers in reverse natural order' do
      input = %w[100 20 3]
      expect(described_class.sort(input, reverse: true)).to eq(%w[100 20 3])
    end

    it 'sorts mixed strings in reverse natural order' do
      input = %w[file10 file2 file1]
      expect(described_class.sort(input, reverse: true)).to eq(%w[file10 file2 file1])
    end

    it 'handles empty array with reverse' do
      expect(described_class.sort([], reverse: true)).to eq([])
    end

    it 'handles single element with reverse' do
      expect(described_class.sort(%w[only], reverse: true)).to eq(%w[only])
    end

    it 'handles nil values with reverse' do
      input = ['b', nil, 'a']
      expect(described_class.sort(input, reverse: true)).to eq(['b', 'a', nil])
    end
  end

  describe '.sort_by with reverse' do
    it 'sorts by block result in reverse natural order' do
      items = [
        { name: 'item1' },
        { name: 'item10' },
        { name: 'item2' }
      ]
      result = described_class.sort_by(items, reverse: true) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[item10 item2 item1])
    end
  end

  describe '.sort_stable' do
    it 'preserves original order for equal elements' do
      input = %w[file1 FILE1 file2]
      result = described_class.sort_stable(input)
      expect(result).to eq(%w[file1 FILE1 file2])
    end

    it 'preserves order among case-insensitive duplicates' do
      input = %w[Banana banana BANANA apple]
      result = described_class.sort_stable(input)
      expect(result).to eq(%w[apple Banana banana BANANA])
    end

    it 'sorts naturally when no ties exist' do
      input = %w[file10 file2 file1]
      result = described_class.sort_stable(input)
      expect(result).to eq(%w[file1 file2 file10])
    end

    it 'handles empty array' do
      expect(described_class.sort_stable([])).to eq([])
    end

    it 'handles single element' do
      expect(described_class.sort_stable(%w[only])).to eq(%w[only])
    end

    it 'handles nil values' do
      input = ['b', nil, 'a']
      result = described_class.sort_stable(input)
      expect(result).to eq([nil, 'a', 'b'])
    end
  end

  describe '.min' do
    it 'finds the naturally smallest element' do
      input = %w[file10 file2 file1]
      expect(described_class.min(input)).to eq('file1')
    end

    it 'finds the smallest numeric string' do
      input = %w[100 20 3]
      expect(described_class.min(input)).to eq('3')
    end

    it 'returns nil for empty array' do
      expect(described_class.min([])).to be_nil
    end

    it 'returns the element for single-element array' do
      expect(described_class.min(%w[only])).to eq('only')
    end

    it 'handles nil values' do
      input = ['b', nil, 'a']
      expect(described_class.min(input)).to be_nil
    end

    it 'is case insensitive by default' do
      input = %w[Banana apple Cherry]
      expect(described_class.min(input)).to eq('apple')
    end
  end

  describe '.max' do
    it 'finds the naturally largest element' do
      input = %w[file10 file2 file1]
      expect(described_class.max(input)).to eq('file10')
    end

    it 'finds the largest numeric string' do
      input = %w[100 20 3]
      expect(described_class.max(input)).to eq('100')
    end

    it 'returns nil for empty array' do
      expect(described_class.max([])).to be_nil
    end

    it 'returns the element for single-element array' do
      expect(described_class.max(%w[only])).to eq('only')
    end

    it 'handles nil values' do
      input = ['b', nil, 'a']
      expect(described_class.max(input)).to eq('b')
    end

    it 'is case insensitive by default' do
      input = %w[Banana apple Cherry]
      expect(described_class.max(input)).to eq('Cherry')
    end
  end

  describe '.first' do
    it 'returns the naturally smallest element by default' do
      input = %w[file10 file2 file1]
      expect(described_class.first(input)).to eq('file1')
    end

    it 'returns an array of the n smallest elements when n > 1' do
      input = %w[file10 file2 file1 file20 file3]
      expect(described_class.first(input, n: 3)).to eq(%w[file1 file2 file3])
    end

    it 'returns the entire sorted array when n exceeds array length' do
      input = %w[file10 file2 file1]
      expect(described_class.first(input, n: 10)).to eq(%w[file1 file2 file10])
    end

    it 'returns an empty array when n is 0' do
      input = %w[file10 file2 file1]
      expect(described_class.first(input, n: 0)).to eq([])
    end

    it 'returns nil for an empty array with default n' do
      expect(described_class.first([])).to be_nil
    end

    it 'returns an empty array for an empty array with n > 1' do
      expect(described_class.first([], n: 2)).to eq([])
    end

    it 'honors case_sensitive when true' do
      input = %w[banana Apple cherry]
      expect(described_class.first(input, case_sensitive: true)).to eq('Apple')
    end

    it 'returns the n smallest with case_sensitive: true' do
      input = %w[banana Apple cherry Date]
      result = described_class.first(input, n: 2, case_sensitive: true)
      expect(result).to eq(%w[Apple Date])
    end

    it 'raises ArgumentError for negative n' do
      expect { described_class.first(%w[a b], n: -1) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for non-Integer n' do
      expect { described_class.first(%w[a b], n: 1.5) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for nil n' do
      expect { described_class.first(%w[a b], n: nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.last' do
    it 'returns the naturally largest element by default' do
      input = %w[file10 file2 file1]
      expect(described_class.last(input)).to eq('file10')
    end

    it 'returns an array of the n largest elements when n > 1 in reverse natural order' do
      input = %w[file10 file2 file1 file20 file3]
      expect(described_class.last(input, n: 3)).to eq(%w[file20 file10 file3])
    end

    it 'returns the entire reverse-sorted array when n exceeds array length' do
      input = %w[file10 file2 file1]
      expect(described_class.last(input, n: 10)).to eq(%w[file10 file2 file1])
    end

    it 'returns an empty array when n is 0' do
      input = %w[file10 file2 file1]
      expect(described_class.last(input, n: 0)).to eq([])
    end

    it 'returns nil for an empty array with default n' do
      expect(described_class.last([])).to be_nil
    end

    it 'returns an empty array for an empty array with n > 1' do
      expect(described_class.last([], n: 2)).to eq([])
    end

    it 'honors case_sensitive when true' do
      input = %w[banana Apple cherry]
      expect(described_class.last(input, case_sensitive: true)).to eq('cherry')
    end

    it 'returns the n largest with case_sensitive: true' do
      input = %w[banana Apple cherry Date]
      result = described_class.last(input, n: 2, case_sensitive: true)
      expect(result).to eq(%w[cherry banana])
    end

    it 'raises ArgumentError for negative n' do
      expect { described_class.last(%w[a b], n: -1) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for non-Integer n' do
      expect { described_class.last(%w[a b], n: 1.5) }.to raise_error(ArgumentError)
    end

    it 'raises ArgumentError for nil n' do
      expect { described_class.last(%w[a b], n: nil) }.to raise_error(ArgumentError)
    end
  end

  describe '.compare' do
    it 'returns -1 when a sorts before b' do
      expect(described_class.compare('file1', 'file2')).to eq(-1)
    end

    it 'returns 1 when a sorts after b' do
      expect(described_class.compare('file10', 'file2')).to eq(1)
    end

    it 'returns 0 for equal strings' do
      expect(described_class.compare('file1', 'file1')).to eq(0)
    end

    it 'returns 0 for case-insensitive equal strings' do
      expect(described_class.compare('File1', 'file1')).to eq(0)
    end

    it 'distinguishes case when case_sensitive is true' do
      result = described_class.compare('File1', 'file1', case_sensitive: true)
      expect(result).not_to eq(0)
    end

    it 'handles nil values' do
      expect(described_class.compare(nil, 'a')).to eq(-1)
      expect(described_class.compare('a', nil)).to eq(1)
      expect(described_class.compare(nil, nil)).to eq(0)
    end
  end

  describe 'ArrayRefinement#sort_naturally_by' do
    using Philiprehberger::NaturalSort::ArrayRefinement

    it 'sorts by block result in natural order' do
      items = [
        Struct.new(:name).new('item10'),
        Struct.new(:name).new('item2'),
        Struct.new(:name).new('item1')
      ]
      result = items.sort_naturally_by(&:name)
      expect(result.map(&:name)).to eq(%w[item1 item2 item10])
    end

    it 'supports case sensitive sorting' do
      items = [
        Struct.new(:name).new('Item2'),
        Struct.new(:name).new('item1'),
        Struct.new(:name).new('Item10')
      ]
      result = items.sort_naturally_by(case_sensitive: true, &:name)
      expect(result.map(&:name)).to eq(%w[Item2 Item10 item1])
    end

    it 'supports reverse sorting' do
      items = [
        Struct.new(:name).new('item1'),
        Struct.new(:name).new('item10'),
        Struct.new(:name).new('item2')
      ]
      result = items.sort_naturally_by(reverse: true, &:name)
      expect(result.map(&:name)).to eq(%w[item10 item2 item1])
    end

    it 'handles empty arrays' do
      result = [].sort_naturally_by { |x| x }
      expect(result).to eq([])
    end

    it 'handles single element arrays' do
      items = [Struct.new(:name).new('only')]
      result = items.sort_naturally_by(&:name)
      expect(result.map(&:name)).to eq(%w[only])
    end
  end

  describe '.natural_key' do
    it 'returns comparable keys that sort strings naturally' do
      sorted = %w[file10 file2 file1].sort_by { |s| described_class.natural_key(s) }
      expect(sorted).to eq(%w[file1 file2 file10])
    end

    it 'works with min_by' do
      result = %w[file10 file2 file1].min_by { |s| described_class.natural_key(s) }
      expect(result).to eq('file1')
    end

    it 'works with max_by' do
      result = %w[file10 file2 file1].max_by { |s| described_class.natural_key(s) }
      expect(result).to eq('file10')
    end

    it 'handles nil' do
      key = described_class.natural_key(nil)
      expect(key).to eq([[-1, '']])
    end

    it 'is case insensitive by default' do
      sorted = %w[Banana apple Cherry].sort_by { |s| described_class.natural_key(s) }
      expect(sorted).to eq(%w[apple Banana Cherry])
    end

    it 'supports case sensitive mode' do
      sorted = %w[banana Apple cherry].sort_by { |s| described_class.natural_key(s, case_sensitive: true) }
      expect(sorted).to eq(%w[Apple banana cherry])
    end

    it 'sorts numbers before strings in mixed chunks' do
      key_num = described_class.natural_key('123')
      key_str = described_class.natural_key('abc')
      expect(key_num <=> key_str).to eq(-1)
    end
  end

  describe '.sort_by_stable' do
    it 'preserves original order for equal block values' do
      items = [
        { name: 'file1', id: 'a' },
        { name: 'FILE1', id: 'b' },
        { name: 'file2', id: 'c' }
      ]
      result = described_class.sort_by_stable(items) { |x| x[:name] }
      expect(result.map { |x| x[:id] }).to eq(%w[a b c])
    end

    it 'sorts by block result in natural order' do
      items = [
        { name: 'item10' },
        { name: 'item2' },
        { name: 'item1' }
      ]
      result = described_class.sort_by_stable(items) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[item1 item2 item10])
    end

    it 'supports case sensitive mode' do
      items = [{ name: 'Item2' }, { name: 'item1' }, { name: 'Item10' }]
      result = described_class.sort_by_stable(items, case_sensitive: true) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[Item2 Item10 item1])
    end

    it 'handles empty array' do
      result = described_class.sort_by_stable([]) { |x| x }
      expect(result).to eq([])
    end
  end

  describe '.sort with ignore_case' do
    it 'sorts case-insensitively when ignore_case is true' do
      input = %w[Banana apple Cherry]
      expect(described_class.sort(input, ignore_case: true)).to eq(%w[apple Banana Cherry])
    end

    it 'overrides case_sensitive when ignore_case is true' do
      input = %w[Banana apple Cherry]
      result = described_class.sort(input, case_sensitive: true, ignore_case: true)
      expect(result).to eq(%w[apple Banana Cherry])
    end

    it 'does not affect default behavior when ignore_case is false' do
      input = %w[Banana apple Cherry]
      expect(described_class.sort(input, ignore_case: false)).to eq(%w[apple Banana Cherry])
    end

    it 'sorts numbered strings case-insensitively with ignore_case' do
      input = %w[File10 file2 FILE1]
      result = described_class.sort(input, ignore_case: true)
      expect(result).to eq(%w[FILE1 file2 File10])
    end

    it 'respects case_sensitive when ignore_case is false' do
      input = %w[banana Apple cherry]
      result = described_class.sort(input, case_sensitive: true, ignore_case: false)
      expect(result).to eq(%w[Apple banana cherry])
    end
  end

  describe '.sort_by with ignore_case' do
    it 'sorts by block result case-insensitively when ignore_case is true' do
      items = [{ name: 'Item10' }, { name: 'item2' }, { name: 'ITEM1' }]
      result = described_class.sort_by(items, ignore_case: true) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[ITEM1 item2 Item10])
    end

    it 'overrides case_sensitive when ignore_case is true in sort_by' do
      items = [{ name: 'Banana' }, { name: 'apple' }, { name: 'Cherry' }]
      result = described_class.sort_by(items, case_sensitive: true, ignore_case: true) { |x| x[:name] }
      expect(result.map { |x| x[:name] }).to eq(%w[apple Banana Cherry])
    end
  end

  describe '.group_by_prefix' do
    it 'groups strings by their non-numeric prefix' do
      input = %w[file1 file2 file10 img3 img20]
      result = described_class.group_by_prefix(input)
      expect(result).to eq({
                             'file' => %w[file1 file2 file10],
                             'img' => %w[img3 img20]
                           })
    end

    it 'naturally sorts values within each group' do
      input = %w[file10 file2 file1]
      result = described_class.group_by_prefix(input)
      expect(result['file']).to eq(%w[file1 file2 file10])
    end

    it 'handles strings with no prefix (starting with digits)' do
      input = %w[1abc 2def 10ghi]
      result = described_class.group_by_prefix(input)
      expect(result['']).to eq(%w[1abc 2def 10ghi])
    end

    it 'handles strings with no numbers' do
      input = %w[cherry apple banana]
      result = described_class.group_by_prefix(input)
      expect(result).to eq({
                             'cherry' => %w[cherry],
                             'apple' => %w[apple],
                             'banana' => %w[banana]
                           })
    end

    it 'handles empty array' do
      expect(described_class.group_by_prefix([])).to eq({})
    end

    it 'handles single element' do
      result = described_class.group_by_prefix(%w[file1])
      expect(result).to eq({ 'file' => %w[file1] })
    end

    it 'handles mixed prefixes with case insensitive sorting' do
      input = %w[File1 file2 File10]
      result = described_class.group_by_prefix(input)
      expect(result['File']).to eq(%w[File1 File10])
      expect(result['file']).to eq(%w[file2])
    end
  end

  describe '.collate' do
    it 'returns -1 when a sorts before b' do
      expect(described_class.collate('file1', 'file2')).to eq(-1)
    end

    it 'returns 1 when a sorts after b' do
      expect(described_class.collate('file10', 'file2')).to eq(1)
    end

    it 'returns 0 for equal strings' do
      expect(described_class.collate('file1', 'file1')).to eq(0)
    end

    it 'is case insensitive by default' do
      expect(described_class.collate('File1', 'file1')).to eq(0)
    end

    it 'supports case_sensitive mode' do
      result = described_class.collate('File1', 'file1', case_sensitive: true)
      expect(result).not_to eq(0)
    end

    it 'can be used with Array#sort' do
      input = %w[file10 file2 file1]
      result = input.sort { |a, b| described_class.collate(a, b) }
      expect(result).to eq(%w[file1 file2 file10])
    end

    it 'handles nil values' do
      expect(described_class.collate(nil, 'a')).to eq(-1)
      expect(described_class.collate('a', nil)).to eq(1)
      expect(described_class.collate(nil, nil)).to eq(0)
    end
  end

  describe '.between?' do
    it 'returns true when value is within range' do
      expect(described_class.between?('v1.5', 'v1.0', 'v2.0')).to be true
    end

    it 'returns false when value is below range' do
      expect(described_class.between?('v0.5', 'v1.0', 'v2.0')).to be false
    end

    it 'returns false when value is above range' do
      expect(described_class.between?('v3.0', 'v1.0', 'v2.0')).to be false
    end

    it 'returns true when value equals min boundary' do
      expect(described_class.between?('v1.0', 'v1.0', 'v2.0')).to be true
    end

    it 'returns true when value equals max boundary' do
      expect(described_class.between?('v2.0', 'v1.0', 'v2.0')).to be true
    end

    it 'returns true when min, max, and value are all equal' do
      expect(described_class.between?('v1.0', 'v1.0', 'v1.0')).to be true
    end

    it 'is case insensitive by default' do
      expect(described_class.between?('File5', 'file1', 'file10')).to be true
    end

    it 'respects case sensitivity when enabled' do
      result = described_class.between?('file5', 'File1', 'File10', case_sensitive: true)
      expect(result).to be false
    end

    it 'works with mixed alphanumeric IDs' do
      expect(described_class.between?('item7', 'item1', 'item20')).to be true
    end

    it 'works with purely numeric strings' do
      expect(described_class.between?('5', '1', '10')).to be true
    end
  end

  describe '.sort_index' do
    it 'returns original indices in natural sort order' do
      input = %w[file10 file2 file1]
      expect(described_class.sort_index(input)).to eq([2, 1, 0])
    end

    it 'returns indices for image names with multiple numbers' do
      input = %w[img12 img2 img1 img22]
      expect(described_class.sort_index(input)).to eq([2, 1, 0, 3])
    end

    it 'is case insensitive by default' do
      input = %w[Banana apple cherry]
      expect(described_class.sort_index(input)).to eq([1, 0, 2])
    end

    it 'supports case sensitive sorting' do
      input = %w[banana Apple cherry]
      expect(described_class.sort_index(input, case_sensitive: true)).to eq([1, 0, 2])
    end

    it 'supports reverse order' do
      input = %w[file10 file2 file1]
      expect(described_class.sort_index(input, reverse: true)).to eq([0, 1, 2])
    end

    it 'returns empty array for empty input' do
      expect(described_class.sort_index([])).to eq([])
    end

    it 'returns [0] for single element' do
      expect(described_class.sort_index(%w[only])).to eq([0])
    end
  end

  describe '.uniq' do
    it 'deduplicates using natural equality case-insensitively by default' do
      expect(described_class.uniq(%w[a1 A1 a01])).to eq(%w[a1])
    end

    it 'collapses leading-zero numeric duplicates even in case-sensitive mode' do
      result = described_class.uniq(%w[a1 A1 a01], case_sensitive: true)
      expect(result).to eq(%w[a1 A1])
    end

    it 'returns an empty array for empty input' do
      expect(described_class.uniq([])).to eq([])
    end

    it 'returns a new array equal to the input when all elements are unique' do
      input = %w[file1 file2 file10]
      result = described_class.uniq(input)
      expect(result).to eq(%w[file1 file2 file10])
      expect(result).not_to equal(input)
    end

    it 'preserves first-occurrence order' do
      expect(described_class.uniq(%w[b a b])).to eq(%w[b a])
    end

    it 'does not mutate the input array' do
      input = %w[a1 A1 a01]
      described_class.uniq(input)
      expect(input).to eq(%w[a1 A1 a01])
    end
  end

  describe '.sort_paths' do
    it 'sorts paths by natural order of each segment' do
      input = ['a/10/x', 'a/2/x', 'a/2/y']
      expect(described_class.sort_paths(input)).to eq(['a/2/x', 'a/2/y', 'a/10/x'])
    end

    it 'handles mixed-depth paths' do
      input = ['a/b/c', 'a/b', 'a/b/c/d', 'a']
      expect(described_class.sort_paths(input)).to eq(['a', 'a/b', 'a/b/c', 'a/b/c/d'])
    end

    it 'handles duplicate path segments' do
      input = ['a/a/a', 'a/a', 'a/a/b', 'a/a/a']
      expect(described_class.sort_paths(input)).to eq(['a/a', 'a/a/a', 'a/a/a', 'a/a/b'])
    end

    it 'preserves trailing separators in output but compares by split segments' do
      input = ['a/10/', 'a/2/', 'a/2']
      result = described_class.sort_paths(input)
      expect(result).to eq(['a/2', 'a/2/', 'a/10/'])
    end

    it 'is case insensitive by default' do
      input = ['a/Banana', 'a/apple', 'a/cherry']
      expect(described_class.sort_paths(input)).to eq(['a/apple', 'a/Banana', 'a/cherry'])
    end

    it 'supports case sensitive sorting' do
      input = ['a/banana', 'a/Apple', 'a/cherry']
      result = described_class.sort_paths(input, case_sensitive: true)
      expect(result).to eq(['a/Apple', 'a/banana', 'a/cherry'])
    end

    it 'supports a custom Windows-style separator' do
      input = ['C:\\docs\\file10', 'C:\\docs\\file2', 'C:\\docs\\file1']
      result = described_class.sort_paths(input, separator: '\\')
      expect(result).to eq(['C:\\docs\\file1', 'C:\\docs\\file2', 'C:\\docs\\file10'])
    end

    it 'reverses the final output order when reverse is true' do
      input = ['a/10/x', 'a/2/x', 'a/2/y']
      expect(described_class.sort_paths(input, reverse: true)).to eq(['a/10/x', 'a/2/y', 'a/2/x'])
    end

    it 'returns a new array and does not mutate the input' do
      input = ['a/10/x', 'a/2/x', 'a/2/y']
      result = described_class.sort_paths(input)
      expect(input).to eq(['a/10/x', 'a/2/x', 'a/2/y'])
      expect(result).not_to equal(input)
    end

    it 'returns an empty array for empty input' do
      expect(described_class.sort_paths([])).to eq([])
    end
  end

  describe '.comparator' do
    it 'returns a Proc' do
      expect(described_class.comparator).to be_a(Proc)
    end

    it 'can be used with Array#sort' do
      input = %w[file10 file2 file1]
      result = input.sort(&described_class.comparator)
      expect(result).to eq(%w[file1 file2 file10])
    end

    it 'supports case sensitive mode' do
      cmp = described_class.comparator(case_sensitive: true)
      expect(cmp.call('Apple', 'banana')).to be_negative
    end
  end

  describe '.index' do
    it 'returns the index of a matching element in an unsorted array' do
      expect(described_class.index(%w[file10 file2 file1], 'file2')).to eq(1)
    end

    it 'returns nil when the target is not present' do
      expect(described_class.index(%w[file10 file2 file1], 'file99')).to be_nil
    end

    it 'treats naturally-equal values (zero-padding) as equal' do
      expect(described_class.index(%w[a1 b1], 'a01')).to eq(0)
    end

    it 'returns nil for an empty array' do
      expect(described_class.index([], 'anything')).to be_nil
    end

    it 'respects case_sensitive: true' do
      expect(described_class.index(%w[Apple apple banana], 'apple', case_sensitive: true)).to eq(1)
    end
  end

  describe '.position' do
    it 'finds a target in a naturally-sorted array via binary search' do
      sorted = described_class.sort(%w[file10 file2 file1])
      expect(described_class.position(sorted, 'file2')).to eq(1)
    end

    it 'returns nil when the target is not present' do
      sorted = described_class.sort(%w[file10 file2 file1])
      expect(described_class.position(sorted, 'file99')).to be_nil
    end

    it 'treats naturally-equal values as equal' do
      sorted = described_class.sort(%w[a1 b1 c1])
      expect(described_class.position(sorted, 'a01')).to eq(0)
    end

    it 'returns nil for an empty array' do
      expect(described_class.position([], 'anything')).to be_nil
    end

    it 'finds elements at the boundaries' do
      sorted = described_class.sort(%w[file10 file2 file1])
      expect(described_class.position(sorted, 'file1')).to eq(0)
      expect(described_class.position(sorted, 'file10')).to eq(2)
    end
  end
end
