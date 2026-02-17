# API Reference Guide

Complete function reference for the ATmega32 Interactive Maze System.

## Table of Contents
- [Initialization Functions](#initialization-functions)
- [Hardware Abstraction](#hardware-abstraction)
- [Display Functions](#display-functions)
- [Game Logic](#game-logic)
- [Interrupt Service Routines](#interrupt-service-routines)

---

## Initialization Functions

### `void ADC_init()`

Initializes the Analog-to-Digital Converter for sensor readings.

**Parameters:** None

**Returns:** `void`

**Configuration:**
- Reference voltage: AVCC (5V)
- Prescaler: 128 (ADC clock = 125 kHz)
- Resolution: 10-bit (0-1023)

**Example:**
```c
ADC_init();
uint16_t temperature = ADC_Read(0);
```

**Register Settings:**
```c
ADMUX  |= (1 << REFS0);           // AVCC reference
ADCSRA |= (1 << ADEN)             // Enable ADC
        | (1 << ADPS0)            // Prescaler = 128
        | (1 << ADPS1)
        | (1 << ADPS2);
```

---

### `void Timer0_Init()`

Initializes Timer0 for pseudo-random number generation.

**Parameters:** None

**Returns:** `void`

**Configuration:**
- Mode: Normal (overflow)
- Prescaler: 1 (no prescaling)
- Overflow frequency: ~61 kHz (every 4.096 ms)

**Purpose:** Generates cycle variable for random question selection

**Example:**
```c
Timer0_Init();  // Start random number generator
// cycle variable updates automatically via ISR
```

---

### `void Timer1_Init()`

Initializes Timer1 for ultrasonic distance measurement.

**Parameters:** None

**Returns:** `void`

**Configuration:**
- Mode: Input Capture
- Prescaler: 1 (16 MHz)
- Overflow interrupt: Enabled

**Example:**
```c
Timer1_Init();
double distance = ultra();  // Measure distance
```

---

### `void LCD_Init(void)`

Initializes the LCD in 4-bit mode with 2 lines.

**Parameters:** None

**Returns:** `void`

**Initialization Sequence:**
1. 20ms power-on delay
2. 4-bit mode setup (0x02)
3. Function set: 2 lines, 5×7 matrix (0x28)
4. Display control: Display ON, cursor OFF (0x0C)
5. Entry mode: Increment cursor (0x06)
6. Clear display (0x01)

**Example:**
```c
LCD_Init();
BeMessage("Hello World");
```

---

## Hardware Abstraction

### `uint16_t ADC_Read(uint8_t pin)`

Reads analog voltage from specified ADC pin.

**Parameters:**
- `pin` (uint8_t): ADC channel number (0-7)

**Returns:** 
- `uint16_t`: 10-bit ADC value (0-1023)

**Mapping:**
- 0 → 0V
- 1023 → 5V
- Resolution: ~4.88 mV per count

**Example:**
```c
uint16_t ntc_value = ADC_Read(0);      // Temperature sensor
uint16_t fsr_value = ADC_Read(7);      // Force sensor

// Convert to voltage
float voltage = (ntc_value * 5.0) / 1023.0;
```

**Implementation:**
```c
ADMUX = (ADMUX & 0xF8) | (pin & 0x07);  // Select channel
ADCSRA |= (1 << ADSC);                   // Start conversion
while (ADCSRA & (1 << ADIF));            // Wait for completion
return ADC;                               // Return result
```

---

### `double ultra(void)`

Measures distance using HC-SR04 ultrasonic sensor.

**Parameters:** None

**Returns:**
- `double`: Distance in centimeters

**Range:** 2 cm - 400 cm (optimal: 5-30 cm)

**Accuracy:** ±1 cm

**Measurement Time:** ~20-40 ms

**Algorithm:**
1. Send 10μs trigger pulse on PD0
2. Wait for echo rising edge on PD6
3. Start Timer1
4. Wait for echo falling edge
5. Stop Timer1
6. Calculate: `distance = timer_count / 932.94`

**Example:**
```c
double dist = ultra();
if (dist < 5.0) {
    BeMessage("Too close!");
}
```

**Formula Derivation:**
```
Sound speed: 343 m/s @ 20°C
Timer freq: 16 MHz
distance (cm) = (time × 343 × 100) / 2
time (s) = count / 16,000,000
distance = count / 932.94
```

---

## Display Functions

### `void BeMode(uint8_t cmd)`

Sends command to LCD in 4-bit mode.

**Parameters:**
- `cmd` (uint8_t): LCD command byte

**Returns:** `void`

**Common Commands:**
- `0x01`: Clear display
- `0x02`: Return home
- `0x0C`: Display ON, cursor OFF
- `0x0E`: Display ON, cursor ON
- `0x80`: Set cursor to position 0 (line 1)
- `0xC0`: Set cursor to position 0 (line 2)

**Example:**
```c
BeMode(0x01);      // Clear screen
BeMode(0xC0);      // Move to second line
BeMode(0x0E);      // Turn on cursor
```

**Timing:**
- Enable pulse: 20μs
- Command execution: 20ms

---

### `void BeMessage(char* str)`

Displays string on LCD at current cursor position.

**Parameters:**
- `str` (char*): Null-terminated string to display

**Returns:** `void`

**Maximum Length:** 16 characters per line

**Display Time:** ~50ms per character

**Example:**
```c
LCD_Init();
BeMessage("Door 1");
BeMode(0xC0);           // New line
BeMessage("3 Tries Left");
```

**Multi-line Example:**
```c
LCD_Init();
BeMessage("Question:");
BeMode(0xC0);
BeMessage("3 + 2 = ?");
_delay_ms(2000);
```

---

## Game Logic

### `bool CheckAnswer(uint8_t Door_Num)`

Displays question and validates player's answer.

**Parameters:**
- `Door_Num` (uint8_t): Current door number (0-5)

**Returns:**
- `bool`: `true` if answer correct, `false` otherwise

**Behavior:**
1. Selects unused random question based on cycle
2. Displays question on LCD (2 lines)
3. Displays answer options (4 choices)
4. Waits for keypad input (PD2-PD5)
5. Beeps buzzer on button press
6. Validates answer
7. Marks question as used

**Example:**
```c
if (CheckAnswer(current_door)) {
    open(current_door);  // Open door
    current_door++;
} else {
    tries_remaining--;
}
```

**Keypad Mapping:**
- PD2 → Option 1
- PD3 → Option 2
- PD4 → Option 3
- PD5 → Option 4

---

### `bool winner(void)`

Main game loop handling all 6 doors.

**Parameters:** None

**Returns:**
- `bool`: `true` if player wins, `false` if out of tries

**Behavior:**
1. Resets question memory
2. Closes all doors
3. For each door (0-5):
   - Check temperature safety
   - Display door number and tries
   - Ask question
   - Validate answer
   - Open door on success or decrement tries
4. Returns victory status

**Example:**
```c
if (winner()) {
    BeMessage("VICTORY!");
} else {
    BeMessage("Game Over");
}
```

**Game Flow:**
```
Start → Door 1 → Question → (Correct) → Door 2 → ...
                        ↓
                   (Wrong, tries > 0)
                        ↓
                    Try Again
                        ↓
                (Wrong, tries = 0)
                        ↓
                   Game Over
```

---

### `bool CheckTemperature()`

Monitors system temperature using NTC thermistor.

**Parameters:** None

**Returns:**
- `bool`: `true` if temperature alert (overheating), `false` if normal

**Threshold:** 150 ADC counts (~0.73V)

**Safety Feature:** Game pauses when alert triggered

**Example:**
```c
while (CheckTemperature()) {
    LCD_Init();
    BeMessage("TEMP ALERT");
    _delay_ms(1500);
}
// Resume game when temperature normalizes
```

**NTC Characteristics:**
- Type: Negative Temperature Coefficient
- Lower voltage = Higher temperature
- Alert threshold: < 150 counts

---

## Control Functions

### `void setB(uint8_t door, bool set)`

Controls servo motor for specified door.

**Parameters:**
- `door` (uint8_t): Door number (0-5)
- `set` (bool): `true` for open (0°), `false` for close (90°)

**Returns:** `void`

**PWM Generation:**
- Frequency: 50 Hz (20ms period)
- Open (true): 1ms ON, 19ms OFF (0°)
- Close (false): 2ms ON, 18ms OFF (90°)
- Repetitions: 50 cycles for smooth motion

**Example:**
```c
setB(0, true);   // Open door 0 (set to 0°)
_delay_ms(1000);
setB(0, false);  // Close door 0 (set to 90°)
```

**Total Execution Time:** 50 × 20ms = 1 second

---

### `void open(uint8_t Door)`

High-level door control function.

**Parameters:**
- `Door` (uint8_t): 
  - 0-1: Open specific door
  - 2-7: Close all doors

**Returns:** `void`

**Example:**
```c
open(0);    // Open door 0
open(1);    // Open door 1
open(7);    // Close all 6 doors (reset)
```

**Implementation:**
```c
if (Door < 2) {
    setB(Door, true);   // Open one door
} else {
    for (uint8_t i = 0; i < 6; i++) {
        setB(i, false); // Close all doors
    }
}
```

---

## Interrupt Service Routines

### `ISR(TIMER0_OVF_vect)`

Timer0 overflow interrupt for random number generation.

**Trigger:** Every 4.096 ms (Timer0 overflow)

**Function:** Updates `cycle` variable (0-15)

**Algorithm:**
```c
cycle = (cycle + 1) % 16;
```

**Purpose:** Provides pseudo-random question selection based on player timing

**Example Usage:**
```c
// In main code:
uint8_t question_index = cycle;
// This value changes automatically based on timing
```

---

### `ISR(TIMER1_OVF_vect)`

Timer1 overflow interrupt for ultrasonic timing.

**Trigger:** Every 4.096 ms (Timer1 overflow at 16-bit)

**Function:** Increments `TimerOverflow` counter

**Purpose:** Extends Timer1 range beyond 16-bit for long-distance measurements

**Algorithm:**
```c
total_count = ICR1 + (65535 × TimerOverflow);
```

**Maximum Range:** ~400 cm (with overflow counting)

---

## Data Structures

### Question Database

```c
char* questions[16][2];     // 16 questions, 2 lines each
char* answers[16][2];       // 16 answer sets, 2 lines each
uint8_t correct_answers[16]; // Correct answer indices (0-3)
bool QMemory[16];           // Question usage tracking
```

### Global Variables

```c
uint8_t cycle;              // Random question selector (0-15)
uint8_t Door_Num;           // Current door position (0-6)
uint8_t TimerOverflow;      // Ultrasonic timer overflow counter
```

---

## Pin Definitions Summary

```c
// Port A
#define NTC_PIN     0   // PA0 - Temperature sensor ADC
#define LCD_RS      1   // PA1 - LCD Register Select
#define LCD_EN      2   // PA2 - LCD Enable
#define LCD_D4_D7   3-6 // PA3-PA6 - LCD Data
#define FSR_PIN     7   // PA7 - Force sensor ADC

// Port B
#define SERVO_0_5   0-5 // PB0-PB5 - Servo control signals

// Port C
#define LED_RED     0   // PC0 - Red LED
#define LED_GREEN   1   // PC1 - Green LED
#define LED_BLUE    2   // PC2 - Blue LED
#define BUZZER      5   // PC5 - Buzzer

// Port D
#define TRIG        0   // PD0 - Ultrasonic trigger
#define KEY_1_4     2-5 // PD2-PD5 - Keypad buttons
#define ECHO        6   // PD6 - Ultrasonic echo
```

---

## Error Codes

The system doesn't use formal error codes, but displays these messages:

| Message | Meaning |
|---------|---------|
| "NO PLAYER FOUND" | FSR not detecting anyone |
| "1 PLAYER ONLY" | Multiple players detected |
| "TEMP ALERT" | Temperature threshold exceeded |
| "Wrong" | Incorrect answer |
| "GET OUT" | Player too close to exit sensor |
| "PERFECT VICTORY!" | All doors completed |

---

## Compilation Notes

**Required Compiler Flags:**
```bash
-mmcu=atmega32       # Target microcontroller
-DF_CPU=16000000UL   # Clock frequency
-Os                  # Optimize for size
```

**Required Headers:**
```c
#include <avr/io.h>          // I/O registers
#include <util/delay.h>      // Delay functions
#include <avr/interrupt.h>   // Interrupt handling
#include <stdio.h>           // sprintf()
#include <string.h>          // strcat()
#include <stdbool.h>         // Boolean type
```
