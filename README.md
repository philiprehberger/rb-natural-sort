# philiprehberger-natural_sort

[![Tests](https://github.com/philiprehberger/rb-natural-sort/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-natural-sort/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-natural_sort.svg)](https://rubygems.org/gems/philiprehberger-natural_sort)
[![License](https://img.shields.io/github/license/philiprehberger/rb-natural-sort)](LICENSE)
[![Sponsor](https://img.shields.io/badge/sponsor-GitHub%20Sponsors-ec6cb9)](https://github.com/sponsors/philiprehberger)

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

### Case-Sensitive Mode

```ruby
Philiprehberger::NaturalSort.sort(["Banana", "apple"], case_sensitive: true)
# => ["Banana", "apple"]
```

## API

| Method | Description |
|--------|-------------|
| `NaturalSort.sort(array, case_sensitive: false)` | Sort an array of strings in natural order |
| `NaturalSort.sort_by(array, case_sensitive: false) { \|x\| ... }` | Sort by block result in natural order |
| `NaturalSort.compare(a, b, case_sensitive: false)` | Compare two strings, returns -1, 0, or 1 |
| `NaturalSort.comparator(case_sensitive: false)` | Returns a reusable comparison Proc |

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

[MIT](LICENSE)
