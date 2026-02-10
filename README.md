# SeaTalk WiFi Remote

An ESP32-based wireless remote controller for marine autopilot systems using the SeaTalk protocol. Control your autopilot remotely over WiFi instead of using hardwired physical buttons.

## Features

- **6 programmable buttons** for autopilot control
- **WiFi UDP communication** to SeaTalk gateway
- **Deep sleep mode** for battery conservation
- **Auto-wake** on button press
- **LED status indicator** with visual feedback patterns
- **3D printable enclosure** (OpenSCAD parametric design)

## Button Functions

| Button | GPIO | Function |
|--------|------|----------|
| BTN1 | 32 | -1° heading |
| BTN2 | 33 | +1° heading |
| BTN3 | 25 | -10° heading |
| BTN4 | 26 | +10° heading |
| BTN5 | 27 | Auto/Standby toggle |
| BTN6 | 14 | Track mode |

## Hardware Requirements

- ESP32 development board
- 6x tactile push buttons
- LED + resistor (optional, GPIO 2)
- LiPo battery for portable operation
- USB-C charging circuit
- WiFi-to-SeaTalk gateway on your network

## Wiring

All buttons use internal pull-up resistors. Connect buttons between GPIO and GND.

```
ESP32 GPIO 32 ----[BTN1]---- GND
ESP32 GPIO 33 ----[BTN2]---- GND
ESP32 GPIO 25 ----[BTN3]---- GND
ESP32 GPIO 26 ----[BTN4]---- GND
ESP32 GPIO 27 ----[BTN5]---- GND
ESP32 GPIO 14 ----[BTN6]---- GND
ESP32 GPIO 2  ----[LED]--[R]---- GND
```

## Configuration

1. Copy the example configuration file:

```bash
cp seatalk-wifi-remote/conf_example.h seatalk-wifi-remote/conf.h
```

2. Edit `seatalk-wifi-remote/conf.h` with your WiFi credentials and gateway settings:

```cpp
const char* WIFI_SSID = "MyBoatWiFi";
const char* WIFI_PASSWORD = "my_secret_password";

const char* SEATALK_GATEWAY_IP = "192.168.1.100";  // SeaTalk gateway IP
const uint16_t SEATALK_GATEWAY_PORT = 4001;         // SeaTalk gateway port
```

> **Note:** `conf.h` is gitignored to prevent committing your credentials.

## Building

### Prerequisites

- [Arduino CLI](https://arduino.github.io/arduino-cli/)
- ESP32 Arduino core

### Install ESP32 Core

```bash
cd seatalk-wifi-remote
make install-core
```

### Build and Upload

```bash
make build          # Compile only
make upload         # Build and upload
make monitor        # Open serial monitor
make upload-monitor # Upload and open monitor
```

## Power Management

- **Enter sleep**: Hold BTN1 + BTN6 for 2 seconds
- **Wake up**: Press any button
- **Auto-sleep**: After 1 minute of inactivity (configurable)

### LED Patterns

| Pattern | Meaning |
|---------|---------|
| 3 blinks | Startup complete |
| Single flash | Command sent |
| 10 rapid blinks | WiFi connection error |
| 5 blinks | Entering sleep mode |

## 3D Printed Enclosure

Two enclosure versions are available in the `enclosure/` directory:

### Version 2 (Recommended)

Located in `enclosure/v2/` - larger design with 20mm internal clearance for ESP32 and battery.

**Dimensions:** 78mm × 98mm × 35mm (external)

```bash
cd enclosure/v2
make           # Generate all STL files
make base      # Base shell only
make lid       # Lid only
make extenders # Button extenders only
```

### Version 1 (Compact)

Located in `enclosure/v1-mini/` - compact nke-style remote design.

**Dimensions:** 78mm × 58mm × 23mm (external)

## SeaTalk Protocol

The remote sends SeaTalk Datagram 86 (Autopilot Remote Keystroke) commands:

| Key Code | Command |
|----------|---------|
| 0x05 | -1° |
| 0x06 | +1° |
| 0x07 | -10° |
| 0x08 | +10° |
| 0x01 | Auto |
| 0x02 | Standby |
| 0x03 | Track |


## License

MIT License

## Acknowledgments

- [YAPP Box Generator](https://github.com/mrWheel/YAPP_Box) for parametric enclosure design
- SeaTalk protocol documentation from the marine open-source community
