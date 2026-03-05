import serial
import matplotlib.pyplot as plt
from dummy_sensor import stream_samples

USE_DUMMY = True

data = []

if USE_DUMMY:
    generator = stream_samples()
else:
    ser = serial.Serial("COM3", 115200)

for _ in range(1000):

    if USE_DUMMY:
        packet = next(generator)
        high, low = packet[0], packet[1]
    else:
        high = ser.read(1)[0]
        low = ser.read(1)[0]

    value = (high << 8) | low
    data.append(value)

plt.plot(data)
plt.title("Sensor Data Stream")
plt.show()