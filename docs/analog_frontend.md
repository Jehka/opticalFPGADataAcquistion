# Analog Front-End Design

The optical sensor interface converts ambient light variations into a voltage suitable for ADC sampling.

---

## Sensor

Light Dependent Resistor (LDR)

LDR resistance varies with light intensity:

Bright light → Low resistance  
Darkness → High resistance

---

## Voltage Divider

The LDR forms a voltage divider with a fixed resistor.
# Analog Front-End Design

The optical sensor interface converts ambient light variations into a voltage suitable for ADC sampling.

---

## Sensor

Light Dependent Resistor (LDR)

LDR resistance varies with light intensity:

Bright light → Low resistance  
Darkness → High resistance

---

## Voltage Divider

The LDR forms a voltage divider with a fixed resistor.
3.3V
↓
LDR
↓
Vout → ADC Input
↓
10kΩ
↓
GND

This converts resistance changes into measurable voltage variations.

---

## Anti-Alias Filter

A first-order RC filter limits the analog bandwidth.
Vout → 10kΩ → ADC Input
|
150nF
|
GND

Cutoff frequency:

fc = 1 / (2πRC)

Using:

R = 10kΩ  
C = 150nF  

fc ≈ **106 Hz**

---

## Sampling Relationship

Sampling Rate = 1 kHz  
Nyquist Frequency = 500 Hz  

Filter cutoff ≈ 100 Hz ensures strong attenuation before Nyquist.

---

## LTSpice Simulation

The LDR circuit and filter were simulated in LTSpice to verify:

• Voltage response to light changes  
• Filter cutoff behavior  
• Expected signal range