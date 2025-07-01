# 📦 Project Sharer

A clean, modern Flutter app using GetX architecture that lets users:

* Input project metadata
* Generate clarifying questions
* Answer those questions
* Automatically generate platform-specific shareable content using Gemini API

---

## 🔐 API Key Handling & Security

### ✅ Safe Practices Implemented:

* **Gemini API Key** is stored locally using `SharedPreferences`, **not** hardcoded.
* Key is set during onboarding and can be reset via a built-in UI (`Reset API Key`).
* `apiKey` is **not printed**, logged, or exposed in any stream or network trace.
* No network requests use insecure transport (HTTP).
* No access tokens or sensitive data stored in memory beyond runtime.

### 🔍 Checked for API Leaks:

* ✅ No hardcoded keys in any file
* ✅ No accidental `.toString()` or logging of keys
* ✅ All API interactions use runtime-injected keys only
* ✅ Reset workflow safely clears API key and resets navigation

---

## 📂 Structure

```
├── main.dart
├── bindings/
│   └── project_binding.dart
├── controllers/
│   ├── project_controller.dart
│   └── question_controller.dart
├── models/
│   └── question_model.dart
├── services/
│   └── api_service.dart
└── views/
    ├── api_setup_screen.dart
    ├── project_input_screen.dart
    ├── question_screen.dart
    └── result_screen.dart
```

---

## 🚀 Features

* Offline-first user flow using `SharedPreferences`
* Clean GetX-based MVC architecture
* Gemini API integration (streamed responses)
* Shareable content generation for:

  * LinkedIn
  * X (Twitter)
  * GitHub
  * Reddit
  * Hacker News
  * Hashnode
  * Discord


---

## ✅ TODO / Suggestions

* Add encryption (optional) for stored API key
* Add monthly quota warning when tokens exceed threshold
* Add network timeout handling for Gemini API errors

---

## 🧠 Credits

Built with ❤️ by Aniket.

*"Build once, share everywhere."*
