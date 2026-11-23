# houseCARL 설치·연결·문제 해결

houseCARL은 AI 앱에 붙이는 도구(MCP 서버)입니다. MO2 인스턴스를 읽어서 AI가 다음을 할 수 있게 합니다.

- 로드오더, 플러그인 레코드, 어떤 모드가 이기는지, 끊긴 참조 조회
- 새 패치 플러그인 쓰기, Papyrus 컴파일·디컴파일, BSA·NIF 확인
- 넥서스 모드 검색, 업데이트 확인

저장소: [github.com/Avick3110/houseCARL](https://github.com/Avick3110/houseCARL) (GPL-3.0). 이 키트에는 포함하지 않습니다. 아래 내용은 houseCARL 2.1.2 기준입니다(확인일 2026-11-23). 최신 내용은 저장소 README를 따르세요.

## 필요한 것

- Windows x64
- .NET 10 런타임 **x64**
- MO2와 프로필 하나 (MO2가 켜져 있지 않아도 됨)
- Claude Code 2.1.143 이상(데스크톱 앱 Code 탭 포함) 또는 OpenAI Codex

## 설치

1. [릴리스 페이지](https://github.com/Avick3110/houseCARL/releases)에서 `houseCARL-<버전>.zip`을 받아 압축을 풉니다.
2. `houseCARL-Setup.exe`를 실행하고 앱을 고릅니다: `[1] Claude Code`, `[2] Codex`, `[3] Both`.
3. 설치 계획을 읽고 Enter를 누릅니다(`q`는 취소).
4. AI 앱을 다시 시작합니다.

설치 위치는 앱마다 다르며, 둘 다 정상입니다.

- Claude Code: `~\.claude\skills\housecarl\`에 서버와 스킬이 들어가고, `~\.claude.json`에 등록됩니다.
- Codex: `%LOCALAPPDATA%\houseCARL\server\`에 서버가, `~\.agents\skills\`에 스킬이 들어가고, `~\.codex\config.toml`에 등록됩니다.

## 연결 확인

1. AI 앱에서 이 키트 폴더를 엽니다.
2. `houseCARL로 지금 로드오더 상태 알려줘`라고 보냅니다.
3. 처음이면 MO2 인스턴스 폴더(`ModOrganizer.ini`가 있는 폴더)를 묻습니다. 알려 주면 이후로는 기억합니다.
4. 인스턴스 폴더, 프로필 이름, 플러그인 수가 나오면 정상입니다. 인스턴스가 내 MO2인지, 프로필이 시험용 프로필인지 확인하세요.
5. 응답에 "새로고침 대기"나 읽지 못해 제외된 플러그인(load failure, excluded)이 있으면, 그 플러그인과 관련된 판단은 믿지 마세요. 아래 "연결이 안 될 때"를 보고 해결한 뒤 다시 조회합니다.

## 업데이트

1. Claude Code와 Codex를 **모두 끕니다.** 실행 중인 서버는 교체할 수 없습니다.
2. 새 버전의 `houseCARL-Setup.exe`를 실행하고, 처음 설치할 때와 같은 앱을 고릅니다. 두 앱을 다 쓰면 `[3] Both`를 골라야 두 앱의 버전이 같아집니다.
3. MO2 인스턴스 경로 같은 설정은 유지됩니다.

## 연결이 안 될 때

| 증상 | 원인과 해결 |
|---|---|
| `houseCARL-Setup.exe` 창이 아무것도 없이 바로 닫힘 | 대개 .NET 10 런타임이 없는 경우입니다. **x64** 판을 설치하고 다시 실행합니다. 그래도 닫히면 PowerShell 창에서 실행해 오류 메시지를 확인합니다. |
| AI가 houseCARL 도구가 없다고 함 | 설치 후 앱을 다시 시작하지 않았거나, 다른 앱을 골라 설치한 경우가 많습니다. 설치 계획에 나온 앱을 확인합니다. |
| 잘 되다가 갑자기 모든 플러그인이 load failure로 나옴 | .NET 런타임이 업데이트되면 이미 떠 있던 서버가 이렇게 된 적이 있습니다(2026-11 확인). 먼저 AI 앱(세션)을 다시 시작해 봅니다. 그래도 같으면 일부 플러그인 파일이나 인스턴스 경로 문제일 수 있으니 응답의 오류 내용을 AI에게 보여 줍니다. |
| 엉뚱한 프로필을 읽음 | AI에게 `houseCARL MO2 인스턴스를 <폴더>로 바꿔 줘`라고 하거나, MO2에서 프로필을 바꾼 뒤 다시 확인합니다. |
| Papyrus 컴파일이 오류를 줄줄이 냄 | 바닐라·SKSE 스크립트 소스 경로를 `import_dirs`로 넘깁니다. `갈래/04-Papyrus.md` 참고. |

## 다른 MCP 서버는?

처음에는 houseCARL 하나면 충분합니다. 도구가 많을수록 AI가 엉뚱한 도구를 고를 가능성이 커지고, 매 대화에서 사용량도 더 듭니다.

- **넣지 않아도 되는 것:** 드라이브 전체를 여는 filesystem 서버(Claude Code·Codex에 이미 파일 도구가 있고, 권한만 넓어집니다), memory·sequential-thinking 서버(앱에 비슷한 기능이 이미 있습니다).
- **나중에 필요해지면:** SKSE로 엔진 함수를 찾아야 할 때 Ghidra용 MCP 서버를 씁니다. 실행 파일 역분석 지식이 필요한 고급 작업이라 이 키트에서는 다루지 않습니다.
