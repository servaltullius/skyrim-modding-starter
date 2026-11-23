# 스카이림 모딩 시작 키트 (skyrim-modding-starter)

AI 코딩 도구로 스카이림 모드를 고치고 만들려는 사람을 위한 폴더입니다.
이 폴더를 Claude Code나 Codex에서 열면, AI가 `AGENTS.md`의 규칙을 따라 일합니다.

- 원본 모드는 건드리지 않고 새 플러그인으로 고칩니다.
- 레코드 값이나 FormID를 추측하지 않고 조회합니다.
- 게임 안에서 확인해야 하는 것은 확인 목록으로 넘깁니다.

처음이면 **[시작하기.md](시작하기.md)** 부터 읽으세요.

## 대상과 지원 환경

확인일: 2026-11-23. 아래 버전 정보는 이 날짜 기준이니, 오래됐으면 각 링크에서 최신 요구 사항을 확인하세요.

| 항목 | 지원 | 비고 |
|---|---|---|
| 운영체제 | Windows x64 | houseCARL이 Windows 전용 |
| 게임 | Skyrim Special Edition / Anniversary Edition | 이 키트는 **AE 1.6.1170** 환경에서 만들었습니다. 1.5.97, GOG판, 1.7.x에서는 시험하지 않았습니다. VR은 대상이 아닙니다. |
| 모드 관리자 | **Mod Organizer 2** | houseCARL이 MO2 인스턴스를 읽습니다. **Vortex는 지원하지 않습니다.** |
| AI 앱 | Claude 데스크톱 앱의 Code 탭 / Claude Code CLI **2.1.143 이상**, 또는 **OpenAI Codex** | 유료 요금제가 필요할 수 있으니 각 앱의 안내를 확인하세요. |
| houseCARL | 2.1.2에서 확인 | [github.com/Avick3110/houseCARL](https://github.com/Avick3110/houseCARL) (GPL-3.0). 이 키트에 포함하지 않으며, 직접 받아 설치합니다. |
| .NET 런타임 | 10.0 **x64** | houseCARL 실행에 필요 |

## 폴더 구성

```
skyrim-modding-starter/
├─ README.md                 이 문서
├─ LICENSE                   MIT 라이선스
├─ 시작하기.md                설치부터 첫 대화까지
├─ AGENTS.md                 AI가 따르는 규칙 (Claude·Codex 공통)
├─ CLAUDE.md                 AGENTS.md를 불러오는 한 줄
├─ .claude/settings.json     Claude Code 권한 기본값 (houseCARL 읽기 도구 허용, 세이브 보호)
├─ 갈래/                      작업 종류별 안내
│  ├─ 00-도구-고르기.md
│  ├─ 01-모드리스트-점검.md
│  ├─ 02-INI-배포.md
│  ├─ 03-ESP-패치.md
│  ├─ 04-Papyrus.md
│  ├─ 05-SKSE.md
│  └─ 06-크래시-원인찾기.md
├─ mcp/houseCARL.md          설치, 연결 확인, 업데이트, 문제 해결
├─ skse-template/            SKSE 플러그인 빌드 틀 (CommonLibSSE-NG)
├─ 기록/수동-수정-기록.md     원본을 직접 고쳤을 때 남기는 기록
├─ 서식/배포-점검표.md        모드를 올리기 전에 확인할 것
└─ 검증/합격-과제.md          이 키트가 제대로 동작하는지 시험하는 방법
```

## 안전장치와 한계

`.claude\settings.json`은 Claude가 다음 위치의 파일을 고치지 못하게 막습니다. 2026-11-23에 Windows에서 확인한 범위는 아래와 같습니다. 파일 쓰기 도구(Write)와 PowerShell의 `Set-Content` 쓰기가 막혔고, 그 밖의 위치에는 정상적으로 쓰였습니다.

- 세이브 폴더: 경로에 `My Games\Skyrim...\Saves`가 들어간 곳, MO2 프로필별 세이브(`profiles\<프로필>\saves`)
- 게임 설치 폴더: 이름이 `Stock Game`인 폴더, Steam 기본 위치(`steamapps\common\Skyrim Special Edition`)
- MO2 프로필의 `modlist.txt`, `plugins.txt`, `loadorder.txt`

다만 완전한 차단은 아닙니다.

- **Codex에는 적용되지 않습니다.** 이 설정 파일은 Claude 전용입니다. Codex에서는 `AGENTS.md`의 규칙과 Codex 자체의 승인 설정에만 기댑니다.
- **houseCARL의 쓰기는 이 규칙과 별개입니다.** houseCARL은 기본적으로 새 MO2 모드 폴더에만 씁니다. 하지만 원본 플러그인을 고치는 옵션도 있고, 이 옵션의 확인은 서버가 매번 묻는다는 보장이 없습니다. 그래서 `AGENTS.md`가 원본 수정 전에 사용자 동의와 백업을 따로 요구합니다.
- **자동 허용한 houseCARL 도구는 "조회용"이지만, 조회 결과를 `.jsonl` 파일로 내보내는 기능이 있고, 넥서스 조회 도구는 검색어나 파일 해시(MD5)를 넥서스로 보냅니다.** 플러그인·세이브 파일을 고치는 도구는 자동 허용에 넣지 않았습니다.
- **`skse-template`의 `build.cmd`가 하는 복사(DEPLOY_DIR)는 CMake가 하므로 이 규칙으로 막히지 않습니다.** `build.cmd`가 게임 폴더·`Data` 폴더로의 복사는 거부하지만, 지정한 폴더가 맞는지는 사용자가 확인해야 합니다.
- Python 같은 프로그램이 직접 여는 파일, 경로를 밝히지 않는 명령은 막지 못합니다(Claude Code 공식 문서 기준).
- 게임을 위 이름이 아닌 다른 폴더에 설치했다면 그 폴더는 보호되지 않습니다. `.claude\settings.json`의 `deny` 목록에 `"Edit(//드라이브문자/경로/**)"` 형식으로 추가하세요. 예: `G:\Games\Skyrim` → `"Edit(//g/Games/Skyrim/**)"`
- **시험용 프로필은 세이브와 모드 목록만 나눕니다.** 모든 프로필이 같은 `mods` 폴더와 `overwrite` 폴더를 씁니다. 그래서 원본 모드 파일을 고치면 본 프로필에도 그대로 적용됩니다. 원본을 고치기 전에는 반드시 그 파일을 백업하세요(`기록/수동-수정-기록.md`).
- 그래서 **시험용 프로필과 백업**(시작하기 2·3단계)이 가장 확실한 안전장치입니다.

## 라이선스

이 키트는 [MIT 라이선스](LICENSE)입니다. 자유롭게 복사하고 고쳐서 쓸 수 있습니다.

- **houseCARL**(GPL-3.0)은 이 키트에 들어 있지 않습니다. 각자 [houseCARL 저장소](https://github.com/Avick3110/houseCARL)에서 받아 설치합니다.
- `skse-template`이 쓰는 **CommonLibSSE-NG** 등 라이브러리도 들어 있지 않습니다. 빌드할 때 vcpkg가 내려받으며, 각 라이브러리의 라이선스를 따릅니다.

## 이 키트가 하지 않는 것

- MO2 모드 켜기, 플러그인 순서 정하기: 사용자가 MO2에서 직접 합니다.
- 게임 실행과 게임 안 확인: AI는 게임 화면을 보지 못합니다. 확인 목록을 받아 직접 확인하세요.
- 생성 도구(PGPatcher, DynDOLOD, Synthesis, Nemesis·Pandora 등)의 결과물 수정: 그 도구를 다시 돌려야 합니다.
