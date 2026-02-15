# Changelog

All notable changes to this project will be documented in this file.

## [1.1.1] - 2026-02-15

### Fixed
- Fixed API key not being loaded on startup
- Added onApiKeyChanged handler to fetch news when settings load
- Only start refresh timer when API key is configured
- Use ?? operator instead of || for proper null/undefined handling

## [1.1.0] - 2026-02-15

### Added
- News panel that displays full headlines with descriptions
- Click bar widget to open detailed news panel
- Right-click bar widget to open settings
- Panel shows article source, publish time, and "Open Article" buttons
- Beautiful scrollable list with numbered badges
- Loading, empty, and error states in panel

### Changed
- Changed click behavior: left-click opens panel, right-click opens settings
- Updated tooltip to reflect new interaction

## [1.0.2] - 2026-02-15

### Fixed
- Replaced NIcon with emoji for news icon (📰) to match original implementation
- Replaced NIcon refresh button with emoji (🔄) for better compatibility
- Ensures icons display correctly regardless of icon theme

## [1.0.1] - 2026-02-15

### Fixed
- Fixed Settings.qml component errors (replaced NTextField with NTextInput)
- Replicated original NewsSettings pattern from noctalia-shell for better compatibility
- Fixed NComboBox usage with proper currentKey and onSelected handlers
- Removed unnecessary imports and simplified structure
- Fixed syntax error in Settings.qml

## [1.0.0] - 2026-02-15

### Added
- Initial release of the News Bar widget plugin
- Support for NewsAPI.org integration
- Multiple country and category options
- Configurable refresh intervals
- Smooth scrolling text animation
- Auto-refresh functionality
- Manual refresh button
- Comprehensive settings panel
- Support for horizontal and vertical bars
- Tooltips and hover effects
