# OpenSCAD Makefile for Autopilot Remote Enclosure v3
# Generates separate STL files for each part

OPENSCAD := openscad
SCAD_FILE := v3.scad
BUILD_DIR := stl

# Output files
ENCLOSURE_STL := $(BUILD_DIR)/enclosure.stl
BACK_COVER_STL := $(BUILD_DIR)/back_cover.stl
TPU_MASK_STL := $(BUILD_DIR)/tpu_mask.stl

# Common flags: disable all parts by default
OFF := -D 'render_front_face=false' \
       -D 'render_tpu_mask=false' \
       -D 'render_enclosure=false' \
       -D 'render_hook=false' \
       -D 'render_back_cover=false'

.PHONY: all clean enclosure back_cover tpu_mask help

all: enclosure back_cover tpu_mask

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

enclosure: $(BUILD_DIR)
	@echo "Generating enclosure..."
	$(OPENSCAD) -o $(ENCLOSURE_STL) \
		$(OFF) \
		-D 'render_front_face=true' \
		-D 'render_enclosure=true' \
		-D 'render_hook=true' \
		$(SCAD_FILE)

back_cover: $(BUILD_DIR)
	@echo "Generating back cover..."
	$(OPENSCAD) -o $(BACK_COVER_STL) \
		$(OFF) \
		-D 'render_back_cover=true' \
		$(SCAD_FILE)

tpu_mask: $(BUILD_DIR)
	@echo "Generating TPU button mask..."
	$(OPENSCAD) -o $(TPU_MASK_STL) \
		$(OFF) \
		-D 'render_tpu_mask=true' \
		$(SCAD_FILE)

clean:
	rm -rf $(BUILD_DIR)

help:
	@echo "Autopilot Remote Enclosure v3 - STL Generation"
	@echo ""
	@echo "  make            - Generate all STL files"
	@echo "  make enclosure  - Generate enclosure.stl (front face + walls + hook)"
	@echo "  make back_cover - Generate back_cover.stl"
	@echo "  make tpu_mask   - Generate tpu_mask.stl (print in TPU)"
	@echo "  make clean      - Remove generated files"
	@echo ""
	@echo "Output directory: $(BUILD_DIR)/"
