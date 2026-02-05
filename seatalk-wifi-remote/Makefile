# SeaTalk WiFi Remote - Arduino CLI Makefile
# Requires: arduino-cli installed and configured

# ============== CONFIGURATION ==============

# Board settings
BOARD_FQBN := esp32:esp32:esp32
PORT ?= /dev/ttyUSB0
BAUD := 115200

# Project settings
SKETCH := seatalk-wifi-remote.ino
BUILD_DIR := build

# Arduino CLI command
ARDUINO_CLI := arduino-cli

# Upload speed (slower for stability)
UPLOAD_SPEED := 57600

# ============== TARGETS ==============

.PHONY: all build upload clean monitor install-core list-ports help

# Default target
all: build

# Build the sketch
build:
	@echo "Building $(SKETCH)..."
	$(ARDUINO_CLI) compile \
		--fqbn $(BOARD_FQBN):FlashFreq=40,FlashMode=dio \
		--build-path $(BUILD_DIR) \
		--warnings default \
		.

# Upload to board
upload: build
	@echo "Uploading to $(PORT)..."
	$(ARDUINO_CLI) upload \
		--fqbn $(BOARD_FQBN):FlashFreq=40,FlashMode=dio \
		--port $(PORT) \
		--input-dir $(BUILD_DIR)

# Build and upload in one step
flash: upload

# Clean build artifacts
clean:
	@echo "Cleaning build directory..."
	rm -rf $(BUILD_DIR)

# Serial monitor
monitor:
	@echo "Opening serial monitor on $(PORT) at $(BAUD) baud..."
	$(ARDUINO_CLI) monitor --port $(PORT) --config $(BAUD)

# Upload and immediately open monitor
upload-monitor: upload monitor

# Install ESP32 core (run once)
install-core:
	@echo "Adding ESP32 board URL..."
	$(ARDUINO_CLI) config add board_manager.additional_urls \
		https://raw.githubusercontent.com/espressif/arduino-esp32/gh-pages/package_esp32_index.json
	@echo "Updating index..."
	$(ARDUINO_CLI) core update-index
	@echo "Installing ESP32 core..."
	$(ARDUINO_CLI) core install esp32:esp32

# List available serial ports
list-ports:
	$(ARDUINO_CLI) board list

# Show board details
board-info:
	$(ARDUINO_CLI) board details --fqbn $(BOARD_FQBN)

# Verify arduino-cli is installed and show version
check:
	@$(ARDUINO_CLI) version
	@echo "ESP32 core installed:"
	@$(ARDUINO_CLI) core list | grep esp32 || echo "ESP32 core not installed. Run 'make install-core'"

# Help
help:
	@echo "SeaTalk WiFi Remote - Build Targets"
	@echo ""
	@echo "  make              - Build the project"
	@echo "  make build        - Build the project"
	@echo "  make upload       - Build and upload to board"
	@echo "  make flash        - Alias for upload"
	@echo "  make clean        - Remove build artifacts"
	@echo "  make monitor      - Open serial monitor"
	@echo "  make upload-monitor - Upload and open monitor"
	@echo "  make list-ports   - List available serial ports"
	@echo "  make board-info   - Show board details"
	@echo "  make install-core - Install ESP32 Arduino core"
	@echo "  make check        - Verify arduino-cli setup"
	@echo ""
	@echo "Configuration:"
	@echo "  PORT=$(PORT)  (override with: make upload PORT=/dev/ttyUSB1)"
	@echo "  BOARD_FQBN=$(BOARD_FQBN)"
	@echo "  BAUD=$(BAUD)"
