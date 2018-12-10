## [Pending Release][0.6.0]

### Breaking changes

* Your contribution here!

### New features

* Your contribution here!

### Bugfixes

* Your contribution here!

## [0.5.1][](2018-12-09)

### Bugfixes

* [#9] Handle reports with no rows.

## [0.5.0][](2018-12-07)

### Breaking changes

* Removed an unused parameter from Report.new.

### New features

* Added `is_data_golden` and `next_page_token` methods to `Row` and `Report`.
* Improved the Yard documentation.

## [0.4.3][](2018-11-28)

### Bugfixes

* [#7] Fix CSV output when no totals requested in GA query.

## [0.4.2][](2018-11-06)

### Bugfixes

* [#6] Correct the conversion of TIME metrics.

## [0.4.1][](2018-10-31)

### Bugfixes

* Fix the faulty attempt to automate requires.

## [0.4.0][](2018-10-31)

### Breaking changes

* The CSV output from the command-line tool may have changed in certain edge cases, like when no dimensions are specified in the query.

### New features

* Report and Row classes for the result make writing Ruby code a little easier.
* [#5] Dimensions and metrics in rows can be accessed by name. See the README.

## [0.3.0][](2018-10-23)

### New features

* [#4] The query can now be specified as a string, a JSON hash, or a regular Ruby hash with symbolic keys.
* [#3] `gaapi` automatically retrieves the Google Analytics-defined maximum of 10,000 rows, unless the user specifies a lower limit.

## [0.2.1][](2018-09-07)

### Breaking changes

### New features

* Documentation changes.

### Bugfixes

* `gaapi` returns appropriate exit status to operating system.

## [0.2.0][0.2.0](2018-09-06)

### Breaking changes

* Refactor code so it's more useful to incorporate in other programs.

### New features

### Bugfixes

## [0.0.1.alpha1][] (2018-08-27)

### Breaking changes

* N/A.

### New features

* N/A.

### Bugfixes

* N/A.

[Pending Release]: https://github.com/weenhanceit/gaapi/compare/v0.5.1...HEAD
[0.5.1]: https://github.com/weenhanceit/gaapi/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/weenhanceit/gaapi/compare/v0.4.3...v0.5.0
[0.4.3]: https://github.com/weenhanceit/gaapi/compare/v0.4.2...v0.4.3
[0.4.2]: https://github.com/weenhanceit/gaapi/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/weenhanceit/gaapi/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/weenhanceit/gaapi/compare/v0.3.0...v0.4.0
