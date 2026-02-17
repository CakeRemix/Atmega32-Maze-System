# Makefile for ATmega32 Interactive Maze System
# Author: ATmega32 Maze System Team
# Description: Build automation for AVR-GCC compiler

#==============================================================================
# Configuration
#==============================================================================

# Microcontroller settings
MCU = atmega32
F_CPU = 16000000UL
TARGET = maze_system

# Source files
SRC = src/main.c
OBJ = $(SRC:.c=.o)

# Output directory
BUILD_DIR = build

# Programmer settings (change according to your programmer)
PROGRAMMER = usbasp
PORT = usb
BAUD = 19200

# Fuse settings for ATmega32 @ 16MHz external crystal
# LFUSE: 0xEF - External Crystal/Resonator High Freq; Start-up time: 16K CK + 64ms
# HFUSE: 0xC9 - JTAG disabled, SPIEN enabled, EESAVE enabled
LFUSE = 0xef
HFUSE = 0xc9

#==============================================================================
# Compiler and Linker Flags
#==============================================================================

# Compiler flags
CFLAGS = -mmcu=$(MCU)
CFLAGS += -DF_CPU=$(F_CPU)
CFLAGS += -Os                    # Optimize for size
CFLAGS += -Wall                  # Enable all warnings
CFLAGS += -Wextra                # Enable extra warnings
CFLAGS += -std=gnu99             # Use C99 standard with GNU extensions
CFLAGS += -funsigned-char        # Make 'char' unsigned
CFLAGS += -funsigned-bitfields   # Make bitfields unsigned
CFLAGS += -fpack-struct          # Pack structure members
CFLAGS += -fshort-enums          # Use smallest enum type
CFLAGS += -ffunction-sections    # Place each function in own section
CFLAGS += -fdata-sections        # Place each data in own section

# Linker flags
LDFLAGS = -mmcu=$(MCU)
LDFLAGS += -Wl,--gc-sections     # Remove unused sections
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/$(TARGET).map  # Generate map file

# Object copy flags
OBJCOPY_HEX_FLAGS = -O ihex -R .eeprom
OBJCOPY_EEP_FLAGS = -O ihex -j .eeprom --set-section-flags=.eeprom=alloc,load --no-change-warnings

#==============================================================================
# Tools
#==============================================================================

CC = avr-gcc
OBJCOPY = avr-objcopy
OBJDUMP = avr-objdump
SIZE = avr-size
NM = avr-nm
AVRDUDE = avrdude
REMOVE = rm -f
MKDIR = mkdir -p

#==============================================================================
# Build Targets
#==============================================================================

.PHONY: all clean flash fuses size disasm help install-tools

# Default target
all: $(BUILD_DIR) $(BUILD_DIR)/$(TARGET).hex $(BUILD_DIR)/$(TARGET).eep size

# Create build directory
$(BUILD_DIR):
	$(MKDIR) $(BUILD_DIR)

# Compile source files
%.o: %.c
	@echo "Compiling: $<"
	$(CC) $(CFLAGS) -c $< -o $@

# Link object files
$(BUILD_DIR)/$(TARGET).elf: $(OBJ)
	@echo "Linking: $@"
	$(CC) $(LDFLAGS) $^ -o $@

# Generate hex file
$(BUILD_DIR)/$(TARGET).hex: $(BUILD_DIR)/$(TARGET).elf
	@echo "Creating hex file: $@"
	$(OBJCOPY) $(OBJCOPY_HEX_FLAGS) $< $@

# Generate eeprom file
$(BUILD_DIR)/$(TARGET).eep: $(BUILD_DIR)/$(TARGET).elf
	@echo "Creating eeprom file: $@"
	$(OBJCOPY) $(OBJCOPY_EEP_FLAGS) $< $@

# Display size information
size: $(BUILD_DIR)/$(TARGET).elf
	@echo "==================================================="
	@echo "Size Information:"
	@echo "==================================================="
	$(SIZE) -C --mcu=$(MCU) $<
	@echo "==================================================="
	@echo "Flash: 32768 bytes (32 KB)"
	@echo "SRAM:   2048 bytes (2 KB)"
	@echo "EEPROM: 1024 bytes (1 KB)"
	@echo "==================================================="

# Generate disassembly
disasm: $(BUILD_DIR)/$(TARGET).elf
	@echo "Generating disassembly..."
	$(OBJDUMP) -d $< > $(BUILD_DIR)/$(TARGET).lss

# Flash program to microcontroller
flash: $(BUILD_DIR)/$(TARGET).hex
	@echo "==================================================="
	@echo "Flashing $(TARGET).hex to ATmega32..."
	@echo "==================================================="
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U flash:w:$<:i

# Write fuse bits
fuses:
	@echo "==================================================="
	@echo "Writing fuse bits..."
	@echo "LFUSE: $(LFUSE)  HFUSE: $(HFUSE)"
	@echo "WARNING: Incorrect fuse settings can brick your MCU!"
	@echo "==================================================="
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U lfuse:w:$(LFUSE):m -U hfuse:w:$(HFUSE):m

# Verify flash contents
verify: $(BUILD_DIR)/$(TARGET).hex
	@echo "Verifying flash contents..."
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U flash:v:$<:i

# Read fuses from MCU
read-fuses:
	@echo "Reading fuse bits from ATmega32..."
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U lfuse:r:-:h -U hfuse:r:-:h

# Clean build files
clean:
	@echo "Cleaning build files..."
	$(REMOVE) $(OBJ)
	$(REMOVE) $(BUILD_DIR)/$(TARGET).elf
	$(REMOVE) $(BUILD_DIR)/$(TARGET).hex
	$(REMOVE) $(BUILD_DIR)/$(TARGET).eep
	$(REMOVE) $(BUILD_DIR)/$(TARGET).map
	$(REMOVE) $(BUILD_DIR)/$(TARGET).lss
	@echo "Clean complete."

# Deep clean (remove build directory)
distclean: clean
	$(REMOVE) -r $(BUILD_DIR)

# Install AVR toolchain (platform-specific)
install-tools:
	@echo "==================================================="
	@echo "AVR Toolchain Installation Instructions"
	@echo "==================================================="
	@echo "Windows: Download from https://www.microchip.com/"
	@echo "Linux:   sudo apt-get install gcc-avr avr-libc avrdude"
	@echo "macOS:   brew tap osx-cross/avr && brew install avr-gcc avrdude"
	@echo "==================================================="

# Help target
help:
	@echo "==================================================="
	@echo "ATmega32 Maze System - Makefile Help"
	@echo "==================================================="
	@echo "Available targets:"
	@echo ""
	@echo "  make all         - Build hex and eeprom files (default)"
	@echo "  make flash       - Upload hex file to ATmega32"
	@echo "  make fuses       - Write fuse bits to ATmega32"
	@echo "  make verify      - Verify flash contents"
	@echo "  make read-fuses  - Read current fuse settings"
	@echo "  make size        - Display program size"
	@echo "  make disasm      - Generate disassembly listing"
	@echo "  make clean       - Remove build files"
	@echo "  make distclean   - Remove build directory"
	@echo "  make install-tools - Show toolchain installation"
	@echo "  make help        - Display this help message"
	@echo ""
	@echo "Configuration:"
	@echo "  MCU:        $(MCU)"
	@echo "  F_CPU:      $(F_CPU)"
	@echo "  Programmer: $(PROGRAMMER)"
	@echo ""
	@echo "To change programmer, edit PROGRAMMER variable"
	@echo "==================================================="

#==============================================================================
# Utility Targets
#==============================================================================

# List compiler macros
list-macros:
	$(CC) -mmcu=$(MCU) -dM -E - < /dev/null

# Check toolchain versions
check-tools:
	@echo "==================================================="
	@echo "Toolchain Versions:"
	@echo "==================================================="
	@which $(CC) > /dev/null && $(CC) --version | head -n 1 || echo "avr-gcc not found"
	@which $(AVRDUDE) > /dev/null && $(AVRDUDE) -v 2>&1 | head -n 1 || echo "avrdude not found"
	@echo "==================================================="

# Program EEPROM
flash-eeprom: $(BUILD_DIR)/$(TARGET).eep
	@echo "Flashing EEPROM..."
	$(AVRDUDE) -c $(PROGRAMMER) -p $(MCU) -U eeprom:w:$<:i

#==============================================================================
# Dependencies
#==============================================================================

# Include dependencies (if they exist)
-include $(OBJ:.o=.d)

# Generate dependencies
%.d: %.c
	@$(CC) $(CFLAGS) -MM -MT $(@:.d=.o) $< > $@
