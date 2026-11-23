# Changelog

All notable changes to this project are documented in this file. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Register map specification version 1.0 for `aegis_data_acquisition_controller`
- C register header `aegis_data_acquisition_controller_registers.h`
- Team roles and responsibilities in README
- Naming rule (full words, no abbreviations) in CONTRIBUTING
- `ltc2308_spi_controller` with LTC2308 behavioral model and self-checking testbench (18 test cases)
- `averager` (2^N sample average using accumulate and shift) with self-checking testbench (15 test cases)
- `synchronous_fifo` (256 entries, show-ahead read) with self-checking testbench (20 test cases)
- `pwm_generator` (glitch-free period and duty update, force-off input) with self-checking testbench (10 test cases)

### Changed

- Rename directories: `hw` to `hardware`, `aegis_daq_ctrl` to `aegis_data_acquisition_controller`, `sim` to `simulation`
- Rename Platform Designer instances (`sw` to `switch`, `onchip_mem` to `onchip_memory`) and exports (`clock`, `led`, `switch`)
- Rename the `aegis_system` instance in `aegis_top` to `aegis_system_instance`
- Update the board support package settings and the base test application for the new names
- Rewrite README and CONTRIBUTING with the new directory structure
- Register map version 1.1: SCK frequency changed from 2.5 MHz to 12.5 MHz

### Fixed

- `synchronous_fifo`: default `ADDRESS_WIDTH` changed from 9 to 8 to match `DEPTH` = 256; testbench now uses the default parameters

## [0.1.0] - 2026-11-11

### Added

- Quartus project `aegis_top` for the DE10-Standard board (5CSXFC6D6F31C6)
- Platform Designer system `aegis_system`: Nios II/e processor, 128 KB on-chip memory, JTAG UART, 10-bit LED and switch parallel input/output
- Nios II base test application (LED chaser)
- Repository standards: README, contributing guidelines, changelog, pull request and issue templates

### Fixed

- I/O standard assignments not applied to `aegis_top`
- Switch input width mismatch in `aegis_top`