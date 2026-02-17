# Contributing to ATmega32 Interactive Maze System

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## How to Contribute

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When creating a bug report, include:

- **Description**: Clear and concise description of the bug
- **Steps to Reproduce**: Detailed steps to reproduce the behavior
- **Expected Behavior**: What you expected to happen
- **Actual Behavior**: What actually happened
- **Hardware Setup**: ATmega32 configuration, components used
- **Software Version**: Compiler version, Atmel Studio version
- **Additional Context**: Screenshots, photos of hardware setup

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Clear Title**: Use a clear and descriptive title
- **Detailed Description**: Provide a detailed explanation of the feature
- **Use Cases**: Explain why this enhancement would be useful
- **Possible Implementation**: If you have ideas on implementation

### Pull Requests

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Development Guidelines

### Code Style

- Use meaningful variable and function names
- Comment complex logic sections
- Follow existing code formatting
- Keep functions focused on single responsibilities
- Use consistent indentation (tabs or spaces, not mixed)

### Commit Messages

- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and pull requests liberally

Example:
```
Add ultrasonic sensor calibration

- Implement automatic distance calibration
- Add EEPROM storage for calibration data
- Update documentation with calibration procedure

Fixes #123
```

### Testing

- Test your changes on actual hardware before submitting
- Ensure code compiles without warnings
- Verify existing functionality isn't broken
- Test edge cases and boundary conditions

### Documentation

- Update README.md if adding new features
- Update API.md for new functions
- Add inline comments for complex algorithms
- Include examples in documentation

## Project Structure

When adding new files, follow this structure:

```
src/          - Source code files
docs/         - Documentation files
hardware/     - Circuit designs, schematics
tests/        - Test code (if applicable)
```

## Code Review Process

1. A project maintainer will review your pull request
2. Changes may be requested for code quality or functionality
3. Once approved, your PR will be merged
4. Your contribution will be acknowledged in the project

## Community

- Be respectful and constructive in discussions
- Help others when you can
- Share your implementations and improvements
- Report security vulnerabilities privately to maintainers

## Recognition

Contributors will be acknowledged in:
- Project README
- Release notes
- Contributors list

Thank you for contributing to making this project better!
