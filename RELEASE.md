# 🚀 LibreAI v1.0.0 — Initial Public Release

> **Developed by [CodErbauer](https://github.com/coderbauer)**  
> Privacy-first, unrestricted AI client powered by [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/)

---

## 🎬 Setup Guide

New user? Watch the video setup guide before getting started:

[![LibreAI Setup Guide](https://img.youtube.com/vi/k1oGhb50qA4/maxresdefault.jpg)](https://www.youtube.com/watch?v=k1oGhb50qA4)

---

## 📦 Download

| Platform | File | Architecture | Size | Notes |
|----------|------|-------------|------|-------|
| **Android** | `app-arm64-v8a-release.apk` | ARM64 (64-bit) | 18.9 MB | ✅ Recommended — Modern phones (2018+) |
| **Android** | `app-armeabi-v7a-release.apk` | ARMv7 (32-bit) | 16.4 MB | Older/budget Android devices |
| **Android** | `app-x86_64-release.apk` | x86_64 | 20.3 MB | Android emulators / Intel-based devices |
| **macOS** | Build from source | — | — | Run `flutter run -d macos` |

> **Not sure which APK to pick?**  
> → Install **`app-arm64-v8a-release.apk`** — it works on virtually all modern Android phones.

> **Note**: You will need your own **Cloudflare Account ID** and **Cloudflare Workers AI API Token** to use the app. Free Cloudflare accounts include 10,000 free AI neurons per day.

---

## ✨ What's in v1.0.0

### Core Features
- **Kimi K2.7 Code** — 1T parameter frontier multimodal model with vision and agentic code execution
- **Llama 4 Scout 17B** — Meta's multimodal vision LLM
- **Llama 3.2 11B Vision** — Lightweight vision model for fast inference
- **Mistral Small 3.1 24B** — Fast multimodal model with function calling
- **Llama 3.3 70B** — Meta's flagship text & code reasoning model
- **DeepSeek R1 32B (Qwen Distill)** — Extended chain-of-thought reasoning model
- **Flux 2 Klein 4B** — Dedicated image generation with automatic prompt enhancement

### Privacy & Security
- ✅ **100% Local Storage** — All API keys, chat threads, and settings stored on-device only
- ✅ **Zero Telemetry** — Direct connection to Cloudflare Workers AI with no middlemen
- ✅ **No Account Required** — Use your existing Cloudflare credentials

### User Experience
- 🎨 **Anthropic-Inspired Design** — Warm Cream Light / Dark Obsidian themes with Terracotta Clay accents
- 🌗 **Auto System Theme** — Follows OS light/dark preference automatically
- 📖 **Typewriter Model Indicator** — Real-time model state feedback in top bar
- 🖼️ **Image Attachment & Vision** — Attach images to messages when using vision-capable models
- 🕓 **Chat History** — Full multi-thread conversation history with rename/delete support
- 📱 **Responsive Layout** — Adaptive sidebar for desktop/wide screen and mobile layouts

### Onboarding
- 3-slide interactive onboarding experience
- Guided API credential setup with inline **Video Guide** button
- CodErbauer branding and privacy pledge

### Settings
- Live Light / Dark / Auto theme switching
- Per-session model selection (LLM + Image Gen)
- Custom system prompt persona configuration
- **Restore Factory Defaults** reset
- **Clear Cache & Reset All Data** — Wipes all local storage and returns to onboarding

### Error Handling
Structured, user-actionable messages for all Cloudflare Workers AI error codes:

| Error | Guidance Shown |
|-------|---------------|
| Context window limit (413 / 3006) | Start a new chat |
| Daily 10k neuron limit (429 / 3036) | Upgrade to paid plan |
| Out of capacity (429 / 3040) | Retry or switch model |
| Model terms required (403 / 5016) | Accept terms in Cloudflare Dashboard |
| Request timeout (408 / 3007) | Retry request |

---

## 🛠️ Building from Source

```bash
# Clone
git clone https://github.com/your-username/libreai.git
cd libreai

# Install dependencies
flutter pub get

# Run on Android
flutter run -d android

# Run on macOS
flutter run -d macos

# Build release APK
flutter build apk --release
```

**Requirements**: Flutter SDK v3.12+, Android SDK (API 21+), or Xcode 15+ for macOS.

---

## ⚙️ First-Time Setup

1. Install the APK or build from source
2. Complete the **3-step onboarding** wizard
3. Enter your **Cloudflare Account ID** and **Cloudflare Workers AI API Token**
   - Get them free at [dash.cloudflare.com](https://dash.cloudflare.com)
   - Go to **AI → Workers AI** and create an API token with `AI: Read` permission
4. Select your preferred **LLM model** and **image generation model** in Settings
5. Start chatting! 🎉

---

## 📋 Known Limitations

- iOS build not configured in this release (iOS asset catalog setup pending)
- Image attachment only available when a **Vision-capable model** is selected
- Free Cloudflare tier limited to **10,000 AI neurons/day**

---

## 🙏 Credits

- **Developer**: CodErbauer
- **AI Infrastructure**: [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/)
- **Models**: Meta (Llama), Moonshot AI (Kimi), Mistral AI, DeepSeek, Black Forest Labs (Flux)
- **Design Inspiration**: Anthropic Design System

---

*LibreAI is open source under the MIT License.*
