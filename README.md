# AEGIS – SoC Data Acquisition & Control

Course project for **System-on-Chip Practice (TH SoC)**
Faculty of Electronics and Telecommunications, University of Science, VNU-HCM

| | |
|---|---|
| Assigned topic | SoC – Data Acquisition & Control (SPI ADC + PWM/I2C) |
| Project name | AEGIS (Acquisition Engine with Guarded Intelligent Switching) |
| Instructor | Nguyen Nhu Hoang |
| Semester | Semester 1, 2026 |
| Group | 5 |
| Board | Terasic DE10-Standard (Cyclone V 5CSXFC6D6F31C6) |
| Tools | Quartus Prime Lite 18.1, Platform Designer, ModelSim, Nios II SBT for Eclipse |

## 1. Project Description
The project builds a small SoC on the DE10-Standard board that measures an analog signal, controls a PWM output in a closed loop, and protects the output with a hardware fail-safe.
The PWM output is wired back to an ADC input (loopback), so the system can measure its own output without external sensors. A PI controller on the Nios II keeps the measured value at a setpoint chosen with the switches. If the measured value exceeds a threshold, a custom hardware block turns the PWM off without waiting for the CPU.

## 2. Requirements and Approach
| Course requirement | Approach in this project |
|---|---|
| Hardware design (custom IP) | `aegis_daq_ctrl`: Avalon-MM IP with SPI controller for the on-board LTC2308 ADC, averager, FIFO, PWM generator, threshold comparator with fail-safe, fault logger |
| System integration (existing IPs) | Nios II, on-chip memory, JTAG UART, Interval Timer, PIO, DMA, I2C master |
| Firmware | Drivers for the custom IP, PI control loop, interrupt handling, OLED display over I2C |
| Application | On-board display (OLED, HEX, LEDR) and a Python PC application for monitoring and setpoint control |

## 3. System Overview
Detailed register definitions: [docs/register_map.md](docs/register_map.md)

## 4. Progress
| Phase | Content | Status |
|---|---|---|
| 1 | Project setup, base Nios II system (LED, switches, JTAG UART) | Done (v0.1.0), board test pending |
| 2 | Custom IP RTL design and ModelSim simulation | In progress |
| 3 | IP packaging and integration in Platform Designer, Signal Tap tests | Not started |
| 4 | Firmware: drivers, PI loop, interrupts, fail-safe, OLED | Not started |
| 5 | PC application, hardware vs. software fault response measurement | Not started |
| 6 | Report and demo | Not started |

## 5. Repository Structure
| Path | Content |
|---|---|
| `docs/` | Register map, diagrams, simulation results, report material |
| `hw/ip/aegis_daq_ctrl/rtl/` | Verilog source of the custom IP |
| `hw/ip/aegis_daq_ctrl/sim/` | Testbenches and ModelSim scripts |
| `hw/ip/aegis_daq_ctrl/sw/` | C register header for the IP |
| `hw/quartus/` | Quartus project, Platform Designer system, top-level |
| `hw/quartus/software/` | Nios II application and BSP (Eclipse workspace) |
| `pc_app/` | Python PC application |

## 6. How to Build
### Hardware
1. Open `hw/quartus/aegis_top.qpf` in Quartus.
2. Open `aegis_system.qsys` in Platform Designer and click **Generate HDL**.
3. Run **Processing > Start Compilation**.
4. Program `output_files/aegis_top.sof` with the Programmer.

### Firmware
1. Start Eclipse with workspace `hw/quartus/software`.
2. **File > Import > General > Existing Projects into Workspace**, import `aegis_app` and `aegis_app_bsp`.
3. Right-click `aegis_app_bsp` > **Nios II > Generate BSP**.
4. Build `aegis_app`, then **Run As > Nios II Hardware**.

### Simulation
```
cd hw/ip/aegis_daq_ctrl/sim
vsim -do run_<module>.do
```

## 7. Team
| No. | Name | Student ID |
|---|---|---|
| 1 | Phạm Hoàng Gia Bảo | 21200270 |
| 2 | Giang Trọng Nhân | 22200112 |
| 3 | Lê Văn Tiềm | 20200359 |
| 4 | Nguyễn Hoàng Tùng | 19200559 |
| 5 | Nguyễn Quốc Trường | 22200172 |

Task assignment will be added once the group has finalized it.

## 8. Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for the Git workflow and coding guidelines, and [CHANGELOG.md](CHANGELOG.md) for version history.