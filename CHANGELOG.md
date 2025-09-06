# Changelog

## 1.0.1

### Bug Fixes

- Fixed dependency compatibility issues with archive package v4.x
- Resolved null safety issues in test infrastructure
- Fixed file reading errors in browser environment
- Improved error handling for missing test files
- Corrected import statements for better code organization

### Improvements

- Updated dependencies to latest stable versions:
  - archive: ^4.0.7 (was ^3.6.1)
  - xml: ^6.6.1 (was ^6.5.0)
  - path: ^1.9.1 (was ^1.9.0)
- Restructured test file organization for better maintainability
- Enhanced example documentation with comprehensive usage patterns
- Improved bin tool with better error handling and formatting
- Better code formatting and consistency across the codebase

### Technical Changes

- Removed unused `dart:typed_data` imports
- Fixed `InputStreamBase` to `InputStream` compatibility
- Updated archive file handling for v4.x compatibility
- Improved conditional imports for platform-specific code
- Fixed test infrastructure to support both VM and browser environments

## 1.0.0

Initial release of Table Parser - an extended and improved version of spreadsheet_decoder:

### Features

- Support for CSV, ODS, and XLSX file formats
- Enhanced CSV parsing with custom separators and text delimiters
- Improved error handling and validation
- Better performance for large files
- Extended API for table manipulation
- Full update functionality (insert/remove rows/columns, update cells)
- Comprehensive documentation and examples

### CSV Support

- Parse CSV from string or bytes
- Custom separators and text delimiters
- Automatic number parsing (configurable)
- Quoted fields with escape sequence support
- Export back to CSV format

### Compatibility

- Based on spreadsheet_decoder with enhanced functionality
- Compatible API for existing spreadsheet operations
- Dart 3.0+ support
