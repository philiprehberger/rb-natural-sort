# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
