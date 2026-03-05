# Verification Plan

The digital acquisition system was verified using behavioral simulation in Vivado.

---

## Module-Level Verification

### SPI ADC Master

Testbench: `tb_spi_adc_master.v`

Verified:

• SPI clock generation  
• Chip select timing  
• Correct bit shifting  
• Correct sample capture

---

### FIFO Buffer

Testbench: `tb_fifo.v`

Verified:

• Write operations  
• Read operations  
• FIFO full / empty behavior  
• Correct ordering of samples

---

### UART Transmitter

Testbench: `tb_uart_tx.v`

Verified:

• Start bit generation  
• 8-bit data transmission  
• Stop bit generation  
• Busy signal timing

---

## System-Level Verification

Testbench: `tb_full_system.v`

This verifies the full pipeline:

Sample Tick → SPI ADC → FIFO → UART

Verified behavior:

• periodic sampling  
• sample buffering  
• UART frame generation  
• continuous data streaming

---

## Simulation Artifacts

Waveform captures are available in the `sim/` directory:

• SPI interface behavior  
• FIFO integration  
• UART transmission