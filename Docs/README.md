# 🎶 BeatGlow – Live Music Visualizer with Light Sync

**BeatGlow** is a real-time music visualizer that reacts to the beat, amplitude, and energy of any playing song. It’s designed to control smart lights like **Philips Hue** (or any other light system) using a pluggable `LightManager` layer.

---

## 🌟 Features

- 🎧 **Live Audio Analysis**: Captures and processes music using your device's microphone.
- 🔊 **Beat & Amplitude Detection**: Reacts to percussive beats and loudness levels in real time.
- 🌈 **Dominant Color Detection**: Extracts the most prominent audio-driven color to use in visuals and lighting.
- 💡 **Light Sync-Ready**: Uses a clean `LightManager` protocol that can be connected to smart lighting systems like Philips Hue.
- 🎨 **Dynamic SwiftUI Visuals**: Beautiful glowing circles and smooth animations that respond to music.
- 🧪 **Testable MVVM Architecture**: Built with Combine and fully testable components including audio, color, and control logic.

---

## 📸 Screenshots

| Audio Reactive | Beat Detected | Light Pulse |
|----------------|----------------|-------------|
| ![Audio](docs/audio.gif) | ![Beat](docs/beat.gif) | ![Pulse](docs/pulse.gif) |

---

## 🛠 How It Works

1. The microphone listens to ambient or played music.
2. Audio is processed to extract:
   - **Amplitude**: Intensity of sound
   - **Beat**: Detection of beat pulses
   - **Dominant Color**: From frequency spectrum
3. Visuals update in SwiftUI to match the music.
4. `LightManager` receives color and brightness updates to control lights (to be integrated).

---

## 🚨 Light Integration (Pluggable)

> 🔧 **Note:** This project **does not yet integrate Hue or any specific light system**.  
> The `LightManagerProtocol` is provided and can be implemented using **any SDK** like Philips Hue, LIFX, or custom IoT light systems.

```swift
protocol LightManagerProtocol {
    func setColor(_ color: Color)
    func flashOnBeat()
    func updateColor(brightness: Float, color: Color)
}
```

You can inject your own light system logic by conforming to this protocol.

---

## 📦 Requirements

- Xcode 15+
- MacOS 13+
- iOS 16.0+
- Swift 5.9+
- Microphone permission (no network needed)
- Optional: Smart light SDK (e.g., Philips Hue) to connect to `LightManager`

---

## Install Dependencies

This project uses [AudioKit](https://audiokit.io/) to analyze microphone input for real-time beat and amplitude detection.

To install dependencies:

1. Open the project in Xcode.
2. Go to **File > Add Packages**.
3. Search for: `https://github.com/AudioKit/AudioKit`
4. Select the latest stable version and add it to the project.

## 📱 Run the App

```bash
git clone https://github.com/your-username/BeatGlow.git
cd BeatGlow
open BeatGlow.xcodeproj
```

- Build and run the app.
- Grant microphone access.
- Play any music nearby or on the device.
- Watch the visualizer pulse and change with the beat! 🪩

---

## 📂 Folder Structure

```
LightApp/
├── Audio/
│   ├── AudioManager.swift
│   └── AudioManagerProtocol.swift
├── Light/
│   ├── LightManager.swift
│   └── LightManagerProtocol.swift
├── Features/
│   └── PartyMode/
│       ├── Views/
│       │   └── PartyModeView.swift
│       └── ViewModels/
│           └── PartyModeViewModel.swift
├── Mocks/
```

---

## 🧪 Testing

- **Unit Tests**: Covers audio processing, light update logic, and view model behavior.
- **UI Tests**: Simulates visualizer state transitions.

Run tests via:

```bash
⌘ + U
```

---

## 🧹 SwiftLint

We use [SwiftLint](https://github.com/realm/SwiftLint) to enforce clean code.

### Run

```bash
brew install swiftlint
swiftlint
```

> Config in `.swiftlint.yml`.

---

## 📃 License

MIT License – see [LICENSE](LICENSE) for details.

---

## 👨‍💻 Author

Made with 🎵, 🧠, and 💡 by Chinthan M (https://github.com/your-username).

---

## 🙋‍♀️ Want to Contribute?

- Add Hue, LIFX, or custom IoT light integration to `LightManager`
- Improve beat detection accuracy
- Create new visual effects

---
