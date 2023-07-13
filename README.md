# philiprehberger-natural_sort

[![Tests](https://github.com/philiprehberger/rb-natural-sort/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-natural-sort/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-natural_sort.svg)](https://rubygems.org/gems/philiprehberger-natural_sort)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-natural-sort)](https://github.com/philiprehberger/rb-natural-sort/commits/main)

Human-friendly natural sorting — "file2" before "file10"

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-natural_sort"
```

Or install directly:

```bash
gem install philiprehberger-natural_sort
```

## Usage

```ruby
require "philiprehberger/natural_sort"

sorted = Philiprehberger::NaturalSort.sort(["file10", "file2", "file1"])
# => ["file1", "file2", "file10"]
```

### Sorting with a Block

```ruby
items = [{ name: "img10" }, { name: "img2" }, { name: "img1" }]
sorted = Philiprehberger::NaturalSort.sort_by(items) { |x| x[:name] }
# => [{ name: "img1" }, { name: "img2" }, { name: "img10" }]
```

### Sorting with a Refinement

Use the `ArrayRefinement` to call `sort_naturally_by` directly on arrays:

```ruby
using Philiprehberger::NaturalSort::ArrayRefinement

items = [
  OpenStruct.new(name: "img10"),
  OpenStruct.new(name: "img2"),
  OpenStruct.new(name: "img1")
]
items.sort_naturally_by { |x| x.name }
# => [#<OpenStruct name="img1">, #<OpenStruct name="img2">, #<OpenStruct name="img10">]
```

### Comparing Two Strings

```ruby
Philiprehberger::NaturalSort.compare("file2", "file10")
# => -1

Philiprehberger::NaturalSort.compare("file10", "file2")
# => 1
```

### Using a Comparator Proc

```ruby
cmp = Philiprehberger::NaturalSort.comparator
["file10", "file2", "file1"].sort(&cmp)
# => ["file1", "file2", "file10"]
```

### Reverse Sorting

```ruby
Philiprehberger::NaturalSort.sort(["file10", "file2", "file1"], reverse: true)
# => ["file10", "file2", "file1"]

items = [{ name: "img10" }, { name: "img2" }, { name: "img1" }]
sorted = Philiprehberger::NaturalSort.sort_by(items, reverse: true) { |x| x[:name] }
# => [{ name: "img10" }, { name: "img2" }, { name: "img1" }]
```

### Stable Sorting

Preserves original order for elements that compare as equal:

```ruby
Philiprehberger::NaturalSort.sort_stable(["file1", "FILE1", "file2"])
# => ["file1", "FILE1", "file2"]
```

### Min and Max

Find the naturally smallest or largest element without a full sort:

```ruby
Philiprehberger::NaturalSort.min(["file10", "file2", "file1"])
# => "file1"

Philiprehberger::NaturalSort.max(["file10", "file2", "file1"])
# => "file10"
```

### Sort Key for Built-in Methods

Use `natural_key` with Ruby's standard `sort_by`, `min_by`, `max_by`, `group_by`, and other Enumerable methods:

```ruby
files = ["file10.txt", "file2.txt", "file1.txt"]
files.sort_by { |f| Philiprehberger::NaturalSort.natural_key(f) }
# => ["file1.txt", "file2.txt", "file10.txt"]

files.min_by { |f| Philiprehberger::NaturalSort.natural_key(f) }
# => "file1.txt"
```

### Stable Sort with Block

Preserves original order for elements whose block values compare as equal:

```ruby
items = [
  { name: "file1", id: "a" },
  { name: "FILE1", id: "b" },
  { name: "file2", id: "c" }
]
sorted = Philiprehberger::NaturalSort.sort_by_stable(items) { |x| x[:name] }
# => [{ name: "file1", id: "a" }, { name: "FILE1", id: "b" }, { name: "file2", id: "c" }]
```

### Case-Sensitive Mode

```ruby
Philiprehberger::NaturalSort.sort(["Banana", "apple"], case_sensitive: true)
# => ["Banana", "apple"]
```

## API

| Method | Description |
|--------|-------------|
| `NaturalSort.sort(array, case_sensitive: false, reverse: false)` | Sort an array of strings in natural order |
| `NaturalSort.sort_by(array, case_sensitive: false, reverse: false) { \|x\| ... }` | Sort by block result in natural order |
| `NaturalSort.sort_stable(array, case_sensitive: false)` | Stable sort preserving original order for equal elements |
| `NaturalSort.min(array, case_sensitive: false)` | Find the naturally smallest element |
| `NaturalSort.max(array, case_sensitive: false)` | Find the naturally largest element |
| `NaturalSort.compare(a, b, case_sensitive: false)` | Compare two strings, returns -1, 0, or 1 |
| `NaturalSort.comparator(case_sensitive: false)` | Returns a reusable comparison Proc |
| `NaturalSort.natural_key(str, case_sensitive: false)` | Returns a sort key for use with `sort_by`, `min_by`, etc. |
| `NaturalSort.sort_by_stable(array, case_sensitive: false) { \|x\| ... }` | Stable sort by block result preserving order for equal elements |
| `array.sort_naturally_by { \|x\| ... }` | Sort array by block result (via `ArrayRefinement`) |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-natural-sort)

🐛 [Report issues](https://github.com/philiprehberger/rb-natural-sort/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-natural-sort/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
