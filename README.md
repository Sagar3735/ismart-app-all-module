# iSmart HR Portal App

A modern, production-ready Mobile HR Portal and Dashboard application built with Flutter.

## Overview

The iSmart App is a comprehensive self-service HR portal designed to streamline employee management and day-to-day operations. It features a responsive, mobile-first design with a polished UI matching the iSmart web experience.

## Key Features

- **Module Dashboard:** A centralized 36-module architecture dashboard for quick access to various HR functions.
- **Attendance Management:** Includes advanced biometric Face Recognition Attendance and Geofencing capabilities to ensure secure and location-verified check-ins.
- **Payroll & Leave:** Manage and view payroll details, leave requests, and employee records seamlessly.
- **Self-Service & Profile:** Dedicated sections for personal profile management, settings, and learning modules.
- **Modern UI/UX:** Built with a consistent design system, utilizing curated color palettes, modern typography (`google_fonts`), and smooth animations.

## Getting Started

### Prerequisites
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio / VS Code with Flutter plugins

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   ```
2. Navigate to the project directory:
   ```bash
   cd ismart_app
   ```
3. Install dependencies:
   ```bash
   flutter pub get
   ```
4. Run the app:
   ```bash
   flutter run
   ```

## Architecture & State Management

- The app uses a bottom-navigated architecture with dedicated screens for core modules.
- Proper state management is employed for handling mock data like employee profiles, attendance, and leave records.

## Quality Assurance

This codebase strictly adheres to Flutter development standards. Run the following command to ensure there are no static analysis issues:
```bash
flutter analyze
```
