.PHONY: all clean pub run build-apk build-ios build-runner analyze test

# Default target
all: pub build-runner run

# Clean the project
clean:
	flutter clean

# Get dependencies
pub:
	flutter pub get

# Run the app
run:
	flutter run

# Build APK
build-apk:
	flutter build apk

# Build iOS
build-ios:
	flutter build ios

# Run build_runner (Generates Freezed, Riverpod, and JSON Serializable files)
build-runner:
	dart run build_runner build --delete-conflicting-outputs

# Watch build_runner (Auto-generates files on save)
build-runner-watch:
	dart run build_runner watch --delete-conflicting-outputs

# Run Flutter Analyze
analyze:
	flutter analyze

# Run tests
test:
	flutter test
