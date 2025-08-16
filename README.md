# 📸 Just a Sec App

A lightweight, single-user, **offline-first** story app built with **Flutter**.  
Capture **1-second clips**, add captions, and store them locally — no internet required.

---

## 🚀 Tech Stack

| Purpose          | Tech / Package               | Why                                        |
| ---------------- | ---------------------------- | ------------------------------------------ |
| UI Framework     | Flutter (stable)             | Cross-platform, fast iteration, hot reload |
| State Management | Provider                     | Lightweight, simple for small apps         |
| Navigation       | Navigator 2.0 / go_router    | Easy route management & deep linking       |
| Camera           | camera package               | Native camera access                       |
| Image Handling   | image_picker                 | Optional image upload from gallery         |
| Local Storage    | hive                         | Store user profile (name, age, photo)      |
| Clip Storage     | path_provider + video_player | Save and replay 1-second videos locally    |
| Styling          | Google Fonts                 | Elegant typography                         |
| Theming          | Custom theme in `theme.dart` | Consistent colors, font sizes              |
| Animations       | animated_text_kit / lottie   | Smooth micro-interactions                  |

---

## 📂 Project Structure

lib/
│
├── main.dart # Entry point
├── app.dart # MaterialApp setup & routing
│
├── config/
│ ├── theme.dart # Color scheme, fonts, styles
│ └── constants.dart # App-wide constants (texts, durations)
│
├── models/
│ ├── user_model.dart # Username, age, optional photo
│ └── story_model.dart # Story data (file path, date, caption)
│
├── services/
│ ├── storage_service.dart # Save/load stories & profile locally
│ └── camera_service.dart # Capture 1s clips
│
├── screens/
│ ├── splash_screen.dart
│ ├── register_screen.dart
│ ├── camera_screen.dart
│ ├── post_screen.dart # Add caption/location after capture
│ ├── home_screen.dart
│ ├── story_view_screen.dart
│ ├── profile_screen.dart
│
├── widgets/
│ ├── custom_button.dart
│ ├── bottom_nav_bar.dart
│ ├── story_card.dart # Gallery view
│ ├── countdown_overlay.dart
│ └── profile_avatar.dart
│
└── utils/
└── format_date.dart # Date formatting helper

---

## 🛠️ Features

- 📷 **Capture 1-second video clips** directly from the camera
- 🖼 **Optional gallery uploads** for profile or stories
- 💾 **Offline storage** for all clips & profile data
- 🎨 **Custom theming** with Google Fonts
- 🔄 **Smooth animations** for micro-interactions
- 🏠 **Simple navigation** using `go_router` / Navigator 2.0
