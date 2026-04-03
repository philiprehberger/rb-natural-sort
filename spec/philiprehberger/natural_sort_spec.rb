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
end
