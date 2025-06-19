
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include "DHT.h"
#include <Wire.h>
#include <Adafruit_GFX.h>
#include <Adafruit_SSD1306.h>

// OLED display parameters
#define SCREEN_WIDTH 128
#define SCREEN_HEIGHT 64
#define OLED_RESET -1
#define SCREEN_ADDRESS 0x3C

Adafruit_SSD1306 display(SCREEN_WIDTH, SCREEN_HEIGHT, &Wire, OLED_RESET);

// WiFi credentials
const char* ssid = "hfsha";
const char* password = "12345678";

// API configuration
const char* serverUrl = "https://humancc.site/shahidatulhidayah/smart-elderly-app/api/sensor/data.php";
const char* deviceId = "ELDERLY_MONITOR_001"; // Unique device ID

// Sensor pins
#define DHTPIN 4
#define DHTTYPE DHT11
#define PIR_PIN 32
#define VIBRATION_PIN 33
#define FLAME_PIN 34
#define BUZZER_PIN 18
#define RELAY_PIN 25

// Sensor thresholds
#define VIBRATION_THRESHOLD 2000
#define FLAME_THRESHOLD 1500

// Variables
DHT dht(DHTPIN, DHTTYPE);
bool motionDetected = false;
bool fallDetected = false;
bool fireDetected = false;
float temperature = 0;
float humidity = 0;
unsigned long lastUploadTime = 0;
const unsigned long uploadInterval = 10000; // 10 seconds

// --- Sticky alert variables ---
unsigned long fallDetectedUntil = 0;
unsigned long fireDetectedUntil = 0;
const unsigned long alertStickyDuration = 30000; // 30 seconds

// --- Relay polling variables ---
bool relayState = false; // Current relay state from backend
unsigned long lastRelayPollTime = 0;
const unsigned long relayPollInterval = 5000; // 5 seconds

// --- Emergency trigger state ---
static bool emergencyTriggered = false;

void setup() {
  Serial.begin(115200);

  // Initialize sensors
  pinMode(PIR_PIN, INPUT);
  pinMode(VIBRATION_PIN, INPUT);
  pinMode(FLAME_PIN, INPUT);
  pinMode(BUZZER_PIN, OUTPUT);
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(BUZZER_PIN, LOW);
  digitalWrite(RELAY_PIN, LOW);

  dht.begin();

  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.println("Connecting to WiFi...");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
  Serial.println("IP address: ");
  Serial.println(WiFi.localIP());

  // Initialize OLED display
  if(!display.begin(SSD1306_SWITCHCAPVCC, SCREEN_ADDRESS)) {
    Serial.println(F("SSD1306 allocation failed"));
    for(;;);
  }
  display.clearDisplay();
  display.setTextSize(1);
  display.setTextColor(SSD1306_WHITE);
  display.setCursor(0,0);
  display.println("Smart Elderly App");
  display.display();
}

void loop() {
  // Read sensors
  readSensors();

  // // --- Emergency triggers relay ON (local and backend), only once per event ---
  // if ((fireDetected || fallDetected) && !emergencyTriggered) {
  //   digitalWrite(RELAY_PIN, HIGH); // Local relay ON immediately
  //   sendRelayCommand(true);        // Inform backend/app
  //   relayState = true;             // Update local state
  //   emergencyTriggered = true;
  //   Serial.println("Emergency detected: Relay ON (local + backend)");
  // }

  // // Reset trigger when emergency is cleared
  // if (!fireDetected && !fallDetected && emergencyTriggered) {
  //   emergencyTriggered = false;
  // }

  // Send data to server periodically
  if (millis() - lastUploadTime >= uploadInterval) {
    sendSensorData();
    lastUploadTime = millis();
  }

  // --- Poll relay state from backend periodically ---
  if (millis() - lastRelayPollTime >= relayPollInterval) {
    relayState = fetchRelayState();
    lastRelayPollTime = millis();
    // Set relay according to backend state
    digitalWrite(RELAY_PIN, relayState ? HIGH : LOW);
    Serial.print("Relay state from backend: ");
    Serial.println(relayState ? "ON" : "OFF");
  }

  // --- Buzzer logic: only ON if fire or fall detected ---
  if (fireDetected || fallDetected) {
    digitalWrite(BUZZER_PIN, HIGH);
  } else {
    digitalWrite(BUZZER_PIN, LOW);
  }

  // Update OLED display periodically (non-blocking)
  static int oledDisplayState = 0; // 0: Temp, 1: Humidity, 2: Motion, 3: Fall, 4: Fire
  static unsigned long lastOLEDUpdate = 0;
  const unsigned long oledDisplayDuration = 3000; // Display each screen for 3 seconds

  if (millis() - lastOLEDUpdate >= oledDisplayDuration) {
    display.clearDisplay();
    display.setTextSize(2);
    display.setTextColor(SSD1306_WHITE);

    switch (oledDisplayState) {
      case 0:
        display.setCursor(0, 24);
        display.print("TEMP: ");
        display.print(temperature);
        display.println(" C");
        break;
      case 1:
        display.setCursor(0, 24);
        display.print("HUMIDITY: ");
        display.print(humidity);
        display.println(" %");
        break;
      case 2:
        display.setCursor(0, 24);
        display.print("MOTION: ");
        display.println(motionDetected ? "DETECTED" : "NONE");
        break;
      case 3:
        display.setCursor(0, 24);
        display.print("FALL: ");
        display.println(fallDetected ? "DETECTED" : "NONE");
        break;
      case 4:
        display.setCursor(0, 24);
        display.print("FIRE: ");
        display.println(fireDetected ? "DETECTED" : "NONE");
        break;
    }
    display.display();

    oledDisplayState++;
    if (oledDisplayState > 4) {
      oledDisplayState = 0;
    }
    lastOLEDUpdate = millis();
  }

  delay(100); // Small delay to allow other tasks/ESP32 core to run
}

// --- New function: Poll relay state from backend ---
bool fetchRelayState() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = "https://humancc.site/shahidatulhidayah/smart-elderly-app/api/device/relay_state.php?device_id=" + String(deviceId);
    http.begin(url);
    int httpResponseCode = http.GET();
    if (httpResponseCode == 200) {
      String response = http.getString();
      DynamicJsonDocument doc(128);
      DeserializationError error = deserializeJson(doc, response);
      if (!error) {
        bool relayOn = doc["relay_on"];
        http.end();
        return relayOn;
      }
    }
    http.end();
  }
  return false; // Default to OFF if error
}

// --- New function: Send relay command to backend ---
void sendRelayCommand(bool on) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    String url = "https://humancc.site/shahidatulhidayah/smart-elderly-app/api/device/command.php";
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    DynamicJsonDocument doc(128);
    doc["device_id"] = deviceId;
    doc["command_type"] = "relay";
    doc["command_value"] = on ? 1 : 0;
    String payload;
    serializeJson(doc, payload);
    int httpResponseCode = http.POST(payload);
    http.end();
    Serial.print("Sent relay command to backend: ");
    Serial.println(on ? "ON" : "OFF");
  }
}

// --- Updated readSensors() with sticky alert logic ---
void readSensors() {
  // Read PIR sensor
  motionDetected = digitalRead(PIR_PIN) == HIGH;

  // Read vibration sensor
  int vibrationValue = analogRead(VIBRATION_PIN);
  if (vibrationValue > VIBRATION_THRESHOLD) {
    fallDetectedUntil = millis() + alertStickyDuration;
  }
  fallDetected = millis() < fallDetectedUntil;

  // Read flame sensor
  int flameValue = analogRead(FLAME_PIN);
  if (flameValue < FLAME_THRESHOLD) { // Lower value means closer to flame
    fireDetectedUntil = millis() + alertStickyDuration;
  }
  fireDetected = millis() < fireDetectedUntil;

  // Read DHT11 sensor
  temperature = dht.readTemperature();
  humidity = dht.readHumidity();

  // Check if any reads failed
  if (isnan(temperature) || isnan(humidity)) {
    Serial.println("Failed to read from DHT sensor!");
    temperature = 0;
    humidity = 0;
  }

  // Print sensor values for debugging
  Serial.print("Motion: ");
  Serial.print(motionDetected ? "Detected" : "No motion");
  Serial.print(" | Vibration: ");
  Serial.print(vibrationValue);
  Serial.print(" | Flame: ");
  Serial.print(flameValue);
  Serial.print(" | Temp: ");
  Serial.print(temperature);
  Serial.print("°C | Humidity: ");
  Serial.print(humidity);
  Serial.println("%");
}

void checkEmergencies() {
  // Buzzer logic is now handled in loop()
  // Relay is controlled by backend/app and emergency trigger
}

void sendSensorData() {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    http.begin(serverUrl);
    http.addHeader("Content-Type", "application/json");

    // Create JSON payload
    DynamicJsonDocument doc(256);
    doc["device_id"] = deviceId;
    doc["temperature"] = temperature;
    doc["humidity"] = humidity;
    doc["motion"] = motionDetected;
    doc["fall_detected"] = fallDetected;
    doc["fire_detected"] = fireDetected;

    String payload;
    serializeJson(doc, payload);

    Serial.println("Sending data to server...");
    Serial.println(payload);

    // Send HTTP POST request
    int httpResponseCode = http.POST(payload);

    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.print("HTTP Response code: ");
      Serial.println(httpResponseCode);
      Serial.print("Response: ");
      Serial.println(response);
    } else {
      Serial.print("Error code: ");
      Serial.println(httpResponseCode);
    }

    http.end();
  } else {
    Serial.println("WiFi Disconnected");
  }
}