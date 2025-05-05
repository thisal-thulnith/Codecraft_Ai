# CodeCraft AI

**CodeCraft AI** is a Flutter-based mobile application designed to assist developers by generating code snippets based on user queries. With a sleek, modern UI featuring a dynamic particle background, glassmorphism design, and smooth animations, the app provides an engaging user experience. It leverages SQLite for local storage, the BLoC pattern for state management, and a variety of Flutter packages to deliver a robust and visually appealing coding assistant.

## Features

- **Code Snippet Generation**: Input a coding query and select a programming language (Dart, Python, JavaScript, Java, C++) to generate relevant code snippets.
- **Favorite Snippets**: Save and manage favorite snippets locally using SQLite, with the ability to toggle favorite status.
- **Interactive UI**: Enjoy a stunning particle background that responds to touch, glassmorphism-style cards, and smooth animations powered by `animate_do`.
- **State Management**: Utilizes the BLoC pattern for efficient and scalable state management.
- **Customizable Themes**: Features a polished theme with Google Fonts (Poppins), custom button styles, and a gradient background.
- **Local Database**: Stores snippets in a SQLite database for offline access and persistence.
- **Shimmer Loading Effects**: Displays elegant loading animations using the `shimmer` package while processing queries.

## Tech Stack

- **Framework**: Flutter
- **State Management**: flutter_bloc
- **Database**: sqflite
- **UI Enhancements**:
  - animate_do for animations
  - google_fonts for typography
  - shimmer for loading effects
- **Other Packages**: path, dart:ui for custom painting (particle effects)

## Getting Started

### Prerequisites
- Flutter SDK (version 3.0 or higher)
- Dart
- Android/iOS emulator or physical device

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/thisal-thulnith/codecraft-ai.git
