unsigned long lastMicros = 0;
const unsigned long interval = 1000; // 1 kHz = 1000 us

void setup() {
  Serial.begin(115200);
}

void loop() {
  unsigned long now = micros();
  if (now - lastMicros >= interval) {
    lastMicros = now;

    int value = analogRead(A0);

    byte high = value >> 8;
    byte low  = value & 0xFF;

    Serial.write(high);
    Serial.write(low);
  }
}