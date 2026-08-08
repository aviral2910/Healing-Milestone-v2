.PHONY: all help get clean runner watch splash icons apk build-runner

all: get runner

help:
	@echo "Available commands:"
	@echo "  make get       - Fetch dependencies (flutter pub get)"
	@echo "  make clean     - Clean project (flutter clean)"
	@echo "  make runner    - Run build_runner"
	@echo "  make watch     - Run build_runner in watch mode"
	@echo "  make splash    - Generate native splash screen"
	@echo "  make icons     - Generate launcher icons"
	@echo "  make apk       - Build Android APK"

get:
	flutter pub get

clean:
	flutter clean

runner: build-runner
build-runner:
	dart run build_runner build -d

watch:
	dart run build_runner watch -d

splash:
	dart run flutter_native_splash:create

icons:
	dart run flutter_launcher_icons

apk:
	flutter build apk
