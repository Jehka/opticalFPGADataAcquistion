import time
import math
import random

def generate_sample(t):
    signal = 500 + 200 * math.sin(2 * math.pi * 0.5 * t)
    noise = random.uniform(-20, 20)
    return int(signal + noise)

def stream_samples(rate=1000):
    t = 0
    dt = 1 / rate
    while True:
        value = generate_sample(t)
        high = (value >> 8) & 0xFF
        low = value & 0xFF

        yield bytes([high, low])

        t += dt
        time.sleep(dt)
        