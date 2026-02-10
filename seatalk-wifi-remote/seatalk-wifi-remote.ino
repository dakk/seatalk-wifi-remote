/*
 * SeaTalk WiFi Remote Controller
 * ESP32-based remote with 6 buttons for autopilot control
 *
 * Features:
 * - WiFi connectivity to SeaTalk gateway
 * - 6 configurable buttons for autopilot commands
 * - Deep sleep mode (BTN1 + BTN6 to enter sleep)
 * - Wake from sleep on any button press
 */

#include <WiFi.h>
#include <WiFiUdp.h>
#include <esp_sleep.h>

// ============== CONFIGURATION ==============

// WiFi settings
const char* WIFI_SSID = "YOUR_WIFI_SSID";
const char* WIFI_PASSWORD = "YOUR_WIFI_PASSWORD";

// SeaTalk gateway settings (IP and port of your SeaTalk-to-WiFi bridge)
const char* SEATALK_GATEWAY_IP = "192.168.1.100";
const uint16_t SEATALK_GATEWAY_PORT = 4001;

// Button GPIO pins (choose RTC-capable GPIOs for wake-up support)
// RTC GPIOs on ESP32: 0, 2, 4, 12-15, 25-27, 32-39
#define BTN1_PIN  32  // -1 degree
#define BTN2_PIN  33  // +1 degree
#define BTN3_PIN  25  // -10 degrees
#define BTN4_PIN  26  // +10 degrees
#define BTN5_PIN  27  // Auto/Standby toggle
#define BTN6_PIN  14  // Track mode

// LED indicator (optional)
#define LED_PIN   2

// Button debounce time in milliseconds
#define DEBOUNCE_MS 50

// Sleep mode key combination hold time (milliseconds)
#define SLEEP_COMBO_HOLD_MS 2000

// WiFi connection timeout (milliseconds)
#define WIFI_TIMEOUT_MS 10000

// Inactivity timeout before auto-sleep (minutes)
#define INACTIVITY_TIMEOUT_MIN 1

// ============== SEATALK COMMANDS ==============
// SeaTalk autopilot remote keystroke commands (Datagram 86)
// Format: 86 X1 YY - where X1 = key code, YY = 0x00

// Keystroke codes for autopilot
const uint8_t ST_KEY_MINUS_1    = 0x05;  // -1 degree
const uint8_t ST_KEY_PLUS_1     = 0x06;  // +1 degree
const uint8_t ST_KEY_MINUS_10   = 0x07;  // -10 degrees
const uint8_t ST_KEY_PLUS_10    = 0x08;  // +10 degrees
const uint8_t ST_KEY_AUTO       = 0x01;  // Auto mode
const uint8_t ST_KEY_STANDBY    = 0x02;  // Standby mode
const uint8_t ST_KEY_TRACK      = 0x03;  // Track mode

// ============== GLOBAL VARIABLES ==============

WiFiUDP udp;

// Button state tracking
struct Button {
  uint8_t pin;
  uint8_t command;
  bool lastState;
  bool currentState;
  unsigned long lastDebounceTime;
  bool pressed;
};

Button buttons[6] = {
  {BTN1_PIN, ST_KEY_MINUS_1,  true, true, 0, false},
  {BTN2_PIN, ST_KEY_PLUS_1,   true, true, 0, false},
  {BTN3_PIN, ST_KEY_MINUS_10, true, true, 0, false},
  {BTN4_PIN, ST_KEY_PLUS_10,  true, true, 0, false},
  {BTN5_PIN, ST_KEY_AUTO,     true, true, 0, false},  // Toggle auto/standby
  {BTN6_PIN, ST_KEY_TRACK,    true, true, 0, false}
};

bool autoMode = false;  // Track current autopilot state for toggle
unsigned long sleepComboStartTime = 0;
bool sleepComboActive = false;
unsigned long lastActivityTime = 0;  // Track last button activity for auto-sleep

// ============== FUNCTION DECLARATIONS ==============

void setupButtons();
void setupWiFi();
void updateButtons();
void sendSeaTalkCommand(uint8_t keyCode);
void checkSleepCombo();
void enterDeepSleep();
void blinkLED(int times, int delayMs);
void printWakeupReason();

// ============== SETUP ==============

void setup() {
  Serial.begin(115200);
  delay(100);

  Serial.println("\n\n=================================");
  Serial.println("SeaTalk WiFi Remote Controller");
  Serial.println("=================================\n");

  // Print wake-up reason
  printWakeupReason();

  // Initialize LED
  pinMode(LED_PIN, OUTPUT);
  digitalWrite(LED_PIN, LOW);

  // Initialize buttons
  setupButtons();

  // Connect to WiFi
  setupWiFi();

  // Indicate ready
  blinkLED(3, 100);

  // Initialize activity timer
  lastActivityTime = millis();

  Serial.println("\nRemote ready!");
  Serial.println("- Press BTN1+BTN6 for 2 seconds to enter sleep mode");
  Serial.printf("- Auto-sleep after %d minutes of inactivity\n", INACTIVITY_TIMEOUT_MIN);
  Serial.println("- Press any button to wake from sleep\n");
}

// ============== MAIN LOOP ==============

void loop() {
  // Check WiFi connection
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi disconnected, reconnecting...");
    setupWiFi();
  }

  // Update button states
  updateButtons();

  // Check for sleep mode combination (BTN1 + BTN6)
  checkSleepCombo();

  // Process button presses
  for (int i = 0; i < 6; i++) {
    if (buttons[i].pressed) {
      buttons[i].pressed = false;
      lastActivityTime = millis();  // Reset inactivity timer

      // Special handling for BTN5 (Auto/Standby toggle)
      if (i == 4) {
        autoMode = !autoMode;
        sendSeaTalkCommand(autoMode ? ST_KEY_AUTO : ST_KEY_STANDBY);
      } else {
        sendSeaTalkCommand(buttons[i].command);
      }
    }
  }

  // Check for inactivity timeout
  if ((millis() - lastActivityTime) >= (unsigned long)INACTIVITY_TIMEOUT_MIN * 60000UL) {
    Serial.println("Inactivity timeout reached, entering sleep...");
    enterDeepSleep();
  }

  delay(10);
}

// ============== BUTTON FUNCTIONS ==============

void setupButtons() {
  for (int i = 0; i < 6; i++) {
    pinMode(buttons[i].pin, INPUT_PULLUP);
    buttons[i].lastState = digitalRead(buttons[i].pin);
    buttons[i].currentState = buttons[i].lastState;
  }
  Serial.println("Buttons initialized");
}

void updateButtons() {
  for (int i = 0; i < 6; i++) {
    bool reading = digitalRead(buttons[i].pin);

    // Check if button state changed
    if (reading != buttons[i].lastState) {
      buttons[i].lastDebounceTime = millis();
    }

    // If debounce time passed, update state
    if ((millis() - buttons[i].lastDebounceTime) > DEBOUNCE_MS) {
      if (reading != buttons[i].currentState) {
        buttons[i].currentState = reading;

        // Button pressed (LOW because of INPUT_PULLUP)
        if (buttons[i].currentState == LOW) {
          buttons[i].pressed = true;
          Serial.printf("Button %d pressed\n", i + 1);
        }
      }
    }

    buttons[i].lastState = reading;
  }
}

// ============== SLEEP FUNCTIONS ==============

void checkSleepCombo() {
  // Check if BTN1 (index 0) and BTN6 (index 5) are both pressed
  bool btn1Pressed = (buttons[0].currentState == LOW);
  bool btn6Pressed = (buttons[5].currentState == LOW);

  if (btn1Pressed && btn6Pressed) {
    if (!sleepComboActive) {
      sleepComboActive = true;
      sleepComboStartTime = millis();
      Serial.println("Sleep combo detected, hold for 2 seconds...");
    } else if ((millis() - sleepComboStartTime) >= SLEEP_COMBO_HOLD_MS) {
      Serial.println("Entering deep sleep...");
      enterDeepSleep();
    }
  } else {
    if (sleepComboActive) {
      Serial.println("Sleep combo released");
    }
    sleepComboActive = false;
  }
}

void enterDeepSleep() {
  // Indicate entering sleep
  blinkLED(5, 200);

  // Disconnect WiFi to save power
  WiFi.disconnect(true);
  WiFi.mode(WIFI_OFF);

  // Configure wake-up sources using EXT1 (multiple pins)
  // Wake up when ANY of the specified pins goes LOW
  uint64_t wakeupPinMask = 0;
  wakeupPinMask |= (1ULL << BTN1_PIN);
  wakeupPinMask |= (1ULL << BTN2_PIN);
  wakeupPinMask |= (1ULL << BTN3_PIN);
  wakeupPinMask |= (1ULL << BTN4_PIN);
  wakeupPinMask |= (1ULL << BTN5_PIN);
  wakeupPinMask |= (1ULL << BTN6_PIN);

  esp_sleep_enable_ext1_wakeup(wakeupPinMask, ESP_EXT1_WAKEUP_ALL_LOW);

  Serial.println("Going to sleep now. Press any button to wake up.");
  Serial.flush();

  // Enter deep sleep
  esp_deep_sleep_start();
}

void printWakeupReason() {
  esp_sleep_wakeup_cause_t wakeup_reason = esp_sleep_get_wakeup_cause();

  switch (wakeup_reason) {
    case ESP_SLEEP_WAKEUP_EXT0:
      Serial.println("Wakeup caused by external signal using RTC_IO");
      break;
    case ESP_SLEEP_WAKEUP_EXT1:
      Serial.println("Wakeup caused by external signal using RTC_CNTL");
      break;
    case ESP_SLEEP_WAKEUP_TIMER:
      Serial.println("Wakeup caused by timer");
      break;
    case ESP_SLEEP_WAKEUP_TOUCHPAD:
      Serial.println("Wakeup caused by touchpad");
      break;
    case ESP_SLEEP_WAKEUP_ULP:
      Serial.println("Wakeup caused by ULP program");
      break;
    default:
      Serial.printf("Wakeup was not caused by deep sleep: %d\n", wakeup_reason);
      break;
  }
}

// ============== WIFI FUNCTIONS ==============

void setupWiFi() {
  Serial.printf("Connecting to WiFi: %s", WIFI_SSID);

  WiFi.mode(WIFI_STA);
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);

  unsigned long startTime = millis();
  while (WiFi.status() != WL_CONNECTED) {
    if (millis() - startTime > WIFI_TIMEOUT_MS) {
      Serial.println("\nWiFi connection timeout!");
      blinkLED(10, 50);
      return;
    }
    delay(500);
    Serial.print(".");
    digitalWrite(LED_PIN, !digitalRead(LED_PIN));
  }

  digitalWrite(LED_PIN, HIGH);
  Serial.println("\nWiFi connected!");
  Serial.printf("IP address: %s\n", WiFi.localIP().toString().c_str());

  // Initialize UDP
  udp.begin(SEATALK_GATEWAY_PORT);
}

// ============== SEATALK FUNCTIONS ==============

void sendSeaTalkCommand(uint8_t keyCode) {
  // SeaTalk Datagram 86: Autopilot Remote Keystroke
  // Format: 86 X1 YY
  // X = key code, 1 = number of following bytes, YY = 0x00

  uint8_t datagram[3];
  datagram[0] = 0x86;           // Command byte
  datagram[1] = (keyCode << 4) | 0x01;  // Key code in high nibble, length in low nibble
  datagram[2] = 0x00;           // Padding

  // Send via UDP to SeaTalk gateway
  udp.beginPacket(SEATALK_GATEWAY_IP, SEATALK_GATEWAY_PORT);
  udp.write(datagram, 3);
  udp.endPacket();

  Serial.printf("Sent SeaTalk command: 0x%02X 0x%02X 0x%02X (key: 0x%02X)\n",
                datagram[0], datagram[1], datagram[2], keyCode);

  // Brief LED flash to indicate transmission
  digitalWrite(LED_PIN, LOW);
  delay(50);
  digitalWrite(LED_PIN, HIGH);
}

// ============== UTILITY FUNCTIONS ==============

void blinkLED(int times, int delayMs) {
  for (int i = 0; i < times; i++) {
    digitalWrite(LED_PIN, HIGH);
    delay(delayMs);
    digitalWrite(LED_PIN, LOW);
    delay(delayMs);
  }
}
