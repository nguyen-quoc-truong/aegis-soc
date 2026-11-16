# AEGIS Data Acquisition Controller – Register Map Specification

| Item | Value |
|---|---|
| IP name | `aegis_data_acquisition_controller` |
| Document version | 1.1 |
| Status | Frozen (changes require group approval through a pull request) |
| Target | DE10-Standard board (Cyclone V 5CSXFC6D6F31C6), Nios II processor |
| Clock | 50 MHz, single clock domain |

## Revision History

| Version | Date | Author | Changes |
|---|---|---|---|
| 1.0 | 2026-11-15 | AEGIS group | Initial frozen register map |
| 1.1 | 2026-11-16 | AEGIS group | SCK frequency changed to 12.5 MHz so one frame fits in the minimum sample period |
---

## 1. Overview

`aegis_data_acquisition_controller` is an Avalon Memory-Mapped slave IP that provides:

- LTC2308 SPI ADC controller with automatic periodic sampling
- Hardware averager (2^N samples)
- 256-entry sample FIFO
- 4-channel PWM generator with glitch-free duty update
- Threshold comparator with hardware fail-safe (PWM cut-off without the processor)
- Fault event logger (timestamp and value)
- Level-sensitive interrupt output

## 2. Interface Summary

### 2.1 Avalon Memory-Mapped Slave

| Parameter | Value |
|---|---|
| Data width | 32 bits |
| Address width | 5 bits (word addressing, 32 words) |
| Address span | 0x80 bytes |
| Read wait states | 1 (fixed) |
| Write wait states | 0 |

### 2.2 Conduit Signals

| Signal | Direction | Width | Description |
|---|---|---|---|
| `adc_convst` | Output | 1 | LTC2308 CONVST pin |
| `adc_sck` | Output | 1 | LTC2308 SCK pin (12.5 MHz) |
| `adc_sdi` | Output | 1 | LTC2308 SDI pin (configuration word) |
| `adc_sdo` | Input | 1 | LTC2308 SDO pin (conversion data) |
| `pwm_out` | Output | 4 | PWM outputs, channel 0 to 3 |

### 2.3 Interrupt

| Signal | Type | Description |
|---|---|---|
| `interrupt` | Level, active high | `interrupt = OR(INTERRUPT_STATUS AND INTERRUPT_ENABLE)` |

## 3. Conventions

### 3.1 Addressing

The Nios II processor accesses registers with `IORD(BASE, offset)` and `IOWR(BASE, offset, value)`,
where `offset` is the **word** offset. Byte address = `BASE + 4 × offset`.

### 3.2 Access Types

| Access type | Meaning |
|---|---|
| Read/Write | The register can be read and written |
| Read-only | Writes are ignored |
| Read-to-clear | Read-only; reading has a side effect (clears a flag or removes data), applied once per read transfer |
| Write-one-to-clear | Readable; writing 1 clears the bit, writing 0 has no effect |
| Self-clearing | Writing 1 triggers an action; the bit always reads 0 |
| Reserved | Reads 0, writes are ignored |

### 3.3 Data Format

- ADC: LTC2308, 4.096 V reference, unipolar, 12 bits, so **1 least significant bit = 1 millivolt**
- Sample word format (ADC_RAW_SAMPLE, FIFO_DATA): bits `[14:12]` channel, bits `[11:0]` value

---

## 4. Register Summary

| Word offset | Byte offset | Name | Access | Reset value | Description |
|---|---|---|---|---|---|
| 0x00 | 0x00 | CONTROL | Read/Write, Self-clearing | 0x0000_0000 | Global control |
| 0x01 | 0x04 | ADC_CONFIG | Read/Write | 0x0000_0040 | ADC channel and averaging |
| 0x02 | 0x08 | SAMPLE_DIVIDER | Read/Write | 0x0000_01F4 | Sampling period |
| 0x03 | 0x0C | STATUS | Read-only | 0x0000_0008 | Status flags |
| 0x04 | 0x10 | ADC_RAW_SAMPLE | Read-to-clear | 0x0000_0000 | Latest raw sample |
| 0x05 | 0x14 | ADC_AVERAGE | Read-to-clear | 0x0000_0000 | Latest averaged value |
| 0x06 | 0x18 | FIFO_DATA | Read-to-clear | 0x0000_0000 | FIFO read port |
| 0x07 | 0x1C | FIFO_COUNT | Read-only | 0x0000_0000 | FIFO fill level |
| 0x08 | 0x20 | THRESHOLD_HIGH | Read/Write | 0x0000_0FFF | High threshold |
| 0x09 | 0x24 | THRESHOLD_LOW | Read/Write | 0x0000_0000 | Low threshold |
| 0x0A | 0x28 | FAULT_TIME | Read-only | 0x0000_0000 | Timestamp at fault |
| 0x0B | 0x2C | FAULT_VALUE | Read-only | 0x0000_0000 | ADC value at fault |
| 0x0C | 0x30 | INTERRUPT_ENABLE | Read/Write | 0x0000_0000 | Interrupt enable |
| 0x0D | 0x34 | INTERRUPT_STATUS | Write-one-to-clear | 0x0000_0000 | Interrupt status |
| 0x0E | 0x38 | TIMESTAMP | Read-only | 0x0000_0000 | Free-running counter |
| 0x0F | 0x3C | — | Reserved | 0x0000_0000 | Reserved |
| 0x10 | 0x40 | PWM_PERIOD_0 | Read/Write | 0x0000_0000 | PWM channel 0 period |
| 0x11 | 0x44 | PWM_DUTY_0 | Read/Write | 0x0000_0000 | PWM channel 0 duty |
| 0x12 | 0x48 | PWM_PERIOD_1 | Read/Write | 0x0000_0000 | PWM channel 1 period |
| 0x13 | 0x4C | PWM_DUTY_1 | Read/Write | 0x0000_0000 | PWM channel 1 duty |
| 0x14 | 0x50 | PWM_PERIOD_2 | Read/Write | 0x0000_0000 | PWM channel 2 period |
| 0x15 | 0x54 | PWM_DUTY_2 | Read/Write | 0x0000_0000 | PWM channel 2 duty |
| 0x16 | 0x58 | PWM_PERIOD_3 | Read/Write | 0x0000_0000 | PWM channel 3 period |
| 0x17 | 0x5C | PWM_DUTY_3 | Read/Write | 0x0000_0000 | PWM channel 3 duty |
| 0x18 to 0x1F | 0x60 to 0x7C | — | Reserved | 0x0000_0000 | Reserved |

---

## 5. Register Descriptions

### 5.1 CONTROL (0x00)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:5 | — | Reserved | 0 | Reserved |
| 4 | FAULT_CLEAR | Self-clearing | 0 | Write 1: clear FAULT, fault source bits, FAULT_TIME and FAULT_VALUE |
| 3 | SOFTWARE_FAULT | Self-clearing | 0 | Write 1: trigger a software fault (to test the fail-safe) |
| 2 | FAILSAFE_ENABLE | Read/Write | 0 | 1: force all PWM outputs low while FAULT = 1 |
| 1 | PWM_ENABLE | Read/Write | 0 | 1: enable the PWM generator (all channels) |
| 0 | ADC_ENABLE | Read/Write | 0 | 1: enable periodic ADC sampling |

### 5.2 ADC_CONFIG (0x01)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:7 | — | Reserved | 0 | Reserved |
| 6:4 | AVERAGE_EXPONENT | Read/Write | 4 | Average 2^AVERAGE_EXPONENT samples (1 to 128). 0 means no averaging |
| 3 | — | Reserved | 0 | Reserved |
| 2:0 | CHANNEL | Read/Write | 0 | ADC input channel (0 to 7) |

> The LTC2308 applies a new channel configuration to the **next** conversion.
> The first sample after changing CHANNEL still belongs to the previous channel.
> The channel field in ADC_RAW_SAMPLE and FIFO_DATA always reflects the actual channel.
> Writing ADC_CONFIG restarts the averager.

### 5.3 SAMPLE_DIVIDER (0x02)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:16 | — | Reserved | 0 | Reserved |
| 15:0 | DIVIDER | Read/Write | 500 | Clock cycles between two conversion starts |

- Sample rate = 50 MHz / DIVIDER. The reset value 500 gives 100,000 samples per second.
- Minimum DIVIDER = 300 (one conversion frame takes about 6 microseconds). Smaller values are treated as 300.

### 5.4 STATUS (0x03)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:10 | — | Reserved | 0 | Reserved |
| 9 | FAULT_SOFTWARE | Read-only | 0 | Fault caused by SOFTWARE_FAULT (latched) |
| 8 | FAULT_LOW | Read-only | 0 | Fault caused by ADC_AVERAGE < THRESHOLD_LOW (latched) |
| 7 | FAULT_HIGH | Read-only | 0 | Fault caused by ADC_AVERAGE > THRESHOLD_HIGH (latched) |
| 6 | FAULT | Read-only | 0 | Fault active (latched until FAULT_CLEAR) |
| 5 | FIFO_FULL | Read-only | 0 | FIFO count = 256 |
| 4 | FIFO_HALF_FULL | Read-only | 0 | FIFO count ≥ 128 |
| 3 | FIFO_EMPTY | Read-only | 1 | FIFO count = 0 |
| 2 | NEW_AVERAGE | Read-only | 0 | New value in ADC_AVERAGE, cleared by reading ADC_AVERAGE |
| 1 | NEW_RAW_SAMPLE | Read-only | 0 | New value in ADC_RAW_SAMPLE, cleared by reading ADC_RAW_SAMPLE |
| 0 | ADC_BUSY | Read-only | 0 | A conversion frame is in progress |

### 5.5 ADC_RAW_SAMPLE (0x04)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:15 | — | Reserved | 0 | Reserved |
| 14:12 | CHANNEL | Read-to-clear | 0 | Channel of this sample |
| 11:0 | VALUE | Read-to-clear | 0 | Raw sample in millivolts. Reading clears STATUS.NEW_RAW_SAMPLE |

### 5.6 ADC_AVERAGE (0x05)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:12 | — | Reserved | 0 | Reserved |
| 11:0 | VALUE | Read-to-clear | 0 | Average of the last 2^AVERAGE_EXPONENT samples in millivolts. Reading clears STATUS.NEW_AVERAGE |

### 5.7 FIFO_DATA (0x06)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:15 | — | Reserved | 0 | Reserved |
| 14:12 | CHANNEL | Read-to-clear | 0 | Channel |
| 11:0 | VALUE | Read-to-clear | 0 | Averaged value in millivolts |

- Each read removes one entry. Reading an empty FIFO returns 0 and removes nothing.
- Every new ADC_AVERAGE result is written into the FIFO. When the FIFO is full, new results are dropped.

### 5.8 FIFO_COUNT (0x07)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:9 | — | Reserved | 0 | Reserved |
| 8:0 | COUNT | Read-only | 0 | Number of entries in the FIFO (0 to 256) |

### 5.9 THRESHOLD_HIGH (0x08)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:12 | — | Reserved | 0 | Reserved |
| 11:0 | THRESHOLD | Read/Write | 0xFFF | Fault when ADC_AVERAGE > THRESHOLD. 0xFFF never triggers |

### 5.10 THRESHOLD_LOW (0x09)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:12 | — | Reserved | 0 | Reserved |
| 11:0 | THRESHOLD | Read/Write | 0 | Fault when ADC_AVERAGE < THRESHOLD. 0 disables the low threshold |

### 5.11 FAULT_TIME (0x0A)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:0 | TIME | Read-only | 0 | TIMESTAMP value captured at the first fault event |

### 5.12 FAULT_VALUE (0x0B)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:12 | — | Reserved | 0 | Reserved |
| 11:0 | VALUE | Read-only | 0 | ADC_AVERAGE value captured at the first fault event (0 for a software fault) |

### 5.13 INTERRUPT_ENABLE (0x0C)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:3 | — | Reserved | 0 | Reserved |
| 2 | FAULT | Read/Write | 0 | Enable the fault interrupt |
| 1 | FIFO_HALF_FULL | Read/Write | 0 | Enable the FIFO half-full interrupt |
| 0 | NEW_AVERAGE | Read/Write | 0 | Enable the new-average interrupt |

### 5.14 INTERRUPT_STATUS (0x0D)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:3 | — | Reserved | 0 | Reserved |
| 2 | FAULT | Write-one-to-clear | 0 | Set on the rising edge of STATUS.FAULT |
| 1 | FIFO_HALF_FULL | Write-one-to-clear | 0 | Set when the FIFO count reaches 128 |
| 0 | NEW_AVERAGE | Write-one-to-clear | 0 | Set when a new ADC_AVERAGE value is produced |

> INTERRUPT_STATUS bits are set regardless of INTERRUPT_ENABLE. INTERRUPT_ENABLE only gates the `interrupt` output.

### 5.15 TIMESTAMP (0x0E)

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:0 | COUNT | Read-only | 0 | Increments every clock cycle (20 nanoseconds), wraps after about 85.9 seconds |

### 5.16 PWM_PERIOD_n (0x10 + 2n), n = 0 to 3

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:16 | — | Reserved | 0 | Reserved |
| 15:0 | PERIOD | Read/Write | 0 | Period in clock cycles. 0 keeps the channel output low |

PWM frequency = 50 MHz / PERIOD. For example, PERIOD = 5000 gives 10 kHz.

### 5.17 PWM_DUTY_n (0x11 + 2n), n = 0 to 3

| Bits | Name | Access | Reset | Description |
|---|---|---|---|---|
| 31:16 | — | Reserved | 0 | Reserved |
| 15:0 | DUTY | Read/Write | 0 | High time in clock cycles. DUTY ≥ PERIOD gives 100% duty |

> PERIOD and DUTY are latched at the start of each PWM period (glitch-free update).

---

## 6. Functional Behavior

### 6.1 Fault Detection and Fail-safe

| Condition | Source bit set |
|---|---|
| ADC_AVERAGE > THRESHOLD_HIGH | FAULT_HIGH |
| THRESHOLD_LOW ≠ 0 and ADC_AVERAGE < THRESHOLD_LOW | FAULT_LOW |
| Write 1 to CONTROL.SOFTWARE_FAULT | FAULT_SOFTWARE |

1. The comparison is done on every new ADC_AVERAGE value, not on raw samples.
2. On the first fault event: FAULT = 1, FAULT_TIME and FAULT_VALUE are captured, INTERRUPT_STATUS.FAULT = 1.
3. If FAILSAFE_ENABLE = 1, all `pwm_out` outputs go low on the next clock edge (at most 20 nanoseconds after the fault event).
4. Further faults set additional source bits but do not overwrite FAULT_TIME and FAULT_VALUE.
5. FAULT stays latched until CONTROL.FAULT_CLEAR is written. PWM output resumes from the next period.

### 6.2 Data Path

```
LTC2308 --SPI--> ADC_RAW_SAMPLE --> Averager (2^N) --> ADC_AVERAGE --> FIFO --> FIFO_DATA
                                                           |
                                                           +--> Threshold comparator --> FAULT
```

---

## 7. Programming Sequences

### 7.1 Initialization

1. Write `CONTROL = 0` (stop everything).
2. Write `ADC_CONFIG` (channel, average exponent) and `SAMPLE_DIVIDER`.
3. Write `THRESHOLD_HIGH` and `THRESHOLD_LOW`.
4. Write `PWM_PERIOD_n` and `PWM_DUTY_n`.
5. Write `INTERRUPT_STATUS = 0x7` (clear pending interrupts), then `INTERRUPT_ENABLE`.
6. Write `CONTROL = ADC_ENABLE | PWM_ENABLE | FAILSAFE_ENABLE`.

### 7.2 Polling an Averaged Sample

1. Wait until `STATUS.NEW_AVERAGE = 1`.
2. Read `ADC_AVERAGE`. The value in millivolts is `ADC_AVERAGE & 0xFFF`.

### 7.3 Interrupt Service Routine

1. Read `INTERRUPT_STATUS`.
2. If FAULT is set: read `STATUS`, `FAULT_TIME`, `FAULT_VALUE`, and report the fault.
3. If FIFO_HALF_FULL is set: read `FIFO_COUNT` entries from `FIFO_DATA`.
4. If NEW_AVERAGE is set: read `ADC_AVERAGE`.
5. Write the handled bits back to `INTERRUPT_STATUS` to clear them.

### 7.4 Fault Recovery

1. Remove the cause of the fault, or adjust the thresholds.
2. Write `CONTROL` with `FAULT_CLEAR = 1`, keeping the other enable bits.
3. Check that `STATUS.FAULT = 0`.

---

## 8. Firmware Reference

C definitions: `hardware/ip/aegis_data_acquisition_controller/software/aegis_data_acquisition_controller_registers.h`

```c
#include "system.h"
#include "aegis_data_acquisition_controller_registers.h"

#define AEGIS_BASE AEGIS_DATA_ACQUISITION_CONTROLLER_0_BASE

void aegis_initialize(void){
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_CONTROL,0);
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_ADC_CONFIG,AEGIS_ADC_CONFIG_VALUE(0,6));
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_SAMPLE_DIVIDER,500);
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_THRESHOLD_HIGH,3000);
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_PWM_PERIOD(0),5000);
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_PWM_DUTY(0),2500);
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_INTERRUPT_STATUS,0x7);
	AEGIS_WRITE(AEGIS_BASE,AEGIS_REGISTER_CONTROL,AEGIS_CONTROL_ADC_ENABLE|AEGIS_CONTROL_PWM_ENABLE|AEGIS_CONTROL_FAILSAFE_ENABLE);
}
```

> `AEGIS_DATA_ACQUISITION_CONTROLLER_0_BASE` depends on the component instance name in Platform Designer. Check `system.h`.