# Fotosfera

Fotosfera is a Flutter-based image browsing application with pagination, optimized image loading, and a smooth user experience. It uses Firebase for crash reporting, EasyLocalization for multi-language support, and GetIt for dependency injection.

![Demo](assets/demo.gif)

## Features
- Fetches images with pagination support.
- Displays optimal image variants based on available screen size and container size.
- Caches images for efficient loading and offline access.
- Maintains scroll position when navigating back to the image list.
- Supports image detail viewing with zoom and pan gestures.
- Implements a robust architecture using BLoC for state management.
- Uses Dio for API requests and CachedNetworkImage for optimized image loading.
- Firebase Crashlytics for error tracking.
- Multilingual support with EasyLocalization.
- Navigation with GoRouter.

## Installation
### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK
- Firebase setup

### Steps
1. Clone the repository:
   ```sh
   git clone https://github.com/alekla0126/fotosfera.git
   cd fotosfera
   ```
2. Install dependencies:
   ```sh
   flutter pub get
   ```
3. Configure Firebase:
   - Ensure you have `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) set up.
   - Initialize Firebase in `main.dart`.
4. Run the application:
   ```sh
   flutter run
   ```

## Project Structure
```
lib/
├── di/                     # Dependency injection
├── features/
│   ├── job_evaluation/
│   │   ├── data/           # Data layer (models, repositories, API calls)
│   │   ├── domain/         # Business logic (use cases, entities)
│   │   ├── presentation/   # UI layer (pages, widgets, BLoC)
├── translations/           # Localization files
├── main.dart               # Entry point
```

## Technologies Used
- **State Management:** BLoC
- **Networking:** Dio
- **Dependency Injection:** GetIt
- **Navigation:** GoRouter
- **Localization:** EasyLocalization
- **Crash Reporting:** Firebase Crashlytics
- **Image Loading & Caching:** CachedNetworkImage

## API
Fotosfera fetches images from the following endpoint:
```
GET https://ru.api.dev.photograf.io/v1/jobEvaluation/images?continuationToken={token}
```
- `continuationToken` is used for pagination.
- Images are fetched and displayed in a grid format with three columns.
- The optimal image variant is selected based on the available space.
- New pages are loaded when scrolling reaches the bottom, utilizing `continuationToken`.

## Testing
Run unit tests using:
```sh
flutter test
```

## Author
- **GitHub:** [alekla0126](https://github.com/alekla0126)
- **Email:** [alekla0126@gmail.com](mailto:alekla0126@gmail.com)

## License
This project is licensed under the MIT License.
