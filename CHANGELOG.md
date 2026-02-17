# Changelog

All notable changes to the ATmega32 Interactive Maze System will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Planned Features
- EEPROM high score storage
- Wireless connectivity (ESP8266)
- Mobile app for configuration
- Additional question categories
- Difficulty levels
- Timer-based speedrun mode

## [1.0.0] - 2026-02-17

### Added
- Initial release of ATmega32 Interactive Maze System
- 6-door servo-controlled maze mechanism
- 16 mathematical and logical questions
- Real-time temperature monitoring with NTC thermistor
- Force-sensitive resistor for player detection
- HC-SR04 ultrasonic sensor for exit detection
- 16x2 LCD display interface
- 4-button keypad for answer selection
- RGB LED status indicator
- Buzzer audio feedback
- Timer-based pseudo-random question selection
- Three-strike game system
- Automatic game reset mechanism
- Temperature safety alert system
- Complete documentation (README, API, DESIGN)
- Proteus simulation file
- Professional project structure

### Hardware Support
- ATmega32 @ 16MHz
- 4-bit LCD mode (HD44780 compatible)
- Software PWM for 6 servos
- 10-bit ADC for analog sensors
- Timer0 for random generation
- Timer1 for ultrasonic ranging

### Documentation
- Comprehensive README with badges
- API reference for all functions
- System design documentation
- Pin configuration tables
- Circuit diagrams and schematics
- Contributing guidelines
- MIT License

## Development History

### [0.3.0] - Development Phase
- Implemented ultrasonic distance measurement
- Added RGB LED status indicators
- Refined question selection algorithm
- Optimized servo control timing

### [0.2.0] - Development Phase
- Added temperature monitoring
- Implemented force sensor player detection
- Created LCD display functions
- Added buzzer feedback system

### [0.1.0] - Development Phase
- Basic ATmega32 initialization
- LCD communication in 4-bit mode
- Servo motor control implementation
- Question database structure
- Initial game logic framework

---

## Version History Legend

- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security vulnerability fixes
