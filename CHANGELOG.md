# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-05-20
### Changed
- Updated fastqInputs to be an array of fastqPairs (where fastqR2 is optional)

### Added
- Enhancements to input flexibility
- Added isSingleEnd, fragmentLength, and sd parameters.
- Workflow now detects and supports single-end input FASTQ files.
- Automatically passes --single -l <length> -s <sd> options to kallisto quant when appropriate.

## [Unreleased] - 2025-04-25
### Changed
- Downgrade to kallisto version 0.48.0.

## [1.0.0] - 2025-01-13
### Added
- [GRD-832](https://jira.oicr.on.ca/browse/GRD-832), first verion of the wdl along with README and vidarr files
