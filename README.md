# AEGIS – SoC Data Acquisition and Control

Course project for **System-on-Chip Practice**, Faculty of Electronics and Telecommunications, University of Science, Vietnam National University Ho Chi Minh City.

| Item | Detail |
|---|---|
| Assigned topic | SoC – Data Acquisition and Control (SPI ADC, PWM and I2C) |
| Project name | AEGIS (Acquisition Engine with Guarded Intelligent Switching) |
| Instructor | Nguyen Nhu Hoang |
| Semester | Semester 1, 2026 |
| Group | 5 |
| Board | Terasic DE10-Standard (Cyclone V 5CSXFC6D6F31C6) |
| Tools | Quartus Prime Lite 18.1, Platform Designer, ModelSim, Nios II Software Build Tools for Eclipse |

## 1. Project Description

The project builds a small SoC on the DE10-Standard board that measures an analog signal, controls a PWM output in a closed loop, and protects the output with a hardware fail-safe. The PWM output is wired back to an ADC input (loopback), so the system can measure its own output without external sensors. A proportional-integral controller on the Nios II processor keeps the measured value at a setpoint chosen with the switches. If the measured value exceeds a threshold, a custom hardware block turns the PWM output off without waiting for the processor.

## 2. Requirements and Approach

| Course requirement | Approach in this project |
|---|---|
| Hardware design (custom IP) | `aegis_data_acquisition_controller`: Avalon Memory-Mapped IP with an SPI controller for the on-board LTC2308 ADC, averager, FIFO, PWM generator, threshold comparator with fail-safe, fault logger |
| System integration (existing IP) | Nios II processor, on-chip memory, JTAG UART, interval timer, parallel input/output, direct memory access controller, I2C master |
| Firmware | Drivers for the custom IP, proportional-integral control loop, interrupt handling, OLED display over I2C |
| Application | On-board display (OLED, seven-segment displays, LEDs) and a Python desktop application for monitoring and setpoint control |

## 3. System Overview

Detailed register definitions are in [docs/register_map.md](docs/register_map.md).

## 4. Progress

| Phase | Content | Status |
|---|---|---|
| 1 | Project setup, base Nios II system (LEDs, switches, JTAG UART) | Done (version 0.1.0), board test pending |
| 2 | Custom IP register-transfer level design and ModelSim simulation | In progress |
| 3 | IP packaging and integration in Platform Designer, Signal Tap tests | Not started |
| 4 | Firmware: drivers, control loop, interrupts, fail-safe, OLED | Not started |
| 5 | Desktop application, hardware versus software fault response measurement | Not started |
| 6 | Report and demonstration | Not started |

## 5. Repository Structure

| Path | Content |
|---|---|
| `docs/` | Register map, diagrams, simulation results, report material |
| `hardware/ip/aegis_data_acquisition_controller/rtl/` | Verilog source of the custom IP |
| `hardware/ip/aegis_data_acquisition_controller/simulation/` | Testbenches and ModelSim scripts |
| `hardware/ip/aegis_data_acquisition_controller/software/` | C register header for the IP |
| `hardware/quartus/` | Quartus project, Platform Designer system, top-level |
| `hardware/quartus/software/` | Nios II application and board support package (Eclipse workspace) |
| `pc_app/` | Python desktop application |

## 6. How to Build

### Hardware

1. Open `hardware/quartus/aegis_top.qpf` in Quartus.
2. Open `aegis_system.qsys` in Platform Designer and click **Generate HDL**.
3. Run **Processing > Start Compilation**.
4. Program `output_files/aegis_top.sof` with the Programmer.

### Firmware

1. Start Eclipse with the workspace `hardware/quartus/software`.
2. Select **File > Import > General > Existing Projects into Workspace** and import `aegis_app` and `aegis_app_bsp`.
3. Right-click `aegis_app_bsp` and select **Nios II > Generate BSP** to regenerate the board support package.
4. Build `aegis_app`, then select **Run As > Nios II Hardware**.

### Simulation

```
cd hardware/ip/aegis_data_acquisition_controller/simulation
vsim -do run_<module>.do
```

## 7. Team

| Number | Name | Student ID | Role | Responsibility |
|---|---|---|---|---|
| 1 | Nguyễn Quốc Trường | 22200172 | ADC interface | `ltc2308_spi_controller`, LTC2308 behavioral model, repository maintainer |
| 2 | Nguyễn Hoàng Tùng | 19200559 | Data path | `averager`, `synchronous_fifo` |
| 3 | Giang Trọng Nhân | 22200112 | Output and protection | `pwm_generator`, `fault_controller` |
| 4 | Phạm Hoàng Gia Bảo | 21200270 | IP top-level | `aegis_data_acquisition_controller` top-level, Avalon interface, top-level testbench |
| 5 | Lê Văn Tiềm | 20200359 | System integration | Base system extension, IP packaging, firmware drivers, lab preparation |

Roles cover Phase 2 (IP design). Assignments for later phases will be updated in this table.

## 8. Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the Git workflow and coding guidelines, and [CHANGELOG.md](CHANGELOG.md) for the version history.