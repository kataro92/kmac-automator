# KMacAutomator

A macOS menubar application for automating mouse clicks with customizable timing and duration settings.

## Features

- **Menubar Integration**: Lightweight app that runs from the macOS menubar
- **Customizable Timing**: 
  - Start delay before automation begins
  - Configurable duration for the automation session
  - Adjustable click interval between clicks
  - Configurable click delay (time between mouse down and mouse up)
- **Real-time Status**: Visual feedback showing current automation state
- **Accessibility Compliant**: Uses macOS accessibility APIs for reliable mouse automation

## Requirements

- macOS (with Accessibility permissions)
- Xcode 14.0 or later
- Swift 5.0 or later

## Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd KMacAutomator
   ```

2. Open the project in Xcode:
   ```bash
   open KMacAutomator.xcodeproj
   ```

3. Build and run the project (⌘R)

## Setup

### Grant Accessibility Permissions

The app requires Accessibility permissions to automate mouse clicks:

1. When you first run the app, it will prompt you to grant permissions
2. Go to **System Settings > Privacy & Security > Accessibility**
3. Enable **KMacAutomator**
4. Restart the app if needed

## Usage

1. Click the menubar icon (cursor/click icon)
2. Configure your settings:
   - **Start after**: Delay in seconds before automation begins
   - **Duration**: How long the automation should run (in seconds)
   - **Click on each**: Interval between clicks (in milliseconds)
   - **Click delay**: Time between mouse down and mouse up (in milliseconds)
3. Click **Start** to begin automation
4. Click **Stop** to stop automation at any time

### Settings

- **Start after**: Wait time before starting clicks (default: 2.0 seconds)
- **Duration**: Total time the automation runs (default: 3.0 seconds)
- **Click on each**: Milliseconds between each click (default: 360 ms)
- **Click delay**: Milliseconds between mouse down and mouse up events (default: 10 ms)
  - Automatically adjusts if "Click on each" is smaller than the delay

## How It Works

The app uses macOS Core Graphics (Quartz) event APIs to programmatically generate mouse click events at the current cursor position. It:

1. Captures the current mouse position
2. Creates mouse down and mouse up events
3. Posts them to the system event stream
4. Repeats at the configured interval for the specified duration

## Project Structure

```
KMacAutomator/
├── KMacAutomator/
│   ├── KMacAutomatorApp.swift      # Main app entry point
│   ├── MenubarManager.swift         # Menubar icon and popover management
│   ├── AutomationController.swift   # Core automation logic
│   ├── Settings.swift               # Settings model with auto-sync
│   ├── SettingsView.swift           # Settings UI
│   └── ContentView.swift            # (Unused - placeholder)
└── README.md
```

## Development

### Building

```bash
xcodebuild -project KMacAutomator.xcodeproj -scheme KMacAutomator -configuration Release
```
or just open it in XCode and Run

### Code Style

- Follow Swift API Design Guidelines
- Use meaningful variable names
- Add comments for complex logic

## License

MIT License

Copyright (c) 2025 Black Kat

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

## Contributing

This project was created using [Cursor](https://cursor.sh), an AI-powered code editor. Contributions are welcome! Please feel free to submit issues or pull requests.

## Troubleshooting

### Clicks not working

1. Ensure Accessibility permissions are granted
2. Check that the app appears in System Settings > Privacy & Security > Accessibility
3. Try restarting the app

### Wrong click position

The app uses coordinate system conversion between Cocoa (bottom-left origin) and Quartz (top-left origin). If clicks appear at wrong positions, this may be a multi-monitor setup issue.

## Author

Created by Black Kat

