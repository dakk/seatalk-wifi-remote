# OpenSCAD Makefile for Autopilot Remote Enclosure
# Generates separate STL files for base, lid, and switch extenders

OPENSCAD := openscad
SCAD_FILE := AUTOPILOT_REMOTE.scad
BUILD_DIR := stl

# Output files
BASE_STL := $(BUILD_DIR)/base.stl
LID_STL := $(BUILD_DIR)/lid.stl
EXTENDERS_STL := $(BUILD_DIR)/extenders.stl

.PHONY: all clean base lid extenders

all: base lid extenders

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

base: $(BUILD_DIR)
	@echo "Generating base..."
	$(OPENSCAD) -o $(BASE_STL) \
		-D 'printBaseShell=true' \
		-D 'printLidShell=false' \
		-D 'printSwitchExtenders=false' \
		$(SCAD_FILE)

lid: $(BUILD_DIR)
	@echo "Generating lid..."
	$(OPENSCAD) -o $(LID_STL) \
		-D 'printBaseShell=false' \
		-D 'printLidShell=true' \
		-D 'printSwitchExtenders=false' \
		$(SCAD_FILE)

extenders: $(BUILD_DIR)
	@echo "Generating switch extenders..."
	$(OPENSCAD) -o $(EXTENDERS_STL) \
		-D 'printBaseShell=false' \
		-D 'printLidShell=false' \
		-D 'printSwitchExtenders=true' \
		$(SCAD_FILE)

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Autopilot Remote Enclosure - STL Generation"
	@echo ""
	@echo "  make           - Generate all STL files"
	@echo "  make base      - Generate base.stl"
	@echo "  make lid       - Generate lid.stl"
	@echo "  make extenders - Generate extenders.stl"
	@echo "  make clean     - Remove generated files"
	@echo ""
	@echo "Output directory: $(BUILD_DIR)/"
