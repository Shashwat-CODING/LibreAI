# LibreAI 🚀

**LibreAI** is an unrestricted, privacy-first mobile & desktop client built with Flutter, designed to harness the full power of **Cloudflare Workers AI**.

Developed by **CodErbauer**, LibreAI connects directly to Cloudflare's serverless AI infrastructure—giving you instant access to frontier LLMs, multimodal vision models, and dedicated image generation models with zero telemetry and 100% local data storage.

---

## ✨ Features

- **Frontier Multimodal & Vision Models**:
  - `Kimi K2.7 Code` (`@cf/moonshotai/kimi-k2.7-code`) — 1T parameter frontier model with vision & agentic coding.
  - `Llama 4 Scout 17B` (`@cf/meta/llama-4-scout-17b-16e-instruct`)
  - `Llama 3.2 11B Vision` (`@cf/meta/llama-3.2-11b-vision-instruct`)
  - `Mistral Small 3.1 24B` (`@cf/mistralai/mistral-small-3.1-24b-instruct`)
- **Reasoning & Code LLMs**:
  - `Llama 3.3 70B` (`@cf/meta/llama-3.3-70b-instruct`)
  - `DeepSeek R1 32B` (`@cf/deepseek-ai/deepseek-r1-distill-qwen-32b`)
- **Dedicated Image Generation**:
  - `Flux 2 Klein 4B` (`@cf/black-forest-labs/flux-2-klein-4b`)
  - Automatic prompt enhancement and native tool execution support.
- **Anthropic Minimalist Aesthetics**:
  - Warm Cream Light Mode (`#FBF9F5`) and Dark Obsidian Mode (`#141311`) with Terracotta Clay (`#D97757`) accents.
  - Typewriter model indicator for real-time model state feedback.
- **Privacy & Security Guarantee**:
  - **100% Local Storage**: Credentials, chat history, and tokens never leave your device.
  - **Zero Telemetry**: Direct connection to Cloudflare Workers AI with no middleman tracking.
- **Structured Error Handling**:
  - Clear user guidance for context window limits (413), daily neuron quotas (429), capacity limits, and model terms.

---

## 📸 Screenshots

*(App icon and branding powered by `logo.png`)*

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.12+ recommended)
- Android Studio / Xcode for platform builds
- (Optional) Cloudflare Account ID & API Token with Workers AI permissions

### Installation & Run

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/your-username/libreai.git
   cd libreai
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Application**:
   ```bash
   # macOS Desktop
   flutter run -d macos

   # Android Device / Emulator
   flutter run -d android
   ```

4. **Build Release APK**:
   ```bash
   flutter build apk --release
   ```

---

## ⚙️ Configuration

Launch the **Settings Modal** inside LibreAI to configure:
- **Cloudflare Account ID** & **Cloudflare API Token**
- Primary **Chat & Reasoning Model**
- **Dedicated Image Generation Model**
- App Theme Mode (**Auto System**, **Light**, **Dark**)
- Custom **System Prompt Persona**

---

## 👨‍💻 Author & Credits

- **Developer**: CodErbauer
- **Infrastructure**: Powered by [Cloudflare Workers AI](https://developers.cloudflare.com/workers-ai/)
- **Design Inspiration**: Anthropic Design System

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
