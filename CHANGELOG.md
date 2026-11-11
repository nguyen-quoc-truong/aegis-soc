# Changelog

All notable changes to this project are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-11-11

### Added
- Quartus project `aegis_top` for DE10-Standard (5CSXFC6D6F31C6)
- Platform Designer system `aegis_system`: Nios II/e, 128 KB on-chip memory, JTAG UART, 10-bit LED and switch PIOs
- Nios II base test application (LED chaser)
- Repository standards: README, contributing guidelines, changelog, PR and issue templates

### Fixed
- I/O standard assignments not applied to `aegis_top`
- Switch input width mismatch in `aegis_top`
