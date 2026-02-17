# System Design Documentation

## Architecture Overview

The ATmega32 Interactive Maze System follows a modular embedded systems architecture with clear separation between hardware abstraction, application logic, and user interface layers.

## System Layers

### 1. Hardware Abstraction Layer (HAL)

#### ADC Module
- **Purpose**: Analog-to-digital conversion for sensors
- **Resolution**: 10-bit (0-1023)
- **Reference Voltage**: AVCC (5V)
- **Conversion Time**: ~104μs
- **Supported Channels**: PA0 (Temperature), PA7 (Force)

#### Timer Module
- **Timer0**: 8-bit, overflow interrupt for random number generation
- **Timer1**: 16-bit, input capture for ultrasonic ranging
- **Prescaler Options**: Configurable for different timing requirements

#### GPIO Module
- **Port A**: Mixed analog input and digital output (LCD)
- **Port B**: Digital output (Servo PWM)
- **Port C**: Digital output (LED, Buzzer)
- **Port D**: Mixed input/output (Keypad, Ultrasonic)

### 2. Device Driver Layer

#### LCD Driver (HD44780 Compatible)
```
Initialization Sequence:
1. Power-on delay (20ms)
2. Function set: 4-bit mode, 2 lines, 5x7 font
3. Display control: ON, cursor OFF
4. Entry mode: Increment, no shift
5. Clear display
```

#### Servo Driver (Software PWM)
```
PWM Generation:
- Frequency: 50Hz (20ms period)
- Open position: 1ms pulse (0°)
- Close position: 2ms pulse (90°)
- Smooth motion: 50 pulse repetitions
```

#### Ultrasonic Driver (HC-SR04)
```
Measurement Protocol:
1. Send 10μs trigger pulse
2. Wait for echo rising edge
3. Start Timer1
4. Wait for echo falling edge
5. Stop Timer1
6. Calculate: distance = timer_count / 932.94 cm
```

### 3. Application Layer

#### Game State Machine
```
IDLE → PLAYER_DETECT → DOOR_1 → QUESTION_1 → VALIDATE_1 → 
  (correct) → DOOR_2 → ... → DOOR_6 → VICTORY → EXIT → RESET → IDLE
  (wrong) → RETRY (max 3) → DOOR_1 (if tries exhausted)
```

#### Question Management
- **Database**: 16 predefined questions
- **Selection Algorithm**: Timer-based pseudo-random
- **Memory Management**: Boolean array prevents repetition
- **Categories**: Math, calculus, grammar, logic

### 4. User Interface Layer

#### Display System
- **LCD**: Text-based question/answer interface
- **LED**: Color-coded door position indicator
- **Buzzer**: Audio feedback for button presses

#### Input System
- **Keypad**: 4-button answer selection
- **FSR**: Player presence detection
- **Ultrasonic**: Exit proximity sensor

## Data Flow

### Question-Answer Cycle
```
Timer0 Overflow → Update cycle → Select unused question → 
Display on LCD → Wait for keypad input → Validate answer → 
Update game state → Control servo → Update LED
```

### Safety Monitoring Loop
```
Main loop → Read NTC ADC → Compare threshold → 
(if exceeded) → Pause game → Display alert → Wait for cool down →
(if normal) → Resume game
```

## Memory Map

### Flash Memory (32KB)
- **Code**: ~8.2 KB
- **Question Strings**: ~2.1 KB
- **Answer Strings**: ~2.5 KB
- **Available**: ~19.2 KB (60%)

### SRAM (2KB)
- **Global Variables**: ~80 bytes
- **Question Memory Array**: 16 bytes
- **Stack**: ~200 bytes (estimated)
- **Available**: ~1.7 KB (85%)

### EEPROM (1KB)
- Currently unused
- Future: High score storage, calibration data

## Timing Analysis

### Critical Timing Constraints
- **LCD Command**: 20ms between commands
- **LCD Character**: 50ms per character
- **Servo Pulse**: 20ms period (50Hz)
- **Ultrasonic Echo**: Max 38ms (6.5m range)
- **ADC Conversion**: 104μs per channel

### Performance Optimization
- **Parallel Operations**: ADC conversion during LCD delays
- **Interrupt-Driven**: Timer overflows don't block main loop
- **Efficient Polling**: Sensor checks only when needed

## Power Management

### Power Consumption Breakdown
- **MCU**: ~15mA @ 16MHz
- **LCD**: ~3mA (backlight off), ~40mA (backlight on)
- **Servos**: ~100mA each (6 servos = 600mA peak)
- **Sensors**: ~10mA total
- **LEDs**: ~20mA each channel
- **Total Peak**: ~1.2A @ 5V

### Power Saving Opportunities (Future)
- Sleep modes during idle periods
- Servo disable when not in use
- LCD backlight auto-off
- ADC power reduction mode

## Error Handling

### Hardware Errors
- **NTC Failure**: Voltage = 0 detection
- **FSR Calibration**: Multi-player detection
- **Servo Malfunction**: LED backup indicator
- **LCD Communication**: Retry mechanism

### Software Errors
- **Array Bounds**: Modulo operations prevent overflow
- **Integer Overflow**: uint32_t for ultrasonic calculations
- **Null Pointers**: String literals in flash memory

## Testing Strategy

### Unit Testing
- Individual function validation
- Boundary condition checks
- Timing verification with oscilloscope

### Integration Testing
- Hardware-software interface validation
- Multi-component interaction testing
- End-to-end gameplay scenarios

### System Testing
- Long-duration reliability testing
- Environmental condition testing (temperature)
- User acceptance testing

## Design Decisions

### Why Software PWM?
- ATmega32 has limited hardware PWM channels (4)
- Need 6 independent servo controls
- Trade-off: CPU usage vs hardware simplicity

### Why Timer-Based Randomization?
- No hardware RNG in ATmega32
- User timing provides natural entropy
- Simple implementation with Timer0 overflow

### Why 4-bit LCD Mode?
- Saves 4 GPIO pins
- Adequate speed for text display
- Standard implementation in AVR community

## Future Architecture Improvements

### Modularity
- Separate driver files (lcd.c, servo.c, etc.)
- Header files for clean interfaces
- Makefile for modular compilation

### Scalability
- External EEPROM for more questions
- SD card module for media storage
- Network connectivity for online features

### Robustness
- Watchdog timer implementation
- Brown-out detection
- Error logging to EEPROM
