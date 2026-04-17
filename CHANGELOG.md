# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.7.0] - 2026-04-16

### Added
- `sort_index` method returning original indices in natural sort order, with `case_sensitive:` and `reverse:` keyword support

## [0.6.0] - 2026-04-15

### Added
- `between?` method to check if a value falls within a natural sort range [min, max] inclusive

## [0.5.0] - 2026-04-14

### Added
- `ignore_case:` keyword parameter on `sort` and `sort_by` — when true, downcases sort keys before comparison
- `group_by_prefix` method to split strings at the first digit boundary and group by non-numeric prefix
- `collate` method as a spaceship-style comparator returning -1, 0, or 1

## [0.4.0] - 2026-04-11

### Added
- `natural_key` method for use with Ruby's built-in `sort_by`, `min_by`, `max_by`, and other Enumerable methods
- `sort_by_stable` for stable sorting with a key extractor block, preserving original order for equal elements

### Fixed
- Bug report template: add reproduction placeholder and mark gem version as required
- Feature request template: add proposed API placeholder

## [0.3.1] - 2026-04-08

### Changed
- Align gemspec summary with README description.

## [0.3.0] - 2026-04-04

### Added
- `sort_naturally_by` method via `ArrayRefinement` for block-based key extraction on arrays

## [0.2.0] - 2026-04-03

### Added
- Reverse sort option via `reverse:` parameter on `sort` and `sort_by`
- Stable sort via `sort_stable` preserving original order for equal elements
- `min` and `max` methods for finding extremes without full sort

## [0.1.4] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.3] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.2] - 2026-03-26

### Changed
- Add Sponsor badge to README
- Fix License section format
- Sync gemspec summary with README

## [0.1.1] - 2026-03-26

### Added

- Add GitHub funding configuration

## [0.1.0] - 2026-03-26

### Added
- Initial release
- `NaturalSort.sort` for natural order sorting of string arrays
- `NaturalSort.sort_by` for sorting by block result in natural order
- `NaturalSort.compare` for comparing two strings naturally
- `NaturalSort.comparator` returns a reusable comparison Proc
- Case-sensitive and case-insensitive modes
