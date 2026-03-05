# System Overview

This project implements a complete FPGA-based sensor data acquisition pipeline for optical sensing applications.

The system samples an analog light sensor, digitizes the signal, buffers the samples, and streams them to a host computer.

---

## Architecture

![Architecture](docs/architecture.png)
---

## Sampling Strategy

Sampling Rate: **1 kHz**

Analog Filter Cutoff: **~100 Hz**

Filter Components:

R = 10kΩ  
C = 150nF  

This ensures adequate anti-alias filtering before digitization.

---

## RTL Modules

| Module | Description |
|------|------|
| `spi_adc_master` | SPI FSM controller for ADC communication |
| `sample_tick_gen` | Generates deterministic 1 kHz sampling pulse |
| `fifo_buffer` | Buffers samples between acquisition and transmission |
| `uart_controller` | Frames sensor samples into UART packets |
| `uart_tx` | Serial transmitter (115200 baud) |
| `adc_interface` | ADC abstraction wrapper |
| `top` | System integration module |

---

## Data Pipeline

Sensor Data → ADC → FPGA Processing → UART Stream → Host Logger
