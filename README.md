# ComEd Pricing
ComEdPricing is an iOS application designed to monitor real-time electricity pricing, for ComEd's hourly pricing programs. The project includes a dedicated widget for quick access to pricing information directly from the home screen.

## Project Structure
The project is organized into several targets to handle the main application, its extension, and testing:
* ComEdPricing: The primary iOS application.
* ComEdPriceWidgetExtension: A WidgetKit-based extension for home screen updates.
* ComEdPricingTests: Unit testing suite for core logic.
* ComEdPricingUITests: UI testing suite for user interface verification.

## Technical Specifications
The application is built using modern Apple development standards:
* Language: Swift 5.0.
* Frameworks: SwiftUI and WidgetKit.
* Deployment Target: iOS 26.2.
* Architecture: Optimized for both iPhone and iPad.

## Schemes
The project includes two primary shared schemes for building and running:
* ComEdPricing: Builds and runs the main application.
* ComEdPriceWidgetExtension: Specifically targets the widget for testing and debugging.

## Roadmap
* [X] Price Fetcher: Logic for pulling real-time data.
* [X] Price Log: Historical data tracking.
* [X] Notifications: Customizable user alerts.
* [X] Widgets: Support for both Home Screen and Lock Screen.
* [ ] Price Calculator: Estimating costs for various household appliances.
* [ ] Smart Integrations: Connecting with external platforms and vehicles (e.g., Tesla)

## Current Task
* Notification Bugs
* Widget Bugs
