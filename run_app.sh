#!/bin/bash

echo "Starting FinEnot App..."

echo "Cleaning project..."
flutter clean

echo "Getting dependencies..."
flutter pub get

echo "Checking available devices..."
flutter devices

echo "Starting emulator..."
flutter emulators --launch Pixel_4_API_30

echo "Waiting for emulator to start..."
sleep 30

echo "Running app..."
flutter run --debug
