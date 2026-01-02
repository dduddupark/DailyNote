# Daily Note (하루 한 줄 기록) 📖

![App Icon](DailyNote/Assets.xcassets/AppLogo.imageset/logo@2x.png)

**하루의 소중한 순간을 단 한 줄로 기록하는 미니멀 다이어리 앱입니다.**

"가장 단순한 기록이 가장 강력한 기억이 됩니다."  
복잡한 일기 쓰기 대신, 오늘을 나타내는 가장 선명한 한 문장을 남겨보세요.

---

## ✨ 주요 기능

- **실시간 Cloud 동기화**: Firebase 연동으로 어떤 기기에서든 내 기록을 안전하게 보관합니다.
- **익명 로그인**: 복잡한 가입 절차 없이 바로 시작할 수 있습니다.
- **미니멀 최적화 UI**: Apple의 디자인 철학을 담은 깨끗하고 직관적인 "iCloud 스타일" UI를 제공합니다.
- **간결함의 미학**: 하루에 한 번(최대 10회 수정 가능), 가장 집중된 기록을 유도합니다.
- **다국어 지원**: 한국어와 영어를 공식 지원합니다.

## 🛠 Tech Stack

- **Framework**: SwiftUI
- **Architecture**: MVVM
- **Backend**: Firebase (Auth, Firestore)
- **Language**: Swift 5.10
- **Platform**: iOS 17.0+

## 📁 Project Structure

```text
DailyNote/
├── Models/         # Data Models (NoteEntry)
├── Services/       # Firebase & Global Services
├── ViewModels/     # Business Logic & UI State
├── Views/          # SwiftUI View Components
│   ├── Splash/     # Brand Experience
│   └── Home/       # Main Interface
└── Resources/      # Assets & Localization
```

---

## 🚀 Getting Started

1. **Clone the repository**
   ```bash
   git clone https://github.com/dduddupark/DailyNote.git
   ```
2. **Open with Xcode**
   Open `DailyNote.xcodeproj`.
3. **Firebase Setup**
   - Firebase Console에서 새로운 프로젝트를 생성합니다.
   - `GoogleService-Info.plist` 파일을 프로젝트 루트에 추가합니다.
4. **Build & Run**
   `Cmd + R` 키를 눌러 시뮬레이터 또는 디바이스에서 실행합니다.

---

## 📄 License

Copyright &copy; 2026 dduddupark. All rights reserved.
