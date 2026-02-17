# Quick Start Guide

Get your ATmega32 Maze System up and running in minutes!

## Prerequisites Checklist

- [ ] ATmega32 microcontroller (DIP-40 package)
- [ ] USB/Serial programmer (USBasp recommended)
- [ ] 5V regulated power supply (2A minimum)
- [ ] All components from hardware list
- [ ] AVR-GCC toolchain installed
- [ ] Proteus (optional, for simulation)

## 5-Minute Setup

### Step 1: Install Software (2 minutes)

**Windows:**
```powershell
# Download and install Atmel Studio 7
# https://www.microchip.com/en-us/tools-resources/develop/microchip-studio
```

**Linux:**
```bash
sudo apt-get update
sudo apt-get install gcc-avr avr-libc avrdude make
```

**macOS:**
```bash
brew tap osx-cross/avr
brew install avr-gcc avrdude make
```

### Step 2: Clone and Build (1 minute)

```bash
# Clone repository
git clone https://github.com/yourusername/Atmega32-Maze-System.git
cd Atmega32-Maze-System

# Build project
make all

# Expected output:
# Compiling: src/main.c
# Linking: build/maze_system.elf
# Creating hex file: build/maze_system.hex
# Size Information: ~8.2KB Flash, ~380 bytes RAM
```

### Step 3: Flash Microcontroller (1 minute)

```bash
# Connect your programmer to ATmega32
# Flash the program
make flash

# Set fuse bits for 16MHz crystal (one-time only)
make fuses
```

### Step 4: Hardware Connections (5-10 minutes)

#### Essential Connections

**Power:**
```
VCC  (Pin 10) → 5V
GND  (Pin 11) → Ground
AVCC (Pin 30) → 5V (with 100nF capacitor to ground)
AREF (Pin 32) → 100nF capacitor to ground
```

**LCD (16x2):**
```
LCD Pin → ATmega32
VSS     → GND
VDD     → 5V
RS      → PA1 (Pin 40)
RW      → GND (write mode only)
E       → PA2 (Pin 39)
D4      → PA3 (Pin 38)
D5      → PA4 (Pin 37)
D6      → PA5 (Pin 36)
D7      → PA6 (Pin 35)
A       → 5V (via 220Ω resistor for backlight)
K       → GND
```

**Keypad (4 buttons):**
```
Button 1 → PD2 (Pin 16) → Pull-up to 5V
Button 2 → PD3 (Pin 17) → Pull-up to 5V
Button 3 → PD4 (Pin 18) → Pull-up to 5V
Button 4 → PD5 (Pin 19) → Pull-up to 5V
```

**Servos (6x SG90):**
```
Servo    Signal Pin      Power
Servo 1  PB0 (Pin 1)    5V/GND (external)
Servo 2  PB1 (Pin 2)    5V/GND (external)
Servo 3  PB2 (Pin 3)    5V/GND (external)
Servo 4  PB3 (Pin 4)    5V/GND (external)
Servo 5  PB4 (Pin 5)    5V/GND (external)
Servo 6  PB5 (Pin 6)    5V/GND (external)

⚠️ Use separate 5V supply for servos (2A recommended)
```

**Sensors:**
```
NTC Thermistor:
  - Voltage divider: 10kΩ resistor
  - Middle point → PA0 (Pin 40)

FSR Sensor:
  - Voltage divider: 10kΩ resistor
  - Middle point → PA7 (Pin 33)

HC-SR04 Ultrasonic:
  - VCC  → 5V
  - TRIG → PD0 (Pin 14)
  - ECHO → PD6 (Pin 20)
  - GND  → Ground
```

**Indicators:**
```
RGB LED (Common Cathode):
  Red   → PC0 (Pin 22) via 220Ω
  Green → PC1 (Pin 23) via 220Ω
  Blue  → PC2 (Pin 24) via 220Ω
  GND   → Ground

Buzzer:
  Positive → PC5 (Pin 27)
  Negative → Ground
```

### Step 5: Test System (1 minute)

1. **Power On**
   - LCD should display "HALLO"
   - All servos move to closed position
   - RGB LED lights up

2. **Player Detection**
   - Press FSR sensor
   - LCD shows "Door 1" and "3 Tries Left"

3. **Answer Question**
   - Read question on LCD
   - Press button (1-4) to answer
   - Buzzer beeps on button press
   - Correct answer → door opens

4. **Temperature Check**
   - Heat NTC sensor gently
   - "TEMP ALERT" should appear

## Troubleshooting

### LCD Shows Nothing
- Check contrast (adjust 10kΩ potentiometer on LCD)
- Verify 5V power and ground
- Check PA1-PA6 connections
- Ensure 4-bit mode wiring

### Servos Not Moving
- Verify external 5V supply (2A minimum)
- Check PB0-PB5 connections
- Test servo with Arduino first
- Ensure common ground between MCU and servo supply

### No Response from Buttons
- Check pull-up resistors (10kΩ to 5V)
- Verify PD2-PD5 connections
- Test with multimeter (should read 5V when not pressed)

### Random Characters on LCD
- F_CPU mismatch: Ensure 16MHz crystal installed
- Fuse bits incorrect: Run `make fuses`
- Timing issues: Check _delay_ms() calls

### Temperature Sensor Errors
- NTC reading 0: Check voltage divider circuit
- Alert triggering randomly: Adjust threshold in code
- No temperature response: Verify PA0 ADC connection

### Ultrasonic Sensor Issues
- Distance always 0: Check TRIG (PD0) connection
- Erratic readings: Ensure obstacle at 5-30cm range
- No exit detection: Verify ECHO (PD6) and Timer1

## Quick Command Reference

```bash
# Build project
make all              # Compile and generate hex

# Flash to MCU
make flash            # Upload program
make fuses            # Set fuse bits (16MHz)

# Debugging
make size             # Check program size
make disasm           # View assembly code
make verify           # Verify flash contents

# Maintenance
make clean            # Remove build files
make help             # Show all commands
```

## Hardware Testing Sequence

### Test 1: LCD Display
```c
LCD_Init();
BeMessage("TEST OK");
// Expected: "TEST OK" on LCD
```

### Test 2: Servo Control
```c
setB(0, true);   // Open servo 0
_delay_ms(2000);
setB(0, false);  // Close servo 0
// Expected: Servo rotates 0° → 90°
```

### Test 3: ADC Sensors
```c
uint16_t ntc = ADC_Read(0);
uint16_t fsr = ADC_Read(7);
// Expected: Values 0-1023
```

### Test 4: Ultrasonic
```c
double dist = ultra();
// Expected: Distance in cm (5-30cm range)
```

## Simulation Testing (Proteus)

1. Open `hardware/Maze simulation in proteus.pdsprj`
2. Load `build/maze_system.hex` into ATmega32
3. Run simulation (F12)
4. Test all features:
   - LCD display
   - Button presses
   - Sensor readings
   - Servo movements

## Common Issues & Solutions

| Issue | Possible Cause | Solution |
|-------|---------------|----------|
| Won't compile | Missing AVR-GCC | Install toolchain |
| Flash failed | Programmer not connected | Check USB connection |
| Fuse error | Wrong programmer type | Set correct programmer in Makefile |
| LCD garbled | Wrong F_CPU | Check crystal frequency |
| Servo jitter | Insufficient current | Use 2A power supply |
| No sensor reading | ADC not initialized | Call ADC_init() |

## Performance Verification

After setup, verify these metrics:

✅ **Code Size**: ~8.2 KB (25% of flash)  
✅ **Response Time**: < 50ms (button to LCD)  
✅ **Servo Accuracy**: ±2° positioning  
✅ **Distance Accuracy**: ±1cm (5-30cm range)  
✅ **LCD Refresh**: ~15 characters/second  
✅ **Power Consumption**: ~1.2A @ 5V  

## Next Steps

Once basic system works:

1. **Calibrate Sensors**
   - Adjust NTC threshold for room temperature
   - Calibrate FSR for player weight
   - Test ultrasonic at various distances

2. **Customize Questions**
   - Edit question arrays in main.c
   - Update correct_answers array
   - Recompile and flash

3. **Optimize Performance**
   - Adjust servo speed in setB()
   - Tune LCD timing for faster display
   - Modify temperature thresholds

4. **Add Features**
   - See [Future Enhancements](README.md#future-enhancements)
   - Contribute via pull request

## Getting Help

- **Documentation**: See [README.md](README.md), [API.md](docs/API.md), [DESIGN.md](docs/DESIGN.md)
- **Issues**: Open GitHub issue with hardware photos
- **Community**: Join embedded systems forums
- **Email**: Contact maintainers

## Success Checklist

- [ ] Software installed and working
- [ ] Project builds without errors
- [ ] ATmega32 programmed successfully
- [ ] Fuse bits set correctly
- [ ] All hardware connected
- [ ] LCD displays "HALLO"
- [ ] Servos respond to commands
- [ ] Buttons register presses
- [ ] Sensors provide readings
- [ ] Game plays through successfully

## Video Tutorial

[Coming Soon] Step-by-step video guide for hardware setup and testing.

---

**Need help?** Open an issue on GitHub or check the [troubleshooting section](README.md#troubleshooting).

**Ready to play?** Power on and enjoy your interactive maze! 🎮
